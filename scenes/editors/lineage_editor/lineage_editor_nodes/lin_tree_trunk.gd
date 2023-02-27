class_name LinTreeTrunk
extends LinTreeNode

var r: Rect2

func _init():
	child_entered_tree.connect(_on_child_entered_tree)


func redraw(rect: Rect2) -> void:
	print("Redraw trunk")
	r = rect
	queue_redraw()
	for branch in get_branches():
		branch.redraw(Rect2())


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
