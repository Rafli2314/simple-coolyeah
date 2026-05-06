extends CanvasLayer

@onready var label = $DebugLabel

func set_text(text: String):
	label.text = text

var logs: Array = []

func add_log(text: String):
	logs.append(text)
	if logs.size() > 5:
		logs.pop_front()
	label.text = "\n".join(logs)
