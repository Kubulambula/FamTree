extends Node

var _quit_confirmation: ConfirmationDialog = null
var _quit_blockers: Array[Object] = []
var _awaiting_quit: bool = false
signal e_quit

var locale: String = TranslationServer.get_locale()
signal e_locale_changed(new_locale: String)


func _ready():
	_quit_confirmation = load("res://scenes/main_window/popup_windows/quit_confirmation.tscn").instantiate()
	_quit_confirmation.confirmed.connect(_quit_confirmed)
	_quit_confirmation.canceled.connect(func(): _awaiting_quit = false)
	add_child(_quit_confirmation)
	
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
