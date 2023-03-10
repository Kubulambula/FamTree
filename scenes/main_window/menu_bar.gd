extends MenuBar


@onready var file: PopupMenu = $"$FILE"
@onready var settigns: PopupMenu = $"$SETTINGS"
@onready var help: PopupMenu = $"$HELP"

enum FileTabs {
	NEW,
	OPEN,
	SAVE,
	SAVE_AS,
	EXPORT,
#	SAVE_ALL,
	UNDO,
	REDO,
#	CLOSE,
	QUIT,
}

enum SettingsTabs {
	SETTINGS,
}

enum HelpTabs {
	HELP,
	REPO,
	LICENSE,
	SUPPORT,
}


func _ready() -> void:
	for popup_menu in get_children():
		popup_menu.transient = true
		popup_menu.transparent = true
		popup_menu.transparent_bg = true
	
	file.set_item_shortcut(0, Globals.shortcuts["new"])
	file.set_item_shortcut(1, Globals.shortcuts["open"])
	file.set_item_shortcut(3, Globals.shortcuts["save"])
	file.set_item_shortcut(4, Globals.shortcuts["save_as"])
	file.set_item_shortcut(6, Globals.shortcuts["export"])
#	file.set_item_shortcut(5, Globals.shortcuts["save_all"])
	file.set_item_shortcut(8, Globals.shortcuts["undo"])
	file.set_item_shortcut(9, Globals.shortcuts["redo"])
#	file.set_item_shortcut(10, Globals.shortcuts["close"])
	file.set_item_shortcut(11, Globals.shortcuts["quit"])
	
	settigns.set_item_shortcut(0, Globals.shortcuts["settings"])
	
	help.set_item_shortcut(0, Globals.shortcuts["help"])


func _on_file_id_pressed(id: int) -> void:
	match id:
		FileTabs.NEW:
			Globals.new_plt()
		FileTabs.OPEN:
			Globals.open_plt()
		FileTabs.SAVE:
			Globals.save_plt()
		FileTabs.SAVE_AS:
			Globals.save_as_plt()
		FileTabs.EXPORT:
			Globals.export_as()
#		FileTabs.SAVE_ALL:
#			pass
		FileTabs.UNDO:
			pass
		FileTabs.REDO:
			pass
#		FileTabs.CLOSE:
#			pass
		FileTabs.QUIT:
			Globals.request_quit()


func _on_settings_id_pressed(id: int) -> void:
	match id:
		SettingsTabs.SETTINGS:
			add_child(preload("res://scenes/main_window/popup_windows/settings.tscn").instantiate())


func _on_help_id_pressed(id: int) -> void:
	match id:
		HelpTabs.HELP:
			OS.shell_open("https://github.com/Kubulambula/FamTree/issues")
		HelpTabs.REPO:
			OS.shell_open("https://github.com/Kubulambula/FamTree")
		HelpTabs.LICENSE:
			var license_popup = load("res://scenes/main_window/popup_windows/license.tscn").instantiate()
#			license_popup.theme = Globals.theme
			add_child(license_popup)
		HelpTabs.SUPPORT:
			pass
