extends Node

var _request_pool: Array[AwaitableHTTPRequest]
const _Pycolytics = preload("plugin.gd")
var _plugin:_Pycolytics

var concurrent_requests = 64
var default_event_details:PycoEventDetails = PycoEventDetails.new()
var url:String = _plugin.DEFAULT_SERVER_URL
var startup_callable:Callable
var shutdown_callable:Callable


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
	
	for i in range(concurrent_requests):
		_request_pool.push_back(_create_request())
		
	_log_startup.call_deferred()


func _notification(what) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		if shutdown_callable != null:
			log_event_from_details(shutdown_callable.call())


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
		url = ProjectSettings.get_setting_with_override(&"addons/pycolithics/server_url")


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
	var result: AwaitableHTTPRequest.HTTPResult = null
	var request: AwaitableHTTPRequest
	for r in _request_pool:
		if !r.is_requesting:
			request = r
	if request == null:
		push_warning("Too many requests in queue, dropped event ", event_details.to_json())
		return
		
	var body:String = event_details.to_json()		
	result = await request.async_request(self.url, PackedStringArray(), HTTPClient.Method.METHOD_POST, body)
	
	if result._error:
		push_warning(
			"PycoLog: Error while creating HTTP connection to ", url, 
			". Error code ", result._error, ": ", error_string(result._error)
		)
	elif result._result:
		push_warning(
			"\nPycoLog: error while making a HTTP request:",
			"\n    Result code ", result._result, ": ", result.result_message,
			"\n    HTTP status code: ", result.status_code,
			"\n    Respose Headers: ", result.headers,
			"\n    Response Body: ", result.body,
		)
	elif result.status_code > 400:
		push_warning(
			"\nPycoLog: Error reply from server:",
			"\n    HTTP status code: ", result.status_code,
			"\n    Respose Headers: ", result.headers,
			"\n    Response Body: ", result.body,
		)
