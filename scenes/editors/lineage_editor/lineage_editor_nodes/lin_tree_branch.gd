@tool
class_name LinTreeBranch
extends LinTreeNode

var r: Rect2 = Rect2(Vector2(50, 50), Vector2(300, 200))
var settings_popup = preload("res://scenes/editors/lineage_editor/popup_windows/branch_settings.tscn")

var _delete_self: TextureButton = TextureButton.new()


func _get_property_list() -> Array:
	return [
		{"name": "size", "type": TYPE_VECTOR2, "usage": PROPERTY_USAGE_STORAGE},
	]


func _ready() -> void:
	_delete_self.texture_normal = preload("res://icons/minus_circle.svg")
	_delete_self.texture_hover = preload("res://icons/minus_circle_hover.svg")
	_delete_self.pressed.connect(_on_delete_self_pressed)
	add_child(_delete_self, false, Node.INTERNAL_MODE_FRONT)
	_delete_self.owner = self


func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_RIGHT and event.is_pressed():
			var settings = settings_popup.instantiate()
			add_child(settings)
			settings.new_values.connect(_on_new_values)
			settings.show_pls(
				get_screen_transform().origin + get_local_mouse_position() * Globals.active_camera.zoom,
				get_parent().sibling_width,
				get_parent().sibling_spacing
			)


func _on_new_values(width: float, spacing: float) -> void:
	var p = get_parent()
	p.sibling_width = width
	p.sibling_spacing = spacing
	p.redraw(p.war, p.r)


func _on_delete_self_pressed():
	queue_free()
	tree_exited.connect(
		(func(parent, war, r):
			parent.left_siblings.erase(self)
			parent.right_siblings.erase(self)
			parent.redraw(war, r)
			).bind(get_parent(), get_parent().war, get_parent().r)
	)


func redraw(rect: Rect2) -> int:
	r = rect
	queue_redraw()
	return 0


func _draw():
	position = r.position
	custom_minimum_size = r.size
	size = r.size
	draw_rect(Rect2(Vector2.ZERO, r.size), Color.FOREST_GREEN, false, 8)
	_delete_self.position = (size / 2) - (_delete_self.size / 2)
