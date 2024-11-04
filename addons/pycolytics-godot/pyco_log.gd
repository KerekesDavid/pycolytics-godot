extends Node

const _Plugin = preload("plugin.gd")
var _event_queue: Array[PycoEvent]
var _http_request: AwaitableHTTPRequest
var _shutdown_initiated: bool = false
var _last_flush: float
var _url_suffix: String = "v1.0/events"

var flush_period_msec: float = 2000.0  ## Send batched events to server at least this often.
var queue_limit: int = 12  ## Send a batch of events if the queue is at least this long. Helps avoid frame stutter from too many events.
var request_timeout: float = 3.0  ## Number of seconds after which the event logging requests timeout. Will result in lost events.
var url: String = _Plugin.DEFAULT_SERVER_URL + _url_suffix  ## The exact server url for accepting batch requests (eg. including "v1.0/events").
var startup_callable: Callable  ## Callable returning a PycoEvent to send after the zeroth frame. Set to null to disable.
var shutdown_callable: Callable  ## Callable returning a PycoEvent to send on NOTIFICATION_WM_CLOSE_REQUEST. Set to null to disable.

signal shutdown_event_sent  ## Emitted after the shutdown event defined by shutdown_callable was sent.


func _ready() -> void:
	ProjectSettings.settings_changed.connect(_sync_project_settings)
	_sync_project_settings()
	PycoEvent.default_event.application = ProjectSettings.get_setting_with_override(
		&"application/config/name"
	)
	PycoEvent.default_event.platform = OS.get_name()
	PycoEvent.default_event.version = ProjectSettings.get_setting_with_override(
		&"application/config/version"
	)
	PycoEvent.default_event.user_id = OS.get_unique_id()
	PycoEvent.default_event.session_id = (
		"%x" % hash(OS.get_unique_id() + str(Time.get_unix_time_from_system()))
	)

	startup_callable = _get_startup_event
	shutdown_callable = _get_shutdown_event

	_http_request = _create_request()

	_log_startup.call_deferred()


func _process(_delta: float) -> void:
	if Time.get_ticks_msec() - _last_flush > flush_period_msec:
		_flush_queue()


func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		if _http_request.is_requesting:
			await _http_request.request_finished
		if shutdown_callable != null:
			log_event(shutdown_callable.call())
		_shutdown_initiated = true
		_flush_queue()
		await _http_request.request_finished
		shutdown_event_sent.emit()


func _log_startup() -> void:
	if startup_callable != null:
		log_event(startup_callable.call())


func _create_request() -> AwaitableHTTPRequest:
	var http_request := AwaitableHTTPRequest.new()
	add_child(http_request)
	#http_request.use_threads = true
	http_request.timeout = request_timeout
	return http_request


func _sync_project_settings() -> void:
	if ProjectSettings.has_setting(&"addons/pycolytics/api_key"):
		PycoEvent.default_event.api_key = ProjectSettings.get_setting_with_override(
			&"addons/pycolytics/api_key"
		)
	else:
		PycoEvent.default_event.api_key = _Plugin.DEFAULT_API_KEY
	if ProjectSettings.has_setting(&"addons/pycolytics/server_url"):
		url = (
			ProjectSettings.get_setting_with_override(&"addons/pycolytics/server_url") + _url_suffix
		)


func _get_startup_event() -> PycoEvent:
	var event := PycoEvent.copy_default()
	event.event_type = "startup"
	return event


func _get_shutdown_event() -> PycoEvent:
	var event := PycoEvent.copy_default()
	event.event_type = "shutdown"
	return event


## Logs an event, overriding event_type and values with the provided parameters
func log_event_by_type(event_type: String, value: Dictionary = {}) -> void:
	var event: PycoEvent = PycoEvent.copy_default()
	event.event_type = event_type
	event.value = value
	log_event(event)


## Logs an event, overriding the specified values of the default event.
func log_event(pyco_event: PycoEvent) -> void:
	log_event_raw(PycoEvent.copy_default().merge(pyco_event))


## Logs an event as it is. Use PycoEvent.copy_default().merge(...) to selectively override event properties.
func log_event_raw(pyco_event: PycoEvent) -> void:
	if !_shutdown_initiated:
		_event_queue.push_back(pyco_event)
		if _event_queue.size() > queue_limit:
			_flush_queue.call_deferred()
	#else:
		#push_warning(
			#"PycoLog: Events logged after NOTIFICATION_WM_CLOSE_REQUEST are ignored: ",
			#pyco_event.to_json()
		#)


func _flush_queue() -> void:
	if _event_queue.size() == 0 || _http_request.is_requesting:
		return
		
	_last_flush = Time.get_ticks_msec()
	var json_array: PackedStringArray
	for event in _event_queue:
		json_array.append(event.to_json())
	var body: String = "[" + ",".join(json_array) + "]"
	_event_queue.clear()
	var result := await _http_request.async_request(
		url, PackedStringArray(), HTTPClient.Method.METHOD_POST, body
	)

	if result._error:
		push_warning(
			"PycoLog: Error while creating HTTP connection to ", url,
			". Error code ", result._error, ": ", error_string(result._error)
		)
	elif result._result:
		push_warning(
			"\nPycoLog: error while making a HTTP request to ", url,
			"\n    Result code ", result._result, ": ", result.result_message,
			"\n    HTTP status code: ", result.status_code,
			"\n    Respose Headers: ", result.headers,
			"\n    Response Body: ", result.body,
		)
	elif result.status_code > 400:
		push_warning(
			"\nPycoLog: Error reply from server ", url,
			"\n    HTTP status code: ", result.status_code,
			"\n    Respose Headers: ", result.headers,
			"\n    Response Body: ", result.body,
		)
