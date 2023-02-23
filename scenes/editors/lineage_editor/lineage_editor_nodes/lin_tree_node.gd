class_name LinTreeNode
extends Node


func _init():
	child_entered_tree.connect(_on_child_entered_tree)


func redraw() -> void:
	for child in get_children():
		child.redraw()


func get_lin_tree_root() -> LinTreeRoot:
	var current_parent: Node = get_parent()
	while current_parent:
		if current_parent is LinTreeRoot:
			return current_parent
		if not current_parent is LinTreeNode:
			return null
		current_parent = current_parent.get_parent()
	return null


func get_main_descendant() -> LinTreeNode:
	return get_child(0) as LinTreeNode


func get_non_main_descendants() -> Array[LinTreeNode]:
	return get_children().slice(1)


func add_descendant(desc: LinTreeNode, main: bool = false) -> void:
	if main and get_child_count() > 0:
		push_error("Already existing main descendant. Descandant will be added as a regular one")
		return
	add_child(desc)
	desc.owner = owner


func _on_child_entered_tree(child: Node) -> void:
	if child is LinTreeNode:
		return
	push_error("A child that entered the LinTree is not of LinTreeNode type and will be freed!")
	child.queue_free()
