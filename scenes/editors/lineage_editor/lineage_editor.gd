extends Control


@onready var work_area: Node2D = %WorkArea
@onready var work_area_pan_camera: PanCamera2D = work_area.get_node("PanCamera2D")
@onready var magnification_display: Control = %MagnificationDisplay


func _ready():
	magnification_display.init_zoom(work_area_pan_camera.zoom.x)
	work_area_pan_camera.zoom_changed.connect(magnification_display.update_zoom)
