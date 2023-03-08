extends PopupPanel


signal new_values(left: float, right: float, top: float, bottom: float)


func show_pls(pos: Vector2, left: float, right: float, top: float, bottom: float) -> void:
	transparent_bg = true
	transparent = true
	theme = get_tree().current_scene.theme
	%PaddingLeftSpinBox.value = left
	%PaddingRightSpinBox.value = right
	%PaddingTopSpinBox.value = top
	%PaddingBottomSpinBox.value = bottom
	popup(Rect2i(pos, Vector2(380, 170)))


func _on_padding_left_spin_box_value_changed(value: float) -> void:
	new_values.emit(value, %PaddingRightSpinBox.value, %PaddingTopSpinBox.value, %PaddingBottomSpinBox.value)


func _on_padding_right_spin_box_value_changed(value: float) -> void:
	new_values.emit(%PaddingLeftSpinBox.value, value, %PaddingTopSpinBox.value, %PaddingBottomSpinBox.value)


func _on_padding_top_spin_box_value_changed(value: float) -> void:
	new_values.emit(%PaddingLeftSpinBox.value, %PaddingRightSpinBox.value, value, %PaddingBottomSpinBox.value)


func _on_padding_bottom_spin_box_value_changed(value: float) -> void:
	new_values.emit(%PaddingLeftSpinBox.value, %PaddingRightSpinBox.value, %PaddingTopSpinBox.value, value)


func _on_popup_hide() -> void:
	queue_free()
