@tool
class_name LinTreeTrunk
extends LinTreeNode

var r: Rect2 = Rect2(Vector2(100, 100), Vector2(250, 250))
var war: Rect2

var left_siblings: Array = []
var right_siblings: Array = []
var sibling_width: float = 240
var sibling_spacing: float = 100

var _add_up: TextureButton = TextureButton.new()
var _add_down: TextureButton = TextureButton.new()
var _add_left: TextureButton = TextureButton.new()
var _add_right: TextureButton = TextureButton.new()
var _delete_self: TextureButton = TextureButton.new()


var settings_popup = preload("res://scenes/editors/lineage_editor/popup_windows/trunk_settings.tscn")


func _get_property_list() -> Array:
	return [
		{"name": "left_siblings", "type": TYPE_ARRAY, "usage": PROPERTY_USAGE_STORAGE},
		{"name": "right_siblings", "type": TYPE_ARRAY, "usage": PROPERTY_USAGE_STORAGE},
		{"name": "sibling_width", "type": TYPE_FLOAT, "usage": PROPERTY_USAGE_STORAGE},
		{"name": "sibling_spacing", "type": TYPE_FLOAT, "usage": PROPERTY_USAGE_STORAGE},
	]


func get_rects() -> Array[Rect2]:
	var rects: Array[Rect2] = [get_global_rect()]
	for sibling in left_siblings:
		rects.append(sibling.get_global_rect())
	for sibling in right_siblings:
		rects.append(sibling.get_global_rect())
	return rects


func _init():
	mouse_filter = Control.MOUSE_FILTER_STOP
	mouse_default_cursor_shape = Control.CURSOR_BUSY
	
	_add_up.texture_normal = preload("res://icons/plus_circle.svg")
	_add_up.texture_hover = preload("res://icons/plus_circle_hover.svg")
	_add_up.pressed.connect(_on_add_up_pressed)
	add_child(_add_up, false, Node.INTERNAL_MODE_FRONT)
	_add_up.owner = self
	
	_add_down.texture_normal = preload("res://icons/plus_circle.svg")
	_add_down.texture_hover = preload("res://icons/plus_circle_hover.svg")
	_add_down.pressed.connect(_on_add_down_pressed)
	add_child(_add_down, false, Node.INTERNAL_MODE_FRONT)
	_add_down.owner = self
	
	_add_left.texture_normal = preload("res://icons/plus_circle.svg")
	_add_left.texture_hover = preload("res://icons/plus_circle_hover.svg")
	_add_left.pressed.connect(_on_add_left_pressed)
	add_child(_add_left, false, Node.INTERNAL_MODE_FRONT)
	_add_left.owner = self
	
	_add_right.texture_normal = preload("res://icons/plus_circle.svg")
	_add_right.texture_hover = preload("res://icons/plus_circle_hover.svg")
	_add_right.pressed.connect(_on_add_right_pressed)
	add_child(_add_right, false, Node.INTERNAL_MODE_FRONT)
	_add_right.owner = self
	
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
				get_parent().trunk_node_size.x,
				get_parent().trunk_node_size.y
			)


func _on_new_values(width: float, height: float) -> void:
	var p = get_parent()
	p.trunk_node_size = Vector2(width, height)
	p.redraw()


func _on_add_up_pressed() -> void:
	var parent = get_parent()
	var new_trunk: LinTreeTrunk = LinTreeTrunk.new()
	parent.add_trunk(new_trunk)
	parent.move_child(new_trunk, get_index() + 1)
	
	if await parent.redraw():
		printerr("nope")
		new_trunk._on_delete_self_pressed()


func _on_add_down_pressed() -> void:
	var parent = get_parent()
	var new_trunk: LinTreeTrunk = LinTreeTrunk.new()
	parent.add_trunk(new_trunk)
	parent.move_child(new_trunk, get_index())
	
	if await parent.redraw():
		printerr("nope")
		new_trunk._on_delete_self_pressed()
