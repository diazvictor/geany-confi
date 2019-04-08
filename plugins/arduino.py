import geany
import gtk, glib
import os, sys, re
import serial
import serial.tools.list_ports
from datetime import datetime
from ConfigParser import ConfigParser

#geanypy api reference : http://geanypy.readthedocs.org/en/latest/api.html

class Arduino(geany.Plugin):

    __plugin_name__ = "Arduino IDE"
    __plugin_version__ = "dev"
    __plugin_description__ = "Select board, insert library, compile and upload code to Arduino and combatible board."
    __plugin_author__ = "Jonas Fourquier (jonas@mythtv-fr.org)"

    conf_path = os.path.join(geany.app.configdir, "plugins","arduino.conf")


    def __init__(self):

        geany.Plugin.__init__(self)

        #usually arduino dirs
        if sys.platform.startswith('linux') or sys.platform.startswith('cygwin') :
            self.arduino_dirs = [
                '/usr/local/share/arduino',
                '/usr/share/arduino',
                os.path.join(os.environ['HOME'],'Arduino'),
                os.path.join(os.environ['HOME'],'.arduino'),
                os.path.join(os.environ['HOME'],'.arduino15'),
              ]
            self.packages_dirs = [
                os.path.join(os.environ['HOME'],'.arduino','packages'),
                os.path.join(os.environ['HOME'],'.arduino15','packages')
              ]
        elif sys.platform.startswith('win') :
            self.arduino_dirs = [] #TODO ticket#1
            self.packages_dirs = [] #TODO ticket#1
        elif sys.platform.startswith('darwin') :
            self.arduino_dirs = [] #TODO ticket#2
            self.packages_dirs = [] #TODO ticket#2
        else : #unknom OS
            self.arduino_dirs = []
            self.packages_dirs = []

        #arduino in config file
        if not os.path.isfile(self.conf_path) :
            with open(self.conf_path, 'wb') as configfile:
                configfile.write("[arduino]\n#libraries and boards paths search\ndirs =\n#package paths search\npackages_dirs =\n")
        config = ConfigParser()
        config.read(self.conf_path)
        #~ if not config.has_section('arduino') :
            #~ config.add_section('arduino')
            #~ config.set('arduino','dirs','#tata')
            #~ config.set('arduino','packages_dirs','')
            #~ with open(self.conf_path, 'wb') as configfile:
                #~ config.write(configfile)
        self.arduino_dirs.extend((config.get('arduino','dirs') or '').split(','))
        self.packages_dirs.extend((config.get('arduino','packages_dirs') or '').split(','))

        #arduino dirs by ENV (replace usually dirs)
        if os.environ.has_key('GEANY_ARDUINO_DIRS') :
            self.arduino_dirs.extend(os.environ['GEANY_ARDUINO_DIRS'].split(','))
        if os.environ.has_key('GEANY_ARDUINO_PACKAGES_DIRS') :
            self.packages_dirs.extend(os.environ['GEANY_ARDUINO_PACKAGES_DIRS'].split(','))

        self.file_prefs = None #arduino preferences filename
        self.store_customs_prefs = None
        self.signal_id_document_save = None

        #main menu
        self.arduino_menu = gtk.Menu()
        self.arduino_menu_item = gtk.MenuItem("Arduino")
        self.arduino_menu_item.set_submenu(self.arduino_menu)
        self.arduino_menu_item.connect("activate",self.on_arduino_menu_item_clicked)
        geany.main_widgets.tools_menu.append(self.arduino_menu_item)

        #board menu
        self.boards_menu = gtk.Menu()
        boards_menu_item = gtk.MenuItem("Boards")
        boards_menu_item.set_submenu(self.boards_menu)
        self.arduino_menu.append(boards_menu_item)
        boards_menu_item.show()

        #cutoms prefs menu
        self.customs_prefs_menu_item = gtk.MenuItem("Bord preferences ...")
        self.customs_prefs_menu_item.connect("activate",self.on_customs_prefs_menu_item_clicked)
        self.arduino_menu.append(self.customs_prefs_menu_item)
        self.customs_prefs_menu_item.show()

        #separator
        separator = gtk.SeparatorMenuItem()
        self.arduino_menu.append(separator)
        separator.show()

        #port menu
        self.ports_menu = gtk.Menu()
        ports_menu_item = gtk.MenuItem("Port")
        ports_menu_item.set_submenu(self.ports_menu)
        ports_menu_item.connect("activate",self.on_ports_menu_item_clicked)
        self.arduino_menu.append(ports_menu_item)
        ports_menu_item.show()

        #separator
        separator = gtk.SeparatorMenuItem()
        self.arduino_menu.append(separator)
        separator.show()

        #programmer menu
        self.programmers_menu = gtk.Menu()
        programmers_menu_item = gtk.MenuItem("Programmers")
        programmers_menu_item.set_submenu(self.programmers_menu)
        self.arduino_menu.append(programmers_menu_item)
        programmers_menu_item.show()

        #separator
        separator = gtk.SeparatorMenuItem()
        self.arduino_menu.append(separator)
        separator.show()

        #libraries menu
        libraries_menu_item = gtk.MenuItem("Include libraries ...")
        libraries_menu_item.connect("activate",self.on_libraries_item_clicked)
        self.arduino_menu.append(libraries_menu_item)
        libraries_menu_item.show()

        #separator
        separator = gtk.SeparatorMenuItem()
        self.arduino_menu.append(separator)
        separator.show()

        #open preferences.txt
        open_prefs_txt_menu_item = gtk.MenuItem("Open preference.txt")
        open_prefs_txt_menu_item.connect("activate",self.on_open_prefs_txt_menu_item_clicked)
        self.arduino_menu.append(open_prefs_txt_menu_item)
        open_prefs_txt_menu_item.show()

        #events
        geany.signals.connect('document-activate', self.on_document_activate)


    def cleanup(self):

        self.arduino_menu_item.destroy()


    ## Functions

    def _construct_menu(self) :
        '''
        Construct menu by walking dirs.
        '''

        #drop boards and programmers menus
        for child in self.boards_menu.get_children() :
            for sub_child in child.get_children() :
                child.remove(sub_child)
                sub_child.destroy()
            self.boards_menu.remove(child)
            child.destroy()
        for child in self.programmers_menu.get_children() :
            self.boards_menu.remove(child)
            child.destroy()

        #get olders prefs
        cur_board = self.get_pref('board')
        cur_programmer = self.get_pref('programmer')

        cur_fname_boards = None
        boards = []
        programmers = []

        #boards and programmers in aurduino dirs
        for arduino_dirs in self.arduino_dirs :
            if os.path.isdir(os.path.join(arduino_dirs,'hardware')) :
                for package in os.listdir(os.path.join(arduino_dirs,'hardware')) :
                    if os.path.isdir(os.path.join(arduino_dirs,'hardware',package)) :
                        for arch in os.listdir(os.path.join(arduino_dirs,'hardware',package)) :
                            fname_platform = os.path.join(arduino_dirs,'hardware',package,arch,'platform.txt')
                            if os.path.isfile(fname_platform) :
                                with open(fname_platform,'r') as f :
                                    packageName = re.findall('^name=(.*)$',f.read(),re.M)[0]

                            fname_boards = os.path.join(arduino_dirs,'hardware',package,arch,'boards.txt')
                            if os.path.isfile(fname_boards) :
                                with open(fname_boards,'r') as f_boards :
                                    for (board,boardName) in re.findall('^(.*)\.name=(.*)$',f_boards.read(),re.M) :
                                        boards.append((packageName, boardName, (fname_boards,package,arch,board)))

                            fname_programmers = os.path.join(arduino_dirs,'hardware',package,arch,'programmers.txt')
                            if os.path.isfile(fname_programmers) :
                                with open(fname_programmers,'r') as f_programmers :
                                    for (programmer,programmerName) in re.findall('^(.*)\.name=(.*)$',f_programmers.read(),re.M) :
                                        programmers.append((programmerName, (fname_programmers,package,arch,programmer)))

        #boards and programmers in packages dir
        for packages_dir in self.packages_dirs :
            if os.path.isdir(packages_dir) :
                for package in os.listdir(packages_dir) :
                    if os.path.isdir(os.path.join(packages_dir,package,'hardware')) :
                        for arch in os.listdir(os.path.join(packages_dir,package,'hardware')) :
                            for version in os.listdir(os.path.join(packages_dir,package,'hardware',arch)) :
                                fname_platform = os.path.join(packages_dir,package,'hardware',arch,version,'platform.txt')
                                if os.path.isfile(fname_platform) :
                                    with open(fname_platform,'r') as f :
                                        packageName = re.findall('^name=(.*)$',f.read(),re.M)[0]

                                fname_boards = os.path.join(packages_dir,package,'hardware',arch,version,'boards.txt')
                                if os.path.isfile(fname_boards) :
                                    with open(fname_boards,'r') as f_boards :
                                        for (board,boardName) in re.findall('^(.*)\.name=(.*)$',f_boards.read(),re.M) :
                                            boards.append((packageName, boardName, (fname_boards,package,arch,board)))

                                fname_programmers = os.path.join(packages_dir,package,'hardware',arch,version,'programmers.txt')
                                if os.path.isfile(fname_programmers) :
                                    with open(fname_programmers,'r') as f_programmers :
                                        for (programmer,programmerName) in re.findall('^(.*)\.name=(.*)$',f_programmers.read(),re.M) :
                                            programmers.append((programmerName, (fname_programmers,package,arch,programmer)))

        #sort
        boards.sort()
        programmers.sort()

        #construct boards menu
        groupBoard = ''
        board_menu_item = None
        package_menu_item = None
        for (packageName, boardName, data) in boards :
            if groupBoard != packageName :
                groupBoard = packageName
                package_menu = gtk.Menu()
                package_menu_item = gtk.RadioMenuItem(package_menu_item, packageName)
                package_menu_item.set_submenu(package_menu)
                self.boards_menu.append(package_menu_item)
                package_menu_item.show()

            board_menu_item = gtk.RadioMenuItem(board_menu_item,boardName)
            if cur_board == data[3] : #radiobutton on current
                board_menu_item.set_active(True)
                package_menu_item.set_active(True)
                (cur_fname_boards,package,arch,board) = data

            package_menu.append(board_menu_item)
            board_menu_item.show()
            board_menu_item.connect("activate", self.on_board_menu_item_clicked, data)

        #construct programmers menu
        programmer_menu_item = None
        for (programmerName, data) in programmers :
            (fname_programmers,package,arch,programmer) = data
            programmer_menu_item = gtk.RadioMenuItem(programmer_menu_item,programmerName)
            if cur_programmer == "%s:%s"%(package,programmer) : #radiobutton on current
                programmer_menu_item.set_active(True)

            self.programmers_menu.append(programmer_menu_item)
            programmer_menu_item.show()
            programmer_menu_item.connect("activate", self.on_programmer_menu_item_clicked, programmer)

        return (cur_board, cur_fname_boards)


    def _construct_customs_prefs_store(self, board, fname_boards) :
        '''
        Construct store board prefs.
        '''

        self.store_customs_prefs = gtk.ListStore(str, str, str, object) #(0: key_label, 1: key, 2:cur_value_label, 3:store_value)

        # file pref unexist
        if not board or not fname_boards :
            return False

        with open(fname_boards,'r') as f :
            boards = f.read()

        for (key,key_label) in re.findall('^menu\.(.*)=(.*)$',boards,re.M) :
            cur_value = self.get_pref("custom_%s"%key) #in preference.txt keys "custom" have a prefix "custom_"
            store_value = gtk.ListStore(str, str) #label, value
            cur_value_label = ''
            for (value,value_label) in re.findall('^%s\.menu\.%s\.(\w*)=(.*)$'%(board,key),boards,re.M) :
                value = "%s_%s"%(board,value) #in preference.txt values "custom" have a prefix "<board>_"
                store_value.append((value_label,value))
                if cur_value == value :
                    cur_value_label = value_label

            # append pref only if mmultiple value available
            if len(store_value) > 1 :
                self.store_customs_prefs.append((key_label, "custom_%s"%key, cur_value_label, store_value))

        return True


    def _construct_libraries_store(self) :
        '''
        Construct store libraries.
        '''

        self.store_libraries = gtk.ListStore(object, str) # 0: libs, 1:markup

        for arduino_dir in self.arduino_dirs :
            if os.path.isdir(os.path.join(arduino_dir,'libraries')) :
                for library in os.listdir(os.path.join(arduino_dir,'libraries')) :
                    fname_library = os.path.join(arduino_dir,'libraries',library,'library.properties')
                    if os.path.isfile(fname_library) :
                        with open(fname_library,'r') as f :
                            f_library_read = f.read()
                        markup = '<b>%s</b><small>'%glib.markup_escape_text(re.findall('^name=(.*)$',f_library_read,re.M)[0].strip())
                        for author in re.findall('^author=(.*)$',f_library_read,re.M) :
                            markup += ' by %s'%glib.markup_escape_text(author.strip())
                        for version in re.findall('^version=(.*)$',f_library_read,re.M) :
                            markup += ' version %s'%glib.markup_escape_text(version.strip())
                        for sentence in re.findall('^sentence=(.*)$',f_library_read,re.M) :
                            markup += "\nsentence %s"%glib.markup_escape_text(sentence.strip())
                        for url in re.findall('^url=(.*)$',f_library_read,re.M) :
                            markup += "\nMore infos: %s"%glib.markup_escape_text(url.strip())
                        markup += "</small>"
                    else :
                        markup = '<b>%s</b>'%glib.markup_escape_text(library)

                    libs = []
                    if os.path.isdir(os.path.join(arduino_dir,'libraries',library)) :
                        for lib in os.listdir(os.path.join(arduino_dir,'libraries',library)) :
                            if os.path.splitext(lib)[1] == ".h" :
                                libs.append(lib)
                    if os.path.isdir(os.path.join(arduino_dir,'libraries',library,'src')) :
                        for lib in os.listdir(os.path.join(arduino_dir,'libraries',library,'src')) :
                            if os.path.splitext(lib)[1] == ".h" :
                                libs.append(lib)

                    if libs :
                        self.store_libraries.append((libs,markup))

    def _get_serial_ports (self) :
        '''
        list ports return a list of tuple (name, descripition, sort)
        '''

        return serial.tools.list_ports.comports()


    def get_pref(self,key) :
        '''
        get preference for <key>.
        '''

        if os.path.isfile(self.file_prefs) :
            with open(self.file_prefs,'r') as f :
                for line in f.readlines() :
                    if line.find('%s='%key) == 0 :
                        return line[line.find('=')+1:].strip()
        return None


    def set_pref(self,key,value) :
        '''
        Set preference <key> to <value>. If <key> don't exist create it.
        '''

        update = False
        prefs = []

        if os.path.isfile(self.file_prefs) :
            with open(self.file_prefs,'r') as f :
                for line in f.readlines() :
                    if line.find('%s='%key) == 0 :
                        prefs.append("%s=%s"%(key,value))
                        update = True
                    else :
                        prefs.append(line.strip())

        if not update :
            prefs.append('%s=%s'%(key,value))
            prefs.sort()

        with open(self.file_prefs,'w') as f :
            f.write("\n".join(prefs))


    ## on signals

    def on_arduino_menu_item_clicked(self,menu_item):

        (cur_board, cur_fname_boards) = self._construct_menu()
        self._construct_customs_prefs_store(cur_board, cur_fname_boards)


    def on_board_menu_item_clicked(self, widget, data) :

        if widget.get_active() :
            (fname_boards,package,arch,board) = data
            self.set_pref('board',board)
            self.set_pref('target_package',package)
            self.set_pref('target_platform',arch)
            self._construct_customs_prefs_store(board, fname_boards)
            if (len (self.store_customs_prefs)) :
                self.customs_prefs_menu_item.set_sensitive(True)
                self.board_custom_prefs_dialog()
            else :
                self.customs_prefs_menu_item.set_sensitive(False)


    def on_customs_prefs_menu_item_clicked(self, widget) :
         self.board_custom_prefs_dialog()


    def on_document_activate(self,signal,document):
        print 'on_document_activate'

        if (geany.document.get_current().file_type.extension == 'ino') :
            self.file_prefs = self._get_file_name_prefs(document.file_name)
            port = self.get_pref('serial.port')
            if port :
                os.environ['GEANY_ARDUINO_PORT'] = port
            self.arduino_menu_item.show()
            self.signal_id_document_save = geany.signals.connect('document-save', self.on_document_save)
        else :
            self.file_prefs = None
            self.arduino_menu_item.hide()
            if (self.signal_id_document_save) :
                geany.signals.disconnect(self.signal_id_document_save)


    def on_document_save(self,signal,document):
        '''
        On document save if an arduino preferences file exist rename it.
        '''
        old_file_prefs = self.file_prefs
        self.file_prefs = self._get_file_name_prefs(document.file_name)
        if (self.file_prefs != old_file_prefs) and os.path.isfile(old_file_prefs) :
            if os.path.isfile(self.file_prefs) :
                file_prefs_bak = self.file_prefs+".bak"+datetime.strftime(datetime.now(),"%Y%m%d%H%M%S")
                os.rename(self.file_prefs,file_prefs_bak)
                geany.dialogs.show_msgbox("An old preference file was found. In %s saved"%file_prefs_bak)
            os.rename(old_file_prefs, self.file_prefs)


    def on_libraries_item_clicked(self,widget) :

        self._construct_libraries_store()
        self.libraries_dialog();


    def on_open_prefs_txt_menu_item_clicked(self,menu_item) :

        geany.document.open_file(self.file_prefs)


    def on_port_menu_item_clicked(self, menu_item, port) :

        self.set_pref('serial.port',port)
        os.environ['GEANY_ARDUINO_PORT'] = port


    def on_ports_menu_item_clicked(self, menu_item) :

        cur_port = self.get_pref('serial.port')

        # drop
        for child in self.ports_menu.get_children() :
            self.ports_menu.remove(child)
            child.destroy()

        port_menu_item = None
        for (name, description, sort) in self._get_serial_ports() :
            port_menu_item = gtk.RadioMenuItem(port_menu_item,"%s - %s"%(name, description))
            if cur_port == name : #radiobutton on current port
                port_menu_item.set_active(True)
            self.ports_menu.append(port_menu_item)
            port_menu_item.show()
            port_menu_item.connect("activate",self.on_port_menu_item_clicked, name)


    def on_programmer_menu_item_clicked(self, widget, programmer) :

        self.set_pref('programmer',programmer)


    ### Dialogs

    def board_custom_prefs_dialog (self) :
        '''
        Display board pref dialog.
        '''

        def combo_value(treeviewcolumn, cell, model, iter):
            cell.set_property('text', model.get_value(iter, 2))
            cell.set_property('model', model.get_value(iter, 3))
            return

        def on_combo_value_changed (combo, path, iter):
            combo_store = self.store_customs_prefs[path][3]
            self.set_pref(self.store_customs_prefs[path][1], combo_store.get_value(iter, 1))
            self.store_customs_prefs[path][2] = combo_store.get_value(iter, 0)

        def on_reponse_event(dialog, reponse) :
            dialog.destroy()

        dialog = gtk.Dialog('Arduino customs preferences', buttons=(gtk.STOCK_CLOSE,gtk.RESPONSE_CLOSE))
        dialog.connect('response', on_reponse_event)
        dialog.set_default_size(400, 400)

        scroll = gtk.ScrolledWindow()

        view =  gtk.TreeView(self.store_customs_prefs)

        key_column = gtk.TreeViewColumn('Key')
        view.append_column(key_column)
        key_render = gtk.CellRendererText()
        key_column.pack_start(key_render, True)
        key_column.add_attribute(key_render, 'text', 0)

        value_render = gtk.CellRendererCombo()
        value_render.set_property("editable", True)
        value_render.set_property("text-column", 0)
        value_render.set_property("has-entry", False)
        value_render.connect("changed", on_combo_value_changed)
        value_column = gtk.TreeViewColumn('Value',value_render,text=2)
        value_column.set_cell_data_func(value_render, combo_value)
        view.append_column(value_column)

        scroll.add(view)
        vbox = dialog.get_content_area()
        vbox.pack_start(scroll)

        dialog.show_all()


    def libraries_dialog (self) :
        '''
        Display libraries dialog.
        '''

        def on_reponse_event(dialog, reponse) :
            dialog.destroy()

        def on_row_activated(treeview, path, view_column) :
            libs = modelfilter[path][0]
            text_block = ''
            for lib in libs :
                text_block += "#include <%s>\n"%lib
            geany.document.get_current().editor.insert_text_block(text_block,0)

        def filter_func(model, iter) :
            entry = filter_entry.get_text().lower()
            if not entry or model.get_value(iter, 1).lower().find(entry) != -1 :
                return True
            return False

        def on_filter_entry_changed(entry) :
            modelfilter.refilter()

        def on_filter_entry_icon_release(entry, icon_pos, event) :
            if icon_pos == gtk.POS_RIGHT :
                entry.set_text('')

        dialog = gtk.Dialog('Arduino libraries', buttons=(gtk.STOCK_CLOSE,gtk.RESPONSE_CLOSE))
        dialog.connect('response', on_reponse_event)
        dialog.set_default_size(400, 400)

        label = gtk.Label('Double click to insert')
        label.set_alignment(0, .5)

        filter_entry = gtk.Entry()
        filter_entry.set_icon_from_icon_name(gtk.POS_LEFT,'edit-find')
        filter_entry.set_icon_from_icon_name(gtk.POS_RIGHT,'edit-clear')
        filter_entry.connect('changed', on_filter_entry_changed)
        filter_entry.connect('icon-release', on_filter_entry_icon_release)

        scroll = gtk.ScrolledWindow()

        modelfilter = self.store_libraries.filter_new()
        modelfilter.set_visible_func(filter_func)

        view =  gtk.TreeView(modelfilter)
        view.set_headers_visible(False)
        view.connect('row-activated',on_row_activated)
        view.set_property('enable-grid-lines', True)

        column = gtk.TreeViewColumn()
        view.append_column(column)
        render = gtk.CellRendererText()
        column.pack_start(render, True)
        column.add_attribute(render, 'markup', 1)

        scroll.add(view)
        vbox = dialog.get_content_area()
        vbox.pack_start(label,False)
        vbox.pack_start(filter_entry,False)
        vbox.pack_start(scroll)

        dialog.show_all()


    def _get_file_name_prefs(self, file_name) :
        '''
        return arduino file preferences for an ino file
        '''
        (path,filename) = os.path.split(geany.document.get_current().file_name)
        return os.path.join(path,'.geany.%s.preferences.txt'%filename)
