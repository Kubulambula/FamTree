class_name LinTreeTrunk
extends LinTreeNode

var r: Rect2
var war: Rect2

var left_preference: bool = true
var sibling_width: float = 400
var sibling_spacing: float = 100


func _init():
	child_entered_tree.connect(_on_child_entered_tree)


func redraw(work_area_rect: Rect2, rect: Rect2, prefer_siblings_on_left: bool) -> void:
	print("Redraw trunk")
	war = work_area_rect
	left_preference = prefer_siblings_on_left
	r = rect
	queue_redraw()
	
	var sibling_side_slice_index: int = (get_child_count() / 2) + (1 if left_preference and get_child_count() % 2 else 0)
	if draw_branches_on_left(get_branches().slice(0, sibling_side_slice_index)):
		push_error("branches on left out of area")
		return
	if draw_branches_on_right(get_branches().slice(sibling_side_slice_index)):
		push_error("branches on right out of area")
		return


func draw_branches_on_left(branches: Array[LinTreeBranch]) -> int:
	if r.position.x - (branches.size()) * (sibling_spacing + sibling_width) < war.position.x:
		return 1
	for i in branches.size():
		branches[i].redraw(
			Rect2(
				Vector2(
					r.position.x - (i + 1) * (sibling_spacing + sibling_width),
					r.position.y
				),
				Vector2(
					sibling_width,
					r.size.y
				)
			)
		)
	return 0


func draw_branches_on_right(branches: Array[LinTreeBranch]) -> int:
	if r.end.x + (sibling_spacing + sibling_width) * branches.size() > war.end.x:
		return 1
	for i in branches.size():
		branches[i].redraw(
			Rect2(
				Vector2(
					r.end.x + (i + 1) * sibling_spacing + i * sibling_width,
					r.position.y
				),
				Vector2(
					sibling_width,
					r.size.y
				)
			)
		)
	return 0


func _draw():
	draw_rect(r, Color.BLUE, true)


func get_lin_tree_root() -> LinTreeRoot:
	return get_parent() as LinTreeRoot


func add_brach(branch: LinTreeBranch) -> void:
	add_child(branch)
	branch.owner = owner


func get_branches() -> Array[LinTreeBranch]:
	var branches: Array[LinTreeBranch]
	for child in get_children():
		if child is LinTreeBranch:
			branches.append(child)
	return branches


func _on_child_entered_tree(child: Node) -> void:
	if child is LinTreeNode:
		return
	push_error("A child that entered the LinTree is not of LinTreeNode type and will be freed!")
