@tool
extends EditorPlugin

const AUTOLOAD_NAME = "PycoLog"
const DEFAULT_API_KEY := "I-am-an-unsecure-dev-key-REPLACE_ME"
const DEFAULT_SERVER_URL := "http://127.0.0.1:8000/"
const API_KEY_SETTING := &"addons/pycolytics/api_key"
const SERVER_URL_SETTING := &"addons/pycolytics/server_url"
const HASH_SALT_SETTING := &"addons/pycolytics/hash_salt"

func _enter_tree() -> void:
	if not ProjectSettings.has_setting(API_KEY_SETTING):
		ProjectSettings.set_setting(API_KEY_SETTING, DEFAULT_API_KEY)
	ProjectSettings.set_initial_value(API_KEY_SETTING, DEFAULT_API_KEY)
	ProjectSettings.set_as_basic(API_KEY_SETTING, true)
	ProjectSettings.add_property_info(
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

	if not ProjectSettings.has_setting(HASH_SALT_SETTING):
		ProjectSettings.set_setting(HASH_SALT_SETTING, ("%x" % randi()).left(8))
	ProjectSettings.set_as_basic(HASH_SALT_SETTING, false)
	ProjectSettings.add_property_info(
		{
			"name": HASH_SALT_SETTING,
			"type": TYPE_STRING,
			"hint": PROPERTY_HINT_NONE,
			"doc": "Salt used to generate anonymised UserIDs. \
							Changing this will make it impossible to match with UserIDs created before the change."
		}
	)

	var error: int = ProjectSettings.save()
	if error:
		push_error("Encountered error %d when saving project settings." % error)

	add_autoload_singleton(AUTOLOAD_NAME, "pyco_log.gd")


func _exit_tree() -> void:
	remove_autoload_singleton(AUTOLOAD_NAME)
