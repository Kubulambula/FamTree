extends Node2D


@onready var _pan_camera: PanCamera2D = $PanCamera2D

var lin_tree_root: LinTreeRoot = null
var padding_left: float = 50
var padding_right: float = 50
var padding_top: float = 200
var padding_bottom: float = 100

var work_area_rect: Rect2


func _ready():
	var paper_size: Vector2 = Vector2(get_A_paper_size_mm(4).y, get_A_paper_size_mm(4).x) * 10
	%WorkAreaBG.custom_minimum_size = paper_size
	await get_tree().create_timer(0.1).timeout # For some reason, waiting does the trick
	_pan_camera.do_zoom_without_mouse(0.4 - _pan_camera.zoom.x)
	
	work_area_rect = Rect2(
		# offset the work area position vector because the ColorRect uses Center anchor preset
		Vector2(padding_left, padding_top) - (%WorkAreaBG.size / 2), # top-left corner
		paper_size - Vector2(padding_right + padding_left, padding_bottom + padding_top) # size
	)
	
	queue_redraw()
	
	$LinTreeRoot.redraw(work_area_rect)


func _draw():
	draw_rect(work_area_rect, Color.RED)


# TODO: This is temp
func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_RIGHT and event.is_pressed():
			show_context_popup([{}, {}, {}])


func get_A_paper_size_mm(A: int) -> Vector2:
	return [
		Vector2(841, 1188), # A0
		Vector2(594, 841),  # A1
		Vector2(420, 594),  # A2
		Vector2(297, 420),  # A3
		Vector2(210, 297),  # A4
		Vector2(148, 210),  # A5
		Vector2(105, 148),  # A6
		Vector2(74, 105),   # A7
		Vector2(52, 74),    # A8
	][A]

# expects Array of Dictionaries in format of:
# {"label": String, "icon": Texture2D, "callback": Callable, "separator": bool}
func show_context_popup(items: Array[Dictionary]) -> void:
	if items.is_empty():
		push_error("items.is_empty() is true. Cannot create a context popup")
		return
	var popup_context_menu: PopupMenu = PopupMenu.new()
	var callbacks: Array = []
	for i in items.size():
		if items[i].get("separator", false):
			popup_context_menu.add_separator(items[i].get("label", ""))
			callbacks.append(null)
		else:
			popup_context_menu.add_icon_item(items[i].get("icon", null), items[i].get("label", "NO LABEL"))
			callbacks.append(items[i].get("callback", func(): printerr("NO CALLBACK")))
	
	popup_context_menu.index_pressed.connect((func(idx: int, callbacks: Array): callbacks[idx].call()).bind(callbacks))
	popup_context_menu.transparent_bg = true
	popup_context_menu.transparent = true
	popup_context_menu.theme = get_tree().current_scene.theme
	popup_context_menu.popup_hide.connect(popup_context_menu.queue_free)
	add_child(popup_context_menu)
	popup_context_menu.popup(Rect2i(get_screen_transform().origin + get_global_mouse_position() * _pan_camera.zoom, Vector2.ZERO))
