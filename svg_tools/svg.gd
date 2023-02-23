class_name SVG
extends RefCounted

var code: String = ""


# for exporting: https://pypi.org/project/svglib/




func clear() -> void:
	code = ""


func begin(dimensions: Vector2i, comment: String="") -> void:
	dimensions = dimensions.abs()
	code = '%s<svg width="%dpx" height="%dpx" xmlns="http://www.w3.org/2000/svg">\n' % [
		("<!-- %s -->\n" % comment) if comment else comment,
		dimensions.x,
		dimensions.y,
#		bg_color.to_html(true),
#		bg_color.r8, bg_color.g8, bg_color.b8, bg_color.a8
	]


func end() -> void:
	code += "</svg>"


func add_rect(rect: Rect2, fill: Color, outline: Color, outline_width: float) -> void:
	code += '<rect x="%f" y="%f" width="%f" height="%f" style="fill:rgb(%d,%d,%d,%d);stroke:rgb(%d,%d,%d,%d);stroke-width:%f"/>\n' % [
		rect.position.x, rect.position.y, rect.size.x, rect.size.y, fill.r8, fill.g8, fill.b8, fill.a8, outline.r8, outline.g8, outline.g8, outline.a8, outline_width
	]
	pass
