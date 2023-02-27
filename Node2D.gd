extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready():
	
	var children = [0]
	
	var child_count = children.size()
	var left_preference = true
	var last_left_index = (child_count / 2) + (1 if left_preference and child_count % 2 else 0)
	printerr(children.slice(0, last_left_index))
	printerr(children.slice(last_left_index))
#	var svg = SVG.new()
#	svg.begin(Vector2i(500,500), "Hello World")
#	svg.add_rect(Rect2(10, 10, 100, 100), Color.RED, Color.SADDLE_BROWN, 2)
#	svg.end()



#	FileAccess.open("user://test.svg", FileAccess.WRITE).store_string(svg.code)
#	print(svg.code)

#	var output = []
#	printerr(OS.execute("python3", ["D:/MyCode/FamTree/svg_tools/svg_exporter.py", svg.code, "png"], output))
#	printerr(output[0])
