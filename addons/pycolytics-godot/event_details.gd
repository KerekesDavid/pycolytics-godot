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


## Creates a copy of the default event, use this with merge() to create customized events.
static func copy_default() -> PycoEvent:
	return PycoLog.default_event.duplicate()


## Overrides the fields of self with the non-empty fields of the parameter pyco_event
func merge(pyco_event:PycoEvent) -> PycoEvent:
	for p in pyco_event.get_property_list():
		if p["usage"] & PROPERTY_USAGE_SCRIPT_VARIABLE:
			var value:Variant = pyco_event.get(p[&"name"])
			match typeof(value):
				Variant.Type.TYPE_STRING:
					if value == '':
						continue
				Variant.Type.TYPE_OBJECT:
					if value == null:
						continue
				Variant.Type.TYPE_DICTIONARY:
					if value == {}:
						continue
			set(p[&"name"], value)
	return self


func to_json() -> String:
	var property_strings:PackedStringArray
	for p in get_property_list():
		if p["usage"] & PROPERTY_USAGE_SCRIPT_VARIABLE:
			property_strings.push_back(JSON.stringify(p[&"name"]) + ":" + JSON.stringify(get(p[&"name"])))
	var json:String = "{" + ", ".join(property_strings) + "}"
	return json
