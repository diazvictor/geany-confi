# -*- coding: utf-8 -*
#
#  Geany Git Branches Plugin
#
#  Copyright (c) 2018 joonis new media
#  Author: Thimo Kraemer <thimo.kraemer@joonis.de>
#
#  This program is free software; you can redistribute it and/or modify
#  it under the terms of the GNU General Public License as published by
#  the Free Software Foundation; either version 2 of the License, or
#  (at your option) any later version.
#
#  This program is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#  GNU General Public License for more details.
#
#  You should have received a copy of the GNU General Public License
#  along with this program; if not, write to the Free Software
#  Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston,
#  MA 02110-1301, USA.

import gtk
import geany
import os
import sys
import subprocess
import traceback


# Logging helpers ######################################################

def add_message(text, warn=False):
    text = text.strip()
    if not text:
        return
    # Statusbar
    statusbar = geany.main_widgets.progressbar.get_parent()
    context_id = statusbar.get_context_id('git-plugin')
    lines = text.splitlines()
    status = lines[0]
    if len(lines) > 1:
        status += ' ... ' + lines[-1]
    statusbar.push(context_id, status)
    # Message
    msgwindow = geany.msgwindow
    if warn:
        color = msgwindow.COLOR_RED
    else:
        color = msgwindow.COLOR_BLUE
    msgwindow.msg_add(text, color)

def add_status(text):
    text = text.strip()
    if not text:
        return
    geany.msgwindow.status_add(text)

def _excepthook(etype, value, tb):
    if isinstance(value, subprocess.CalledProcessError):
        msg = value.output
    else:
        msg = ''.join(traceback.format_exception(etype, value, tb))
    add_message(msg, warn=True)
sys.excepthook = _excepthook


# Menu helpers #########################################################

def create_submenu(parent, name):
    menu = gtk.Menu()
    item = gtk.MenuItem(name)
    item.set_submenu(menu)
    parent.append(item)
    item.show()
    menu.show()
    return item, menu

def create_menu_item(parent, name, action=None, checked=None):
    if name == '-':
        item = gtk.SeparatorMenuItem()
    elif checked is None:
        item = gtk.MenuItem(name)
    else:
        item = gtk.CheckMenuItem(name)
        item.set_active(checked)
    parent.append(item)
    if action:
        item.connect('activate', action)
    item.show()
    return item

def remove_menu_items(menu, offset=0):
    for item in menu.get_children()[offset:]:
        menu.remove(item)


# Git command class ####################################################

class Git(object):

    _instance_cache = {}

    def __init__(self, path):
        if not os.path.isdir(os.path.join(path, '.git')):
            raise ValueError('not a git repository')
        self.path = path
        self.active_branch = None
        self.local_branches = set()
        self.remote_branches = set()
        self.remotes = set()
        self._instance_cache[path] = self
        self.get_branches()

    @staticmethod
    def get_git_basepath(path):
        if not path or '/gvfs/' in path:
            return
        while not path.endswith(os.path.sep):
            path = os.path.dirname(path)
            if os.path.isdir(os.path.join(path, '.git')):
                return path

    @classmethod
    def git_from_path(cls, path):
        path = cls.get_git_basepath(path)
        if not path:
            return
        if path in cls._instance_cache:
            return cls._instance_cache[path]
        return cls(path)

    def __call__(self, *args, **kwargs):
        cmd = ['git'] + list(args)
        add_status('Executing: ' + ' '.join(cmd))
        cwd = os.getcwd()
        try:
            os.chdir(self.path)
            output = subprocess.check_output(cmd, stderr=subprocess.STDOUT)
        finally:
            os.chdir(cwd)
        if kwargs.get('log_output', True):
            add_message(output)
        return output.strip()

    def checkout(self, branch, remote=None):
        self.active_branch = None
        if remote:
            # self('checkout', '-b', branch, '%s/%s' % (remote, branch))
            self('checkout', '--track', '%s/%s' % (remote, branch))
            self.local_branches.add(branch)
        else:
            self('checkout', branch)
        self.active_branch = branch

    def fetch(self, remote=None):
        self('fetch', remote or '--all')
        self.get_branches()

    def pull(self, remote, branch):
        self('pull', remote, branch)

    def push(self, remote, branch):
        self('push', remote, branch)

    def create_branch(self, branch):
        self.active_branch = None
        self('checkout', '-b', branch)
        self.active_branch = branch
        self.local_branches.add(branch)

    def delete_branch(self, branch):
        self('branch', '-d', branch)
        self.local_branches.remove(branch)

    def get_branches(self):
        output = self('branch', '-a', '--no-color', log_output=False)
        self.active_branch = None
        self.local_branches.clear()
        self.remote_branches.clear()
        self.remotes.clear()
        for name in output.splitlines():
            name = name.strip()
            if name.startswith('remotes/'):
                if ' -> ' in name:
                    continue
                r, remote, branch = name.split('/', 2)
                self.remotes.add(remote)
                if branch in self.local_branches:
                    continue
                name = '%s/%s' % (remote, branch)
                self.remote_branches.add(name)
            else:
                if name.startswith('*'):
                    name = name[1:].strip()
                    self.active_branch = name
                self.local_branches.add(name)
        return (self.active_branch, self.local_branches, self.remote_branches)

    def get_remotes(self):
        remotes = self('remote', log_output=False).splitlines()
        self.remotes.clear()
        self.remotes.update(remotes)
        return self.remotes

    def has_changes(self):
        try:
            self('diff', '--quiet', log_output=False)
        except:
            return True
        return False


