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


func _ready():
	_quit_confirmation = load("res://scenes/main_window/popup_windows/quit_confirmation.tscn").instantiate()
	_quit_confirmation.confirmed.connect(_quit_confirmed)
	_quit_confirmation.canceled.connect(func(): _awaiting_quit = false)
	add_child(_quit_confirmation)
	
	_new_confirmation = load("res://scenes/main_window/popup_windows/new_confirmation.tscn").instantiate()
	_new_confirmation.confirmed.connect(_on_new_plt_confirmed)
	add_child(_new_confirmation)
	
	set_locale("cs")


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
	if last_lintree_save_file.is_empty():
		save_as_plt()
		return
	
	if not savable:
		push_error("nothing savable")
		return
	
	var packed_savable: PackedScene = PackedScene.new()
	var err: int = packed_savable.pack(savable)
	if err:
		push_error("some error occured: %s (%s)" % [err, error_string(err)])
		return
	err = ResourceSaver.save(packed_savable, last_lintree_save_file)
	if err:
		push_error("can't save: %s (%s)" % [err, error_string(err)])


func save_as_plt() -> void:
	if not savable:
		push_error("nothing savable")
		return
	
	var packed_savable: PackedScene = PackedScene.new()
	var err: int = packed_savable.pack(savable)
	if err:
		push_error("some error occured: %s (%s)" % [err, error_string(err)])
		return
	
	var fd: FileDialog = FileDialog.new()
	fd.theme = get_tree().current_scene.theme
	fd.cancel_button_text = "$CANCEL"
	fd.title = "$SAVE_AS"
	fd.file_mode = FileDialog.FILE_MODE_SAVE_FILE
	fd.access = FileDialog.ACCESS_FILESYSTEM
	fd.set_filters(PackedStringArray(["*.tscn ; Text Scene"]))
	fd.close_requested.connect(
		func():
			fd.queue_free()
	)
	fd.file_selected.connect(
		func(file: String):
			err = ResourceSaver.save(packed_savable, file)
			if err:
				push_error("can't save: %s (%s)" % [err, error_string(err)])
			else:
				last_lintree_save_file = file
	)
	add_child(fd)
	fd.popup_centered(Vector2(800, 600))


func open_plt() -> void:
	var fd: FileDialog = FileDialog.new()
	fd.theme = get_tree().current_scene.theme
	fd.cancel_button_text = "$CANCEL"
	fd.title = "$OPEN"
	fd.file_mode = FileDialog.FILE_MODE_OPEN_FILE
	fd.access = FileDialog.ACCESS_FILESYSTEM
	fd.set_filters(PackedStringArray(["*.tscn ; Text Scene"]))
	fd.close_requested.connect(
		func():
			fd.queue_free()
	)
	fd.file_selected.connect(_on_selected_plt_to_open)
	add_child(fd)
	fd.popup_centered(Vector2(800, 600))


func _on_selected_plt_to_open(file: String) -> void:
	if lin_tree_work_area == null:
		push_error("REEEEEEEEEEE")
		return
	var packed: PackedScene = ResourceLoader.load(file)
	if packed == null:
		push_error("can't read")
	
	last_lintree_save_file = file
	var new_lin_tree = packed.instantiate()
	
	lin_tree_work_area.root.queue_free()
	lin_tree_work_area.root = new_lin_tree
	lin_tree_work_area.add_child(new_lin_tree)
	new_lin_tree.redraw()


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


func export_as() -> void:
	if not savable:
		push_error("nothing savable")
		return
	
	var fd: FileDialog = FileDialog.new()
	fd.theme = get_tree().current_scene.theme
	fd.cancel_button_text = "$CANCEL"
	fd.title = "$EXPORT_AS"
	fd.file_mode = FileDialog.FILE_MODE_SAVE_FILE
	fd.access = FileDialog.ACCESS_FILESYSTEM
	fd.set_filters(PackedStringArray(["*.svg ; Scalable Vector Graphics"]))
	fd.close_requested.connect(
		func():
			fd.queue_free()
	)
	fd.file_selected.connect(export_to)
	add_child(fd)
	fd.popup_centered(Vector2(800, 600))


func export_to(file: String) -> void:
	var s: SVG = SVG.new()
	s.begin(savable.paper_size, "FamTree generated SVG")
	var rects: Array[Rect2] = savable.get_all_rects()
	for i in rects.size():
		rects[i].position += savable.paper_size / 2
		s.add_rect(rects[i], Color.BLACK, Color.TRANSPARENT, 5)
	s.end()
	
	var f: FileAccess = FileAccess.open(file, FileAccess.WRITE)
	f.store_string(s.code)
