extends PopupPanel


signal new_values(width: float, height: float, visible: bool)


func show_pls(pos: Vector2, width: float, height: float, visible: bool) -> void:
	transparent_bg = true
	transparent = true
	theme = get_tree().current_scene.theme
	%WidthSpinBox.value = width
	%HeightSpinBox.value = height
	%VisibilityCheckButton.button_pressed = visible
	popup(Rect2i(pos, Vector2(220, 200)))


func _on_popup_hide() -> void:
	queue_free()


func _on_width_spin_box_value_changed(value: float) -> void:
	new_values.emit(value, %HeightSpinBox.value, %VisibilityCheckButton.button_pressed)


func _on_height_spin_box_value_changed(value: float) -> void:
	new_values.emit(%WidthSpinBox.value, value, %VisibilityCheckButton.button_pressed)


func _on_visibility_check_button_toggled(button_pressed: bool) -> void:
	if button_pressed:
		%VisibilityCheckButton.icon = preload("res://icons/eye_open.svg")
	else:
		%VisibilityCheckButton.icon = preload("res://icons/eye_closed.svg")
	new_values.emit(%WidthSpinBox.value, %HeightSpinBox.value, button_pressed)
