extends Node2D

var _quit_confirmation: ConfirmationDialog = null
var _quit_blockers: Array[Object] = []
var _awaiting_quit: bool = false
signal e_quit

var locale: String = TranslationServer.get_locale()
signal e_locale_changed(new_locale: String)

var active_camera: Camera2D = null

var savable: Node = null
var lin_tree_work_area: Node = null

var last_lintree_save_file: String = ""

var _new_confirmation: ConfirmationDialog = null

var notification_layer: Notify = preload("res://scenes/main_window/popup_windows/notification_layer.tscn").instantiate()

var default_save_dir: String = ""
var export_line_thickness: int = 0

var inkscape_path: String = ""


func notify(text: String, icon: Notify.Icon = Notify.Icon.NONE, duration: float = 2.0) -> void:
	notification_layer.notify(text, icon, duration)


func _ready():
	var c: ConfigFile = ConfigFile.new()
	var err: int = c.load("user://famtree.cfg")
	if err:
		c.set_value("FamTree", "locale", "en")
		c.set_value("FamTree", "save_dir", "")
		c.set_value("FamTree", "export_line_thickness", 5)
		c.set_value("FamTree", "inkscape_path", "")
	
	set_locale(c.get_value("FamTree", "locale", "en"))
	default_save_dir = c.get_value("FamTree", "save_dir", "")
	export_line_thickness = c.get_value("FamTree", "export_line_thickness", 5)
	inkscape_path = c.get_value("FamTree", "inkscape_path", "")
	c.save("user://famtree.cfg")
	
	
	
	add_child(notification_layer)
	_quit_confirmation = load("res://scenes/main_window/popup_windows/quit_confirmation.tscn").instantiate()
	_quit_confirmation.confirmed.connect(_quit_confirmed)
	_quit_confirmation.canceled.connect(func(): _awaiting_quit = false)
	add_child(_quit_confirmation)
	
	_new_confirmation = load("res://scenes/main_window/popup_windows/new_confirmation.tscn").instantiate()
	_new_confirmation.confirmed.connect(_on_new_plt_confirmed)
	add_child(_new_confirmation)


func request_quit() -> void:
	if _awaiting_quit:
		return
	_awaiting_quit = true
	_quit_confirmation.popup_centered(Vector2i(475, 100))


func _quit_confirmed() -> void:
	e_quit.emit()
	await get_tree().create_timer(0.25).timeout # wait fot quit blockers
	if _quit_blockers.size() == 0:
		get_tree().quit()


func quit_block_request(blocker: Object) -> void:
	if blocker in _quit_blockers or _awaiting_quit == false:
		return
	_quit_blockers.append(blocker)


func quit_block_release(blocker: Object) -> void:
	_quit_blockers.erase(blocker)
	if _quit_blockers.size() == 0:
		get_tree().quit()


var shortcuts: Dictionary = {
	"close": preload("res://app/shortcuts/close.tres"),
	"help": preload("res://app/shortcuts/help.tres"),
	"new": preload("res://app/shortcuts/new.tres"),
	"open": preload("res://app/shortcuts/open.tres"),
	"quit": preload("res://app/shortcuts/quit.tres"),
	"redo": preload("res://app/shortcuts/redo.tres"),
	"save": preload("res://app/shortcuts/save.tres"),
	"save_all": preload("res://app/shortcuts/save_all.tres"),
	"save_as": preload("res://app/shortcuts/save_as.tres"),
	"export": preload("res://app/shortcuts/export_as.tres"),
	"settings": preload("res://app/shortcuts/settings.tres"),
	"undo": preload("res://app/shortcuts/undo.tres"),
}


func set_locale(new_locale: String) -> bool:
	if not new_locale in TranslationServer.get_loaded_locales():
		return false
	TranslationServer.set_locale(new_locale)
	Globals.e_locale_changed.emit(new_locale)
	return true


func _input(event: InputEvent):
	if event is InputEventKey and OS.is_debug_build():
		if Input.is_action_just_pressed("ui_page_down"):
			print("Set locale 'cs': ", set_locale("cs"))
		elif Input.is_action_just_pressed("ui_page_up"):
			print("Set locale 'en': ", set_locale("en"))
		elif Input.is_action_just_pressed("ui_home"):
			print("Set locale 'aa': ", set_locale("aa"))


