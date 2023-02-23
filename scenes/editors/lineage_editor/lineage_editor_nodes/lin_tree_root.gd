class_name LinTreeRoot
extends Node


var work_area_rect: Rect2 = Rect2()


func _init():
	child_entered_tree.connect(_on_child_entered_tree)


func redraw() -> void:
	get_first_descendant().redraw()


func get_first_descendant() -> LinTreeNode:
	return get_child(0) as LinTreeNode


func get_generation_count() -> int:
	var generation_count = 0
	var current_generation: LinTreeNode = get_first_descendant()
	while current_generation != null:
		generation_count += 1
		current_generation = current_generation.get_main_descendant()
	return generation_count


func _on_child_entered_tree(child: Node) -> void:
	if child is LinTreeNode:
		return
	push_error("A child that entered the LinTree is not of LinTreeNode type and will be freed!")
	child.queue_free()
