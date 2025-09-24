# MIT License (see LICENSE.md)
# 
# Copyright (c) 2024 Swarkin & Kerekes Dávid

## Code adapted by Kerekes Dávid from:
## Awaitable HTTP Request Node v1.6.0 by swark1n & [url=https://github.com/Swarkin/Godot-AwaitableHTTPRequest/graphs/contributors]contributors[/url].

class_name AwaitableHTTPRequest
extends HTTPRequest

signal request_finished		## Emits once the current request finishes, right after [member is_requesting] is set to false.
var is_requesting := false  ## Whether the node is busy performing a request.

## A dataclass returned by [method AwaitableHTTPRequest.async_request].
class HTTPResult extends RefCounted:
	var _error:Error					## Returns the [method HTTPRequest.request] error, [constant Error.OK] otherwise.
	var _result:HTTPRequest.Result		## Returns the [annotation HTTPRequest] error, [constant HTTPRequest.RESULT_SUCCESS] otherwise.
	var result_message:String:
		get: return _resolve_result_code(_result)
	var success:bool:					## Checks whether [member _error] and [member _result] aren't in an error state.[br][b]Note:[/b] This does not return false if [member status_code] is >= 400, see [code]https://developer.mozilla.org/en-US/docs/Web/HTTP/Status[/code].
		get: return true if (_error == OK and _result == HTTPRequest.RESULT_SUCCESS) else false

	var status_code:int				## The response status code.
	var headers_raw:PackedStringArray ## The response headers as a PackedStringArray.
	var headers:Dictionary[String, String]:			## The response headers as a dict.
		get: return _headers_to_dict(headers_raw)
	var body:String:					## The response body as a [String].
		get: return body_raw.get_string_from_utf8()
	var body_raw:PackedByteArray		## The response body as a [PackedByteArray].
	var json:Variant:					## Attempt to parse [member body] into a [Dictionary] or [Array], returns null on failure.
		get: return JSON.parse_string(body)

	## Constructs a new [AwaitableHTTPRequest.HTTPResult] from an [enum @GlobalScope.Error] code.
	static func _from_error(err: Error) -> HTTPResult:
		var h := HTTPResult.new()
		h._error = err
		return h

	## Constructs a new [AwaitableHTTPRequest.HTTPResult] from the return value of [signal HTTPRequest.request_completed].
	static func _from_array(a: Array) -> HTTPResult:
		var h := HTTPResult.new()
		@warning_ignore('unsafe_cast') h._result = a[0] as HTTPRequest.Result
		@warning_ignore('unsafe_cast') h.status_code = a[1] as int
		@warning_ignore('unsafe_cast') h.headers_raw = a[2] as PackedStringArray
		@warning_ignore('unsafe_cast') h.body_raw = a[3] as PackedByteArray
		return h

	static func _headers_to_dict(headers_arr: PackedStringArray) -> Dictionary[String, String]:
		var dict: Dictionary[String, String] = {}
		for h: String in headers_arr:
			var split := h.split(':')
			dict[split[0]] = split[1].strip_edges()

		return dict
		
	func _resolve_result_code(result:HTTPRequest.Result) -> String:
		const str_dict:Dictionary[HTTPRequest.Result, String] = {
			HTTPRequest.Result.RESULT_SUCCESS : "RESULT_SUCCESS",
			HTTPRequest.Result.RESULT_CHUNKED_BODY_SIZE_MISMATCH : "RESULT_CHUNKED_BODY_SIZE_MISMATCH",
			HTTPRequest.Result.RESULT_CANT_CONNECT : "RESULT_CANT_CONNECT",
			HTTPRequest.Result.RESULT_CANT_RESOLVE : "RESULT_CANT_RESOLVE",
			HTTPRequest.Result.RESULT_CONNECTION_ERROR : "RESULT_CONNECTION_ERROR",
			HTTPRequest.Result.RESULT_TLS_HANDSHAKE_ERROR : "RESULT_TLS_HANDSHAKE_ERROR",
			HTTPRequest.Result.RESULT_NO_RESPONSE : "RESULT_NO_RESPONSE",
			HTTPRequest.Result.RESULT_BODY_SIZE_LIMIT_EXCEEDED : "RESULT_BODY_SIZE_LIMIT_EXCEEDED",
			HTTPRequest.Result.RESULT_BODY_DECOMPRESS_FAILED : "RESULT_BODY_DECOMPRESS_FAILED",
			HTTPRequest.Result.RESULT_REQUEST_FAILED : "RESULT_REQUEST_FAILED",
			HTTPRequest.Result.RESULT_DOWNLOAD_FILE_CANT_OPEN : "RESULT_DOWNLOAD_FILE_CANT_OPEN",
			HTTPRequest.Result.RESULT_DOWNLOAD_FILE_WRITE_ERROR : "RESULT_DOWNLOAD_FILE_WRITE_ERROR",
			HTTPRequest.Result.RESULT_REDIRECT_LIMIT_REACHED : "RESULT_REDIRECT_LIMIT_REACHED",
			HTTPRequest.Result.RESULT_TIMEOUT : "RESULT_TIMEOUT",
		}
		return str_dict[result]


## Performs an awaitable HTTP request.
##[br]Usage:
##[codeblock]
##@export var http: AwaitableHTTPRequest
##
##func _ready() -> void:
##    var r := await http.async_request('https://api.github.com/users/swarkin')
##
##    if r.success:
##        print(r.status_code)              # 200
##        print(r.headers['Content-Type'])  # application/json
##        print(r.json['bio'])              # fox.
##[/codeblock]
func async_request(url:String, custom_headers:PackedStringArray = PackedStringArray(), method:HTTPClient.Method = HTTPClient.Method.METHOD_GET, request_body:String = '') -> HTTPResult:
	is_requesting = true

	var e := request(url, custom_headers, method, request_body)
	if e:
		return HTTPResult._from_error(e)

	@warning_ignore('unsafe_cast')
	var result := await request_completed as Array

	is_requesting = false
	request_finished.emit()

	return HTTPResult._from_array(result)
