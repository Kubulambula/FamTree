extends PopupPanel


signal new_values(width: float, spacing: float)


func show_pls(pos: Vector2, width: float, spacing: float) -> void:
	transparent_bg = true
	transparent = true
	theme = get_tree().current_scene.theme
	%WidthSpinBox.value = width
	%SpacingSpinBox.value = spacing
	popup(Rect2i(pos, Vector2(220, 165)))


func _on_popup_hide() -> void:
#	printerr("hide")
	queue_free()


func _on_width_spin_box_value_changed(value: float) -> void:
	new_values.emit(value, %SpacingSpinBox.value)


func _on_spacing_spin_box_value_changed(value: float) -> void:
	new_values.emit(%WidthSpinBox.value, value)
