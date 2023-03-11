extends Window


var c: ConfigFile

const langs = ["en", "cs"]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	c = ConfigFile.new()
	var err: int = c.load("user://famtree.cfg")
	if err:
		c.set_value("FamTree", "locale", "en")
		c.set_value("FamTree", "save_dir", "")
		c.set_value("FamTree", "export_line_thickness", 5)
		c.set_value("FamTree", "inkscape_path", "")
	
	%Lang.selected = langs.find(c.get_value("FamTree", "locale", "en"))
	%SaveDir.text = c.get_value("FamTree", "save_dir", "")
	%LineThickness.value = c.get_value("FamTree", "export_line_thickness", 5)
	%InkscapePath.text = c.get_value("FamTree", "inkscape_path", "")


func _on_confirm_button_pressed() -> void:
	Globals.set_locale(langs[%Lang.selected])
	Globals.default_save_dir = %SaveDir.text
	Globals.export_line_thickness = %LineThickness.value
	Globals.inkscape_path = %InkscapePath.text
	
	if %SaveDir.text.is_empty() or not DirAccess.dir_exists_absolute(%SaveDir.text):
		%SaveDir.text = ""
	c.set_value("FamTree", "locale", langs[%Lang.selected])
	c.set_value("FamTree", "save_dir", %SaveDir.text)
	c.set_value("FamTree", "export_line_thickness", %LineThickness.value)
	c.set_value("FamTree", "inkscape_path", %InkscapePath.text)
	c.save("user://famtree.cfg")


func _on_close_requested() -> void:
	queue_free()


func _on_zamzar_pressed() -> void:
	OS.shell_open("https://www.zamzar.com/convert/svg-to-pdf/")
