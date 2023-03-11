class_name LinTreeRoot
extends LinTreeNode


var padding_left: float = 25
var padding_right: float = 25
var padding_top: float = 25
var padding_bottom: float = 25

var trunk_node_size: Vector2 = Vector2(300, 200)
var paper_size: Vector2
var work_area_rect: Rect2

# paper_size is saved, so it can be recovered in the future if needed
func _get_property_list() -> Array:
	return [
		{"name": "padding_left", "type": TYPE_FLOAT, "usage": PROPERTY_USAGE_STORAGE},
		{"name": "padding_right", "type": TYPE_FLOAT, "usage": PROPERTY_USAGE_STORAGE},
		{"name": "padding_top", "type": TYPE_FLOAT, "usage": PROPERTY_USAGE_STORAGE},
		{"name": "padding_bottom", "type": TYPE_FLOAT, "usage": PROPERTY_USAGE_STORAGE},
		{"name": "trunk_node_size", "type": TYPE_VECTOR2, "usage": PROPERTY_USAGE_STORAGE},
		{"name": "paper_size", "type": TYPE_VECTOR2, "usage": PROPERTY_USAGE_STORAGE},
	]


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
#	printerr(work_area_rect)
	queue_redraw()
	
	var trunks: Array[LinTreeTrunk] = get_trunks()
	var spacing_between_trunks: float = (work_area_rect.size.y - trunk_node_size.y * trunks.size()) / (trunks.size() + 1)
	if spacing_between_trunks < 0:
		var err_str: String = "$TOO_MANY_GENERATIONS"
		print(err_str)
		Globals.notify(tr(err_str), Notify.Icon.WARN)
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


func get_all_rects() -> Array[Rect2]:
	var rects: Array[Rect2] = []
	for trunk in get_trunks():
		rects.append_array(trunk.get_rects())
	return rects
