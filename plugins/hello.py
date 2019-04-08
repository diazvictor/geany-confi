import gtk
import geany

class HelloWorld(geany.Plugin):

    __plugin_name__ = "HelloWorld StatusBar"
    __plugin_version__ = "1.0"
    __plugin_description__ = "Just another tool to say hello world"
    __plugin_author__ = "Díaz Urbaneja Víctor Eduardo Diex <diaz.victor@openmailbox.org>"

    def __init__(self):
        self.branch_label = gtk.Label()
        statusbar = geany.main_widgets.progressbar.get_parent()
        statusbar.pack_start(self.branch_label, expand=False, fill=True, padding=0)
        self.branch_label.set_markup('Git branch')
