class_name Notify
extends CanvasLayer


const ICONS = [
	"Nothing here haha",
	preload("res://icons/status_warning.svg"),
	preload("res://icons/status_success.svg"),
	preload("res://icons/status_error.svg"),
]

enum Icon {
	NONE,
	WARN,
	OK,
	ERR
}

var _queue: Array[Dictionary] = []
var _showing: bool = false


func _ready() -> void:
	visible = false


func notify(text: String, icon: Icon = Icon.NONE, duration: float = 1.5) -> void:
	if not _queue.is_empty():
		if _queue[-1]["text"] == text and _queue[-1]["icon"] == icon:
			return
	
	_queue.append(
		{
			"text": text,
			"icon": icon,
			"duration": duration,
		}
	)
	
	if not _showing:
		show_next()


func show_next() -> void:
	if _queue.is_empty():
		return
	_showing = true
	var notification: Dictionary = _queue.pop_front()
	if notification["icon"]:
		%Icon.texture = ICONS[notification["icon"]]
	%Label.text = notification["text"]
	visible = true
	get_tree().create_timer(notification["duration"]).timeout.connect(
		func():
			visible = false
			_showing = false
			await get_tree().create_timer(0.1).timeout
			show_next()
	)
	
