extends MenuBar


@onready var file: PopupMenu = $"$FILE"
@onready var settigns: PopupMenu = $"$SETTINGS"
@onready var help: PopupMenu = $"$HELP"

enum FileTabs {
	NEW,
	OPEN,
	SAVE,
	SAVE_AS,
	SAVE_ALL,
	UNDO,
	REDO,
	CLOSE,
	QUIT,
}

enum SettingsTabs {
	SETTINGS,
}

enum HelpTabs {
	HELP,
	LICENSE,
	SUPPORT,
}


func _ready() -> void:
	file.set_item_shortcut(0, BlackBoard.shortcuts["new"])
	file.set_item_shortcut(1, BlackBoard.shortcuts["open"])
	file.set_item_shortcut(3, BlackBoard.shortcuts["save"])
	file.set_item_shortcut(4, BlackBoard.shortcuts["save_as"])
	file.set_item_shortcut(5, BlackBoard.shortcuts["save_all"])
	file.set_item_shortcut(7, BlackBoard.shortcuts["undo"])
	file.set_item_shortcut(8, BlackBoard.shortcuts["redo"])
	file.set_item_shortcut(10, BlackBoard.shortcuts["close"])
	file.set_item_shortcut(12, BlackBoard.shortcuts["quit"])
	
	settigns.set_item_shortcut(0, BlackBoard.shortcuts["settings"])
	
	help.set_item_shortcut(0, BlackBoard.shortcuts["help"])


func _on_file_id_pressed(id: int) -> void:
	pass # Replace with function body.


func _on_settings_id_pressed(id: int) -> void:
	pass # Replace with function body.


func _on_help_id_pressed(id: int) -> void:
	match id:
		HelpTabs.HELP:
			OS.shell_open("https://www.youtube.com/watch?v=dQw4w9WgXcQ")
		HelpTabs.LICENSE:
			pass
		HelpTabs.SUPPORT:
			pass
