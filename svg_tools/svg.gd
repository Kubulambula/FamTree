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


func add_rect(rect: Rect2, outline: Color, fill: Color = Color.TRANSPARENT, outline_width: float = 5.0) -> void:
	var outline_str: String = "none" if outline == Color.TRANSPARENT else "rgb(%d,%d,%d,%d)" % [outline.r8, outline.g8, outline.b8, outline.a8]
	var fill_str: String = "none" if fill == Color.TRANSPARENT else "rgb(%d,%d,%d,%d)" % [fill.r8, fill.g8, fill.b8, fill.a8]
	code += '\t<rect x="%f" y="%f" width="%f" height="%f" style="fill:%s;stroke:%s;stroke-width:%f"/>\n' % [
		rect.position.x, rect.position.y, rect.size.x, rect.size.y, fill_str, outline_str, outline_width
	]

