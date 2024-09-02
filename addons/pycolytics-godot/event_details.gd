class_name PycoEvent
extends Resource

@export var event_type:String
@export var application:String
@export var version:String
@export var platform:String
@export var user_id:String
@export var session_id:String
@export var value:Dictionary
@export var api_key:String

static var default_event:PycoEvent = PycoEvent.new()  ## All auto-generated events are based on this instance.


## Creates a copy of the default event, use this with merge() to create customized events.
static func copy_default() -> PycoEvent:
	return default_event.duplicate()


## Overrides the fields of self with the non-empty fields of the parameter pyco_event
func merge(pyco_event:PycoEvent) -> PycoEvent:
	if pyco_event.event_type:
		event_type = pyco_event.event_type
	if pyco_event.application:
		application = pyco_event.application
	if pyco_event.version:
		version = pyco_event.version
	if pyco_event.platform:
		platform = pyco_event.platform
	if pyco_event.user_id:
		user_id = pyco_event.user_id
	if pyco_event.session_id:
		session_id = pyco_event.session_id
	if pyco_event.value:
		value = pyco_event.value
	if pyco_event.api_key:
		api_key = pyco_event.api_key
	return self


func to_json() -> String:
	var property_strings:PackedStringArray
	property_strings.append('"event_type":' + JSON.stringify(event_type))
	property_strings.append('"application":' + JSON.stringify(application))
	property_strings.append('"version":' + JSON.stringify(version))
	property_strings.append('"platform":' + JSON.stringify(platform))
	property_strings.append('"user_id":' + JSON.stringify(user_id))
	property_strings.append('"session_id":' + JSON.stringify(session_id))
	property_strings.append('"value":' + JSON.stringify(value))
	property_strings.append('"api_key":' + JSON.stringify(api_key))
	var json:String = "{" + ",".join(property_strings) + "}"
	return json
