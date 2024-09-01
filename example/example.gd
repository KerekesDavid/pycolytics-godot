extends Node2D

@export var pyco_event:PycoEvent


func _ready() -> void:
	# Setting a startup_callable returning a PycoEvent before
	# the end of the first frame allows for a costumized startup event
	PycoLog.startup_callable = func() -> PycoEvent: 
		var e := PycoEvent.copy_default()
		e.event_type = "startup"
		e.value = {"custom_startup_message": 42}
		return e
	
	# Set auto_accept_quit to false, so PycoLog has time to send logging events
	get_tree().set_auto_accept_quit(false)
	# You can trigger get_tree().quit() any time after shutdown_request_sent is emitted
	# Logging events after NOTIFICATION_WM_CLOSE_REQUEST are not sent to the server
	PycoLog.shutdown_event_sent.connect(get_tree().quit)


func _physics_process(_delta: float) -> void:
	# PycoEvent.merge() lets you override values in a PycoEvent
	PycoLog.log_event(PycoEvent.copy_default().merge(pyco_event))


func _process(delta: float) -> void:
	# The simplest way to log an event
	PycoLog.log_event_by_type("process_event", {"delta": delta})


func _input(event: InputEvent) -> void:
	if event.is_action(&"ui_cancel"):
		# Make sure to trigger NOTIFICATION_WM_CLOSE_REQUEST instead of quitting
		# This is neccesary to send shutdown notifications
		# See https://docs.godotengine.org/en/stable/tutorials/inputs/handling_quit_requests.html#sending-your-own-quit-notification
		get_tree().root.propagate_notification(NOTIFICATION_WM_CLOSE_REQUEST)
