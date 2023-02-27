class_name LinTreeRoot
extends LinTreeNode


var trunk_node_size: Vector2 = Vector2(400, 300)
#var spacing_between_trunks: float = 20


func _init():
	child_entered_tree.connect(_on_child_entered_tree)


func redraw(work_area_rect: Rect2) -> void:
	print("Begin redraw (ROOT)")
	var trunks: Array[LinTreeTrunk] = get_trunks()
	var spacing_between_trunks: float = (work_area_rect.size.y - trunk_node_size.y * trunks.size()) / (trunks.size() + 1)
	if spacing_between_trunks < 0:
		push_error("Too much generations or the height is just too big")
		return
	for i in trunks.size():
		trunks[i].redraw(
			work_area_rect,
			Rect2(
				Vector2(
					(work_area_rect.position.x + work_area_rect.size.x / 2) - trunk_node_size.x / 2,
					work_area_rect.end.y - (i + 1) * (spacing_between_trunks + trunk_node_size.y)
				),
				trunk_node_size
			),
			not bool(i % 2) # every even is prefered on the right
		)


func add_trunk(trunk: LinTreeTrunk) -> void:
#	if get_child_count() > 0:
#		push_error("reeee uz mam trunk")
#		return 
	add_child(trunk)
	trunk.owner = self


#func get_first_trunk() -> LinTreeTrunk:
#	return get_child(0) as LinTreeTrunk


#func get_trunk_count() -> int:
#	return get_child_count()
#	var trunk_count = 0
#	var current_trunk: LinTreeTrunk = get_first_trunk()
#	while current_trunk != null:
#		trunk_count += 1
#		current_trunk = current_trunk.get_next_trunk()
#	return trunk_count


func get_trunks() -> Array[LinTreeTrunk]:
	var trunks: Array[LinTreeTrunk]
	for child in get_children():
		if child is LinTreeTrunk:
			trunks.append(child)
	return trunks
		
#	return get_children()#.filter(func(x): return x is LinTreeTrunk)


func _on_child_entered_tree(child: Node) -> void:
	if child is LinTreeTrunk:
		return
	push_error("A child that entered the LinTree is not of LinTreeNode type and will be freed!")
	child.queue_free()
