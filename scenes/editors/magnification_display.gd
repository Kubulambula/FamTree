extends Control


@onready var _label = $PanelContainer/HBoxContainer/Label
var _default_zoom: float = 1


func init_zoom(default_zoom: float) -> void:
	_default_zoom = default_zoom
	update_zoom(default_zoom)


func update_zoom(zoom: float) -> void:
	_label.text = "%.0f%s" % [(zoom * 100 / _default_zoom), "%"]
