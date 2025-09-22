extends RefCounted

const DEFAULT_API_KEY := "I-am-an-unsecure-dev-key-REPLACE_ME"
const DEFAULT_SERVER_URL := "http://127.0.0.1:8000/"
const API_KEY_SETTING := &"addons/pycolytics/api_key"
const SERVER_URL_SETTING := &"addons/pycolytics/server_url"
const HASH_SALT_SETTING := &"addons/pycolytics/hash_salt"


static func init_defaults() -> void:
	init_setting(
		API_KEY_SETTING,
		DEFAULT_API_KEY,
		{
			"name": API_KEY_SETTING,
			"type": TYPE_STRING,
			"hint": PROPERTY_HINT_NONE,
			"doc": "API key to use when connecting to the server."
		}
	)

	if not ProjectSettings.has_setting(SERVER_URL_SETTING):
		ProjectSettings.set_setting(SERVER_URL_SETTING, DEFAULT_SERVER_URL)
	ProjectSettings.set_initial_value(SERVER_URL_SETTING, DEFAULT_SERVER_URL)
	ProjectSettings.set_as_basic(SERVER_URL_SETTING, true)
	ProjectSettings.add_property_info(
		{
			"name": SERVER_URL_SETTING,
			"type": TYPE_STRING,
			"hint": PROPERTY_HINT_NONE,
			"doc": "URL to a pycolytics server."
		}
	)
	init_setting(
		HASH_SALT_SETTING,
		("%x" % randi()).left(8),
		{
			"name": HASH_SALT_SETTING,
			"type": TYPE_STRING,
			"hint": PROPERTY_HINT_NONE,
			"doc": "Salt used to generate anonymised UserIDs. \
							Changing this will make it impossible to match with UserIDs created before the change."
		},
		false,
		false
	)

	var error: int = ProjectSettings.save()
	if error:
		push_error("Encountered error %d when saving project settings." % error)


static func init_setting(name: String, value: Variant, property_info: Dictionary = {}, basic: bool = true, set_initial: bool = true) -> void:
	if not ProjectSettings.has_setting(name):
		ProjectSettings.set_setting(name, value)
	if set_initial:
		ProjectSettings.set_initial_value(name, value)
	ProjectSettings.set_as_basic(name, basic)
	ProjectSettings.add_property_info(property_info)
