class_name PycoEventDetails
extends Resource

@export var event_type:String
@export var application:String
@export var version:String
@export var platform:String
@export var user_id:String
@export var session_id:String
@export var value:Dictionary
@export var api_key:String


static func copy_default() -> PycoEventDetails:
	return PycoLog.default_event_details.duplicate()

func merge(event_details:PycoEventDetails) -> PycoEventDetails:
	for p in event_details.get_property_list():
		if p["usage"] & PROPERTY_USAGE_SCRIPT_VARIABLE:
			var value:Variant = event_details.get(p[&"name"])
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
