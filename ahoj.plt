�(        PackedScene       resource_local_to_scene           resource_name             _bundled   	         names   "         @@25       layout_mode    anchors_preset     script     Control    @@31       custom_minimum_size    offset_left    offset_top     offset_right       offset_bottom      mouse_default_cursor_shape     @@43       @@37          variants                         GDScript      resource_local_to_scene           resource_name             script/source      �
  class_name LinTreeRoot
extends LinTreeNode


var padding_left: float = 25
var padding_right: float = 25
var padding_top: float = 25
var padding_bottom: float = 25

var trunk_node_size: Vector2 = Vector2(400, 300)
var paper_size: Vector2
var work_area_rect: Rect2


func _init():
	Globals.savable = self
	child_entered_tree.connect(_on_child_entered_tree)


# 0 = OK
# 1 = Trunk error
# 2 = Branch error
func redraw() -> int:
	work_area_rect = Rect2(
		# offset the work area position vector because the ColorRect uses Center anchor preset
		Vector2(padding_left, padding_top) - (paper_size / 2), # top-left corner
		paper_size - Vector2(padding_left + padding_right, padding_top + padding_bottom) # size
	)
	queue_redraw()
	
	var trunks: Array[LinTreeTrunk] = get_trunks()
	var spacing_between_trunks: float = (work_area_rect.size.y - trunk_node_size.y * trunks.size()) / (trunks.size() + 1)
	if spacing_between_trunks < 0:
		push_error("Too much generations or the height is just too big")
		return 1
	
	for _x in 2:
		for i in trunks.size():
			if trunks[i].redraw(
				work_area_rect,
				Rect2(
					Vector2(
						(work_area_rect.position.x + work_area_rect.size.x / 2) - trunk_node_size.x / 2,
						work_area_rect.end.y - (i + 1) * (spacing_between_trunks + trunk_node_size.y)
					),
					trunk_node_size
				)
			):
				return 2
		# haha funny await go brrrrr
		# LinTree can be drawn incorectly if this is not used and I don't know why ¯\_(ツ)_/¯ (Godot 4 bug?)
		await get_tree().process_frame
	return 0


func _on_new_paddings(left: float, right: float, top: float, bottom: float) -> void:
	padding_left = left
	padding_right = right
	padding_top = top
	padding_bottom = bottom
	redraw()


func _draw() -> void:
	draw_dashed_line(
		work_area_rect.position,
		work_area_rect.position + Vector2(work_area_rect.size.x, 0),
		Color.BLACK,
		5,
		30,
	)
	# lower
	draw_dashed_line(
		work_area_rect.end - Vector2(work_area_rect.size.x, 0),
		work_area_rect.end,
		Color.BLACK,
		5,
		30,
	)
	# left
	draw_dashed_line(
		work_area_rect.position,
		work_area_rect.position + Vector2(0, work_area_rect.size.y),
		Color.BLACK,
		5,
		30,
	)
	# right
	draw_dashed_line(
		work_area_rect.end - Vector2(0, work_area_rect.size.y),
		work_area_rect.end,
		Color.BLACK,
		5,
		30,
	)


func add_trunk(trunk: LinTreeTrunk) -> void:
#	if get_child_count() > 0:
#		push_error("reeee uz mam trunk")
#		return 
	add_child(trunk)
	trunk.owner = self


func get_trunks() -> Array[LinTreeTrunk]:
	var trunks: Array[LinTreeTrunk] = []
	for child in get_children():
		if child is LinTreeTrunk:
			trunks.append(child)
	return trunks


func _on_child_entered_tree(child: Node) -> void:
	if child is LinTreeTrunk:
		return
	push_error("A child that entered the LinTree is not of LinTreeNode type")
      �C  �C     H�    ��C     HC    `8D            GDScript      resource_local_to_scene           resource_name             script/source      �  @tool
class_name LinTreeTrunk
extends LinTreeNode

var r: Rect2 = Rect2(Vector2(100, 100), Vector2(250, 250))
var war: Rect2

var left_siblings: Array[LinTreeBranch] = []
var right_siblings: Array[LinTreeBranch] = []
var sibling_width: float = 240
var sibling_spacing: float = 100

var _add_up: TextureButton = TextureButton.new()
var _add_down: TextureButton = TextureButton.new()
var _add_left: TextureButton = TextureButton.new()
var _add_right: TextureButton = TextureButton.new()
var _delete_self: TextureButton = TextureButton.new()


var settings_popup = preload("res://scenes/editors/lineage_editor/popup_windows/trunk_settings.tscn")


func _init():
	mouse_filter = Control.MOUSE_FILTER_STOP
	mouse_default_cursor_shape = Control.CURSOR_BUSY
#	gui_input.connect(func(x): printerr("trunk event"))
	
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
	
	# Draw siblings
	if draw_branches_on_left(left_siblings):
		push_error("branches on left out of area")
		return 2
	if draw_branches_on_right(right_siblings):
		push_error("branches on right out of area")
		return 2
	return 0


func draw_branches_on_left(branches: Array[LinTreeBranch]) -> int:
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


func draw_branches_on_right(branches: Array[LinTreeBranch]) -> int:
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
      �     C    `8�    ���   
   node_count              nodes      R   ��������       ����                                        ����                           	      
               	                     ����                        
   	      
               	                     ����                           	      
               	          
   conn_count               conns             
   node_paths               editable_instances               version          script      