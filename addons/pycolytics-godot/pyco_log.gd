extends Node

const _Pycolytics = preload("plugin.gd")
var _plugin:_Pycolytics
var _event_queue:Array[PycoEventDetails]
var _http_request:AwaitableHTTPRequest
var _shutdown_initiated:bool = false
var _last_flush:float
var _url_suffix:String = "v1.0/events"

var flush_period_msec:float = 200.0
var default_event_details:PycoEventDetails = PycoEventDetails.new()
var url:String = _plugin.DEFAULT_SERVER_URL + _url_suffix
var startup_callable:Callable
var shutdown_callable:Callable

signal shutdown_event_sent


func _ready() -> void:
	ProjectSettings.settings_changed.connect(_sync_project_settings)
	
	_sync_project_settings()
	default_event_details.application = ProjectSettings.get_setting_with_override(&"application/config/name")
	default_event_details.platform =  OS.get_name()
	default_event_details.version = ProjectSettings.get_setting_with_override(&"application/config/version")
	default_event_details.user_id = OS.get_unique_id()
	default_event_details.session_id = "%x" % hash(OS.get_unique_id() + str(Time.get_unix_time_from_system()))
	
	startup_callable = _get_startup_event
	shutdown_callable = _get_shutdown_event
	
	_http_request = _create_request()
	
	_log_startup.call_deferred()


func _process(_delta: float) -> void:
	if (_event_queue.size() > 0
	&& !_http_request.is_requesting
	&& Time.get_ticks_msec() - _last_flush > flush_period_msec):
		_last_flush = Time.get_ticks_msec()
		_flush_queue()


func _notification(what) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		if _http_request.is_requesting:
			await _http_request.request_finished
		if shutdown_callable != null:
			log_event_from_details(shutdown_callable.call())
		_shutdown_initiated = true
		_flush_queue()
		await _http_request.request_finished
		shutdown_event_sent.emit()


func _log_startup() -> void:
	if startup_callable != null:
		log_event_from_details(startup_callable.call())


func _create_request() -> AwaitableHTTPRequest:
	var http_request = AwaitableHTTPRequest.new()
	add_child(http_request)
	#http_request.use_threads = true
	http_request.timeout = 3.0
	return http_request


func _sync_project_settings() -> void:
	if ProjectSettings.has_setting(&"addons/pycolithics/api_key"):
		default_event_details.api_key = ProjectSettings.get_setting_with_override(&"addons/pycolithics/api_key")
	else:
		default_event_details.api_key = _plugin.DEFAULT_API_KEY
	if ProjectSettings.has_setting(&"addons/pycolithics/server_url"):
		url = ProjectSettings.get_setting_with_override(&"addons/pycolithics/server_url") + _url_suffix


func _get_startup_event() -> PycoEventDetails:
	var event_details := PycoEventDetails.copy_default()
	event_details.event_type = "startup"
	return event_details


func _get_shutdown_event() -> PycoEventDetails:
	var event_details := PycoEventDetails.copy_default()
	event_details.event_type = "shutdown"
	return event_details


func log_event(event_type:String, value:Dictionary = {}) -> void:
	var details:PycoEventDetails = PycoEventDetails.copy_default()
	details.event_type = event_type
	details.value = value
	log_event_from_details(details)


func log_event_from_details(event_details:PycoEventDetails) -> void:
	if !_shutdown_initiated:
		_event_queue.push_back(event_details)
	#else:
		#print(
			#"PycoLog: Events logged after NOTIFICATION_WM_CLOSE_REQUEST are ignored: ",
			#event_details.to_json()
		#)

func _flush_queue():
	var json_array:PackedStringArray
	for event_details in _event_queue:
		json_array.append(event_details.to_json())
	var body:String = "[" + ",".join(json_array) + "]"
	_event_queue.clear()
	var result := await _http_request.async_request(url, PackedStringArray(), HTTPClient.Method.METHOD_POST, body)
	
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
