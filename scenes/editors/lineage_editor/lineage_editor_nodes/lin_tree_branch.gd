class_name LinTreeBranch
extends LinTreeNode

var r: Rect2


func redraw(rect: Rect2) -> void:
	print("Redraw branch")
	r = rect
	queue_redraw()


func _draw():
	draw_rect(r, Color.GREEN, true)