func save_plt() -> void:
	var err_str: String = ""
	if last_lintree_save_file.is_empty():
		save_as_plt()
		return
	
	if not savable:
		err_str = "$ERR_NO_SAVABLE"
		push_error(err_str)
		Globals.notify(tr(err_str), Notify.Icon.ERR)
		return
	
	var packed_savable: PackedScene = PackedScene.new()
	var err: int = packed_savable.pack(savable)
	if err:
		err_str = "$ERR_WHILE_PACKING"
		push_error(err_str + (" (%s)" % error_string(err)))
		Globals.notify(tr(err_str) + (" (%s)" % error_string(err)), Notify.Icon.ERR)
		return
	err = ResourceSaver.save(packed_savable, last_lintree_save_file)
	if err:
		err_str = "$ERR_WHILE_SAVING"
		push_error(err_str + (" (%s)" % error_string(err)))
		Globals.notify(tr(err_str) + (" (%s)" % error_string(err)), Notify.Icon.ERR)
		return
	err_str = "$SUCCESS_SAVED_TO"
	print(err_str + (": %s" % last_lintree_save_file.get_file()))
	Globals.notify(tr(err_str) + (": %s" % last_lintree_save_file.get_file()), Notify.Icon.OK)


func save_as_plt() -> void:
	var err_str: String = ""
	if not savable:
		err_str = "$ERR_NO_SAVABLE"
		push_error(err_str)
		Globals.notify(tr(err_str), Notify.Icon.ERR)
		return
	
	var packed_savable: PackedScene = PackedScene.new()
	var err: int = packed_savable.pack(savable)
	if err:
		err_str = "$ERR_WHILE_PACKING"
		push_error(err_str + (" (%s)" % error_string(err)))
		Globals.notify(tr(err_str) + (" (%s)" % error_string(err)), Notify.Icon.ERR)
		return
	
	var fd: FileDialog = FileDialog.new()
	fd.theme = get_tree().current_scene.theme
	fd.cancel_button_text = "$CANCEL"
	fd.title = "$SAVE_AS"
	fd.transient = true
	fd.transparent = true
	fd.transparent_bg = true
	fd.file_mode = FileDialog.FILE_MODE_SAVE_FILE
	fd.access = FileDialog.ACCESS_FILESYSTEM
	fd.current_dir = default_save_dir
	fd.set_filters(PackedStringArray(["*.tscn ; Text Scene"]))
	fd.close_requested.connect(
		func():
			fd.queue_free()
	)
	fd.file_selected.connect(
		func(file: String):
			err = ResourceSaver.save(packed_savable, file)
			if err:
				err_str = "$ERR_WHILE_SAVING"
				push_error(err_str + (" (%s)" % error_string(err)))
				Globals.notify(tr(err_str) + (" (%s)" % error_string(err)), Notify.Icon.ERR)
			else:
				last_lintree_save_file = file
				err_str = "$SUCCESS_SAVED_AS"
				print(err_str + (": %s" % file.get_file()))
				Globals.notify(tr(err_str) + (": %s" % file.get_file()), Notify.Icon.OK)
	)
	add_child(fd)
	fd.popup_centered(Vector2(800, 600))


func open_plt() -> void:
	var fd: FileDialog = FileDialog.new()
	fd.theme = get_tree().current_scene.theme
	fd.cancel_button_text = "$CANCEL"
	fd.title = "$OPEN"
	fd.transient = true
	fd.transparent = true
	fd.transparent_bg = true
	fd.file_mode = FileDialog.FILE_MODE_OPEN_FILE
	fd.access = FileDialog.ACCESS_FILESYSTEM
	fd.current_dir = default_save_dir
	fd.set_filters(PackedStringArray(["*.tscn ; Text Scene"]))
	fd.close_requested.connect(
		func():
			fd.queue_free()
	)
	fd.file_selected.connect(_on_selected_plt_to_open)
	add_child(fd)
	fd.popup_centered(Vector2(800, 600))


