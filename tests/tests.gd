class_name PycoLogTests
extends Node


func _ready() -> void:
	PycoEvent.default_event.value = {"default": "value"}

	var event: PycoEvent = PycoEvent.new()
	event.event_type = "test_value"
	event.application = 'test_val"u"e1 {"1":"2"} \n'
	event.version = "test_value2"
	event.platform = "test_value3"
	event.user_id = "test_value4"
	event.session_id = "test_value5"
	#event.api_key = "test_value6"
	event.value = {
		"a": event,
		"b": preload("res://addons/pycolytics-godot/plugin.gd"),
		"inner_dict": {"inner": 3.0},
		"inner_array": [event, 42, 4.2, "string"]
	}
	time_calls(PycoEvent.copy_default().merge.bind(event))

	time_calls(PycoEvent.copy_default().merge(event).to_json)

	print(PycoEvent.copy_default().merge(event).to_json())

	PycoLog.log_event(PycoEvent.copy_default().merge(event))


func time_calls(callable: Callable, n: int = 20000) -> void:
	var st := Time.get_ticks_msec()

	for i in range(n):
		callable.call()
	print("Timing ", callable, ": ", Time.get_ticks_msec() - st)
