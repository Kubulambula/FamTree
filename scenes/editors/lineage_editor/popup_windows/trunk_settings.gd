extends PopupPanel


signal new_values(width: float, height: float)


func show_pls(pos: Vector2, width: float, height: float) -> void:
	transparent_bg = true
	transparent = true
	theme = get_tree().current_scene.theme
	%WidthSpinBox.value = width
	%HeightSpinBox.value = height
	popup(Rect2i(pos, Vector2(220, 165)))


func _on_popup_hide() -> void:
	queue_free()


func _on_width_spin_box_value_changed(value: float) -> void:
	new_values.emit(value, %HeightSpinBox.value)


func _on_height_spin_box_value_changed(value: float) -> void:
	new_values.emit(%WidthSpinBox.value, value)