#		parent.queue_redraw()


func _on_add_left_pressed() -> void:
	var new_branch: LinTreeBranch = LinTreeBranch.new()
	add_child(new_branch)
	new_branch.owner = self
	left_siblings.append(new_branch)
	if redraw(war, r):
		left_siblings.erase(new_branch)
		new_branch.queue_free()


func _on_add_right_pressed() -> void:
	var new_branch: LinTreeBranch = LinTreeBranch.new()
	add_child(new_branch)
	new_branch.owner = self
	right_siblings.append(new_branch)
	if redraw(war, r):
		right_siblings.erase(new_branch)
		new_branch.queue_free()


func _on_delete_self_pressed() -> void:
	if get_parent().get_trunks().size() > 1:
		queue_free()
		tree_exited.connect(
			(func(parent):
				parent.redraw()).bind(get_parent())
		)
	else:
		printerr("nono")


func redraw(work_area_rect: Rect2, rect: Rect2) -> int:
#	print("Trunk: ", rect)
	war = work_area_rect
	r = rect
	# draw the trunk
	queue_redraw()
	
	for s in left_siblings:
		if s.get_parent() == null:
			add_child(s)
	for s in right_siblings:
		if s.get_parent() == null:
			add_child(s)
	
	# Draw siblings
	if draw_branches_on_left(left_siblings):
		push_error("branches on left out of area")
		return 2
	if draw_branches_on_right(right_siblings):
		push_error("branches on right out of area")
		return 2
	return 0


func draw_branches_on_left(branches: Array) -> int:
	if get_global_position().x - (branches.size()) * (sibling_spacing + sibling_width) < war.position.x:
		return 2
	for i in branches.size():
		branches[i].redraw(
			Rect2(
				Vector2(
					-(i + 1) * (sibling_spacing + sibling_width),
					0
				),
				Vector2(
					sibling_width,
					size.y
				)
			)
		)
	return 0


func draw_branches_on_right(branches: Array) -> int:
	if get_global_position().x + size.x + (sibling_spacing + sibling_width) * branches.size() > war.end.x:
		return 2
	for i in branches.size():
		branches[i].redraw(
			Rect2(
				Vector2(
					size.x + ((i + 1) * sibling_spacing) + (i * sibling_width),
					0
				),
				Vector2(
					sibling_width,
					size.y
				)
			)
		)
	return 0


func _draw():
	position = r.position
	custom_minimum_size = r.size
	size = r.size
	
	_add_up.position = Vector2(
		(size.x / 2) - (_add_up.size.x / 2),
		-(_add_up.size.y / 2)
	)
	_add_down.position = Vector2(
		(size.x / 2) - (_add_down.size.x / 2),
		size.y - (_add_down.size.y / 2)
	)
	_add_left.position = Vector2(
		-(_add_left.size.x / 2),
		(size.y / 2) - (_add_down.size.y / 2)
	)
	_add_right.position = Vector2(
		size.x - (_add_right.size.x / 2) ,#- 40,
		(size.y / 2) - (_add_right.size.y / 2)
	)
	_delete_self.position = (size / 2) - (_delete_self.size / 2)
	
	draw_rect(Rect2(Vector2.ZERO, r.size), Color.SADDLE_BROWN, false, 8)


func get_lin_tree_root() -> LinTreeRoot:
	return get_parent() as LinTreeRoot


func add_brach(branch: LinTreeBranch) -> void:
	add_child(branch)
	branch.owner = owner


func get_branches() -> Array[LinTreeBranch]:
	var branches: Array[LinTreeBranch] = []
	for child in get_children():
		if child is LinTreeBranch:
			branches.append(child)
	return branches


#func _on_child_entered_tree(child: Node) -> void:
#	if child is LinTreeNode:
#		return
#	push_error("A child that entered the LinTree is not of LinTreeNode type")