func _on_selected_plt_to_open(file: String) -> void:
	var err_str: String = ""
	if lin_tree_work_area == null:
		err_str = "$ERR_NO_WORK_AREA"
		push_error(err_str)
		Globals.notify(tr(err_str), Notify.Icon.ERR)
		return
	var packed: PackedScene = ResourceLoader.load(file)
	if packed == null:
		err_str = "$ERR_WHILE_LOADING"
		push_error(err_str + (" %s" % file.get_file()))
		Globals.notify(tr(err_str) + (" %s" % file.get_file()), Notify.Icon.ERR)
		return
	
	last_lintree_save_file = file
	var new_lin_tree = packed.instantiate()
	
	lin_tree_work_area.root.queue_free()
	lin_tree_work_area.root = new_lin_tree
	lin_tree_work_area.add_child(new_lin_tree)
	new_lin_tree.redraw()
	
	err_str = "$SUCCESS_OPENED"
	print(err_str + (": %s" % file.get_file()))
	Globals.notify(tr(err_str) + (": %s" % file.get_file()), Notify.Icon.OK)


func new_plt() -> void:
	_new_confirmation.popup_centered(Vector2i(475, 100))


func _on_new_plt_confirmed() -> void:
	var new_lin_tree = LinTreeRoot.new()
	new_lin_tree.paper_size = Vector2(lin_tree_work_area.get_A_paper_size_mm(4).y, lin_tree_work_area.get_A_paper_size_mm(4).x) * 10
	new_lin_tree.add_trunk(LinTreeTrunk.new())
	lin_tree_work_area.root.queue_free()
	lin_tree_work_area.root = new_lin_tree
	lin_tree_work_area.add_child(new_lin_tree)
	new_lin_tree.redraw()
	
	var err_str: String = "$SUCCESS_NEW"
	print(err_str)
	Globals.notify(tr(err_str), Notify.Icon.OK)


func export_as() -> void:
	var err_str: String = ""
	
	if not savable:
		# Can't export. No savable object found ('export_as()')
		err_str = "$ERR_NO_SAVABLE"
		push_error(err_str)
		Globals.notify(tr(err_str), Notify.Icon.ERR)
		return
	
	var fd: FileDialog = FileDialog.new()
	fd.theme = get_tree().current_scene.theme
	fd.transient = true
	fd.transparent = true
	fd.transparent_bg = true
	fd.cancel_button_text = "$CANCEL"
	fd.title = "$EXPORT_AS"
	fd.file_mode = FileDialog.FILE_MODE_SAVE_FILE
	fd.access = FileDialog.ACCESS_FILESYSTEM
	fd.current_dir = default_save_dir
	fd.set_filters(PackedStringArray(["*.svg ; Scalable Vector Graphics + *.pdf*"]))
	fd.close_requested.connect(
		func():
			fd.queue_free()
	)
	fd.file_selected.connect(export_to)
	add_child(fd)
	fd.popup_centered(Vector2(800, 600))


func export_to(file: String) -> void:
	var s: SVG = SVG.new()
	s.begin(savable.paper_size, "")
	var rects: Array[Rect2] = savable.get_all_rects()
	for i in rects.size():
		rects[i].position += savable.paper_size / 2
		s.add_rect(rects[i], Color.BLACK, Color.TRANSPARENT, export_line_thickness)
	s.end()
	
	var f: FileAccess = FileAccess.open(file, FileAccess.WRITE)
	f.store_string(s.code)
	f.close()
	print("'%s' saved and stream closed" % file)
	
	var pdf: bool = false
	if not inkscape_path.is_empty():
		var stderr = []
		var err: int = OS.execute(inkscape_path, ['--export-type="pdf"', file], stderr, true, false)
		if err:
			push_error("Cannot convert via inkscape.\nErr: %i.\nSTDERR: %s\n" % [err, stderr])
			Globals.notify(("'%s' " % file.get_base_dir()) + tr("$SAVED_SVG_BUT_NOT_PDF"), Notify.Icon.WARN, 6.0)
			Globals.notify(tr("$ERR_INKSCAPE_CANNOT_CONVERT"), Notify.Icon.ERR, 6.0)
			return
		pdf = true
	
	var err_str: String = "$SUCCESS_EXPORTED_AS"
	print(err_str + (": %s%s" % [file.get_file(), " + " + file.get_file().split(".")[0] + ".pdf" if pdf else ""]))
	Globals.notify(tr(err_str) + (": %s%s" % [file.get_file(), " + " + file.get_file().split(".")[0] + ".pdf" if pdf else ""]), Notify.Icon.OK)
