class_name PanCamera2D
extends Camera2D


signal zoom_changed(new_zoom)


@export var min_zoom: float = 0.25
@export var max_zoom: float = 1.5
@export var zoom_increment: float = 0.05
@onready var _camera_half_size: Vector2 = get_viewport_rect().size / 2


func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		if event.button_mask == MOUSE_BUTTON_MASK_LEFT or event.button_mask == MOUSE_BUTTON_MASK_MIDDLE:
			position = (position - event.relative / zoom).clamp(
				Vector2(limit_left, limit_top) + _camera_half_size / zoom,
				Vector2(limit_right, limit_bottom) - _camera_half_size / zoom
			)
	
	if event is InputEventMouseButton:
		if event.is_pressed():
			if event.double_click and (event.button_index == MOUSE_BUTTON_LEFT or event.button_index == MOUSE_BUTTON_MIDDLE):
				focus_position(get_global_mouse_position())
			elif event.button_index == MOUSE_BUTTON_WHEEL_UP:
				do_zoom(zoom_increment)
			elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
				do_zoom(-zoom_increment)


func do_zoom(amount: float) -> void:
	var target_mouse_position: Vector2 = get_global_mouse_position()
	zoom = (zoom + Vector2.ONE * amount).clamp(Vector2.ONE * min_zoom, Vector2.ONE * max_zoom)
	
	position = (position + target_mouse_position - get_global_mouse_position()).clamp(
		Vector2(limit_left, limit_top) + _camera_half_size / zoom,
		Vector2(limit_right, limit_bottom) - _camera_half_size / zoom
	)
	
	zoom_changed.emit(zoom.x)


func do_zoom_without_mouse(amount: float) -> void:
	zoom = (zoom + Vector2.ONE * amount).clamp(Vector2.ONE * min_zoom, Vector2.ONE * max_zoom)
	zoom_changed.emit(zoom.x)


func focus_position(pos: Vector2, duration: float=0.25) -> void:
	create_tween().tween_property(self, "position", pos, duration).set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