# Geany plugin class ###################################################

class GitPlugin(geany.Plugin):

    __plugin_name__ = "Git Branches"
    __plugin_version__ = "1.2"
    __plugin_description__ = "Git branches plugin"
    __plugin_author__ = "Thimo Kraemer <thimo.kraemer@joonis.de>"

    def __init__(self):
        geany.Plugin.__init__(self)
        self._documents = {}
        self._git = None

        # Get menu bar
        tools_menu = geany.main_widgets.tools_menu
        tools_menuitem = tools_menu.get_attach_widget()
        menubar = tools_menuitem.get_parent()

        # Get VC menu
        for item in menubar:
            label = item.get_label().replace('_', '')
            if label == 'CV' or 'Control de versiones':
                vc_menu = item.get_submenu()
                break
        else:
            geany.dialogs.show_msgbox('VC plugin required!')
            return

        # Create fetch menu
        self._sep1 = create_menu_item(vc_menu, '-')
        self.fetch_item, fetch_menu = create_submenu(vc_menu, 'Fetch')
        create_menu_item(fetch_menu, 'All', self.on_git_fetch_all)
        create_menu_item(fetch_menu, '-')

        # Create branch menu
        self._sep2 = create_menu_item(vc_menu, '-')
        self.branch_item, branch_menu = create_submenu(vc_menu, 'Branches')
        create_menu_item(branch_menu, 'New branch', self.on_new_branch)
        self.delete_branch_item, m = create_submenu(branch_menu, 'Delete branch')
        create_menu_item(branch_menu, '-')

        # Create pull and push
        self._sep3 = create_menu_item(vc_menu, '-')
        self.pull_item, m = create_submenu(vc_menu, 'Pull')
        self.push_item, m = create_submenu(vc_menu, 'Push')

        # gitg / giggle
        self.gitg_item = None
        self.giggle_item = None
        self._sep4 = None
        try: subprocess.call(['gitg', '-V'])
        except OSError: has_gitg = False
        else: has_gitg = True
        try: subprocess.call(['giggle', '-v'])
        except OSError: has_giggle = False
        else: has_giggle = True
        if has_gitg or has_giggle:
            self._sep4 = create_menu_item(vc_menu, '-')
            if has_gitg:
                self.gitg_item = create_menu_item(vc_menu,
                                    'View with gitg', self.on_gitg)
            if has_giggle:
                self.giggle_item = create_menu_item(vc_menu,
                                    'View with giggle', self.on_giggle)

        # Create branch status label
        self.branch_label = gtk.Label()
        statusbar = geany.main_widgets.progressbar.get_parent()
        statusbar.pack_start(self.branch_label, expand=False, fill=True, padding=0)
        # Init widgets
        self.update_widgets()
        # Connect signals
        geany.signals.connect('document-activate', self.on_activate_document)
        geany.signals.connect('document-close', self.on_close_document)
        # Get informed about changes
        geany.signals.connect('document-save', self.on_save_document)
        geany.signals.connect('document-reload', self.on_save_document)
        # Required to realize a commit
        geany.main_widgets.window.connect('focus-in-event', self.on_focus_window)

    def cleanup(self):
        self._sep1.destroy()
        self._sep2.destroy()
        self._sep3.destroy()
        self.branch_item.destroy()
        self.fetch_item.destroy()
        self.pull_item.destroy()
        self.push_item.destroy()
        if self._sep4:
            self._sep4.destroy()
        if self.gitg_item:
            self.gitg_item.destroy()
        if self.giggle_item:
            self.giggle_item.destroy()
        self.branch_label.destroy()

    def on_activate_document(self, sigmanager, doc):
        if doc.real_path in self._documents:
            git = self._documents[doc.real_path]
        else:
            git = Git.git_from_path(doc.real_path)
            self._documents[doc.real_path] = git
        if git is not self._git:
            self._git = git
            self.update_widgets()

    def on_close_document(self, sigmanager, doc):
        if doc.real_path in self._documents:
            del self._documents[doc.real_path]

    def on_save_document(self, sigmanager, doc):
        if self._git:
            self.update_widgets()

    def on_focus_window(self, widget, event):
        if self._git:
            self.update_widgets()

    def on_gitg(self, menu_item):
        if self._git:
            subprocess.Popen(['gitg', self._git.path])

    def on_giggle(self, menu_item):
        if self._git:
            subprocess.Popen(['giggle', self._git.path])

    def on_git_checkout(self, menu_item):
        self._git.checkout(menu_item.get_label())
        self.update_widgets()

    def on_git_checkout_remote(self, menu_item):
        remote, branch = menu_item.get_label().split('/', 1)
        self._git.checkout(branch, remote)
        self.update_widgets()

    def on_git_fetch_all(self, menu_item):
        self._git.fetch()
        self.update_widgets()

    def on_git_fetch(self, menu_item):
        self._git.fetch(menu_item.get_label())
        self.update_widgets()

    def on_git_pull(self, menu_item):
        remote, branch = menu_item.get_label().split('/', 1)
        self._git.pull(remote, branch)
        self.update_widgets()

    def on_git_push(self, menu_item):
        remote, branch = menu_item.get_label().split('/', 1)
        self._git.push(remote, branch)

    def on_new_branch(self, menu_item):
        name = geany.dialogs.show_input('Enter branch name')
        if not name:
            return
        self._git.create_branch(name)
        self.update_widgets()

    def on_delete_branch(self, menu_item):
        branch = menu_item.get_label()
        text = 'Do you really want to delete branch\n%s?' % branch
        if not geany.dialogs.show_question(text):
            return
        self._git.delete_branch(branch)
        self.update_widgets()

    def update_widgets(self):
        active = None
        git = self._git
        if git:
            if not git.active_branch:
                git.get_branches()
            active = git.active_branch

        if active:
            # Remove all branch items
            branch_menu = self.branch_item.get_submenu()
            remove_menu_items(branch_menu, 3)
            delete_branch_menu = self.delete_branch_item.get_submenu()
            remove_menu_items(delete_branch_menu)
            # Add branch items
            for branch in git.local_branches:
                create_menu_item(branch_menu, branch,
                    self.on_git_checkout, branch == active)
                if branch != active:
                    create_menu_item(delete_branch_menu,
                            branch, self.on_delete_branch)
            if git.remote_branches:
                create_menu_item(branch_menu, '-')
                for branch in git.remote_branches:
                    create_menu_item(branch_menu, branch,
                        self.on_git_checkout_remote, False)
            # Remove remote items
            pull_menu = self.pull_item.get_submenu()
            remove_menu_items(pull_menu)
            push_menu = self.push_item.get_submenu()
            remove_menu_items(push_menu)
            fetch_menu = self.fetch_item.get_submenu()
            remove_menu_items(fetch_menu, 2)
            # Add new remote items
            for remote in git.remotes:
                create_menu_item(pull_menu,
                    '%s/%s' % (remote, active),
                    self.on_git_pull)
                create_menu_item(push_menu,
                    '%s/%s' % (remote, active),
                    self.on_git_push)
                create_menu_item(fetch_menu,
                    remote, self.on_git_fetch)

            self.delete_branch_item.set_sensitive(
                        bool(len(delete_branch_menu)))

            if git.has_changes():
                color = '#FFA500'
            else:
                color = '#90EE90'
            text = '<span background="%s"> %s </span>' % (color, active)
        else:
            text = ' <i>unknown</i> '

        self.branch_label.set_markup('Git branch: ' + text)
        enabled = bool(active)
        if self.gitg_item:
            self.gitg_item.set_sensitive(enabled)
        if self.giggle_item:
            self.giggle_item.set_sensitive(enabled)
        self.branch_label.set_visible(bool(enabled or git))
        self.branch_item.set_sensitive(enabled)
        if not len(self.pull_item.get_submenu()):
            enabled = False
        self.pull_item.set_sensitive(enabled)
        self.push_item.set_sensitive(enabled)
        self.fetch_item.set_sensitive(enabled)
