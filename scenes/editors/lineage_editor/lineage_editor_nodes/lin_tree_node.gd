class_name LinTreeNode
extends Node2D


#func add_descendant(desc: LinTreeNode, main: bool = true) -> void:
#	if get_child_count() > 0:
#		push_error("LinTreeNodeEmpty can only have one descendant. This addition will be ignored")
#		return
#	add_child(desc)
#	desc.owner = owner
