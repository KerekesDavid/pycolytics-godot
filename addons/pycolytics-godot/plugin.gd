@tool
extends EditorPlugin

const AUTOLOAD_NAME = "PycoLog"
const DEFAULT_API_KEY := "I-am-an-unsecure-dev-key-REPLACE_ME"
const DEFAULT_SERVER_URL := "http://127.0.0.1:8000/"


func _enter_tree() -> void:
	var setting_name := &"addons/pycolythics/api_key"
	EditorInterface.get_editor_settings()
	if not ProjectSettings.has_setting(setting_name):
		ProjectSettings.set_setting(setting_name, DEFAULT_API_KEY)
	ProjectSettings.set_initial_value(setting_name, DEFAULT_API_KEY)
	ProjectSettings.set_as_basic(setting_name, true)
	ProjectSettings.add_property_info({
		"name": setting_name,
		"type": TYPE_STRING,
		"hint": PROPERTY_HINT_NONE,
		"doc": "API key to use when connecting to the server."
	})
	
	setting_name = &"addons/pycolythics/server_url"
	if not ProjectSettings.has_setting(setting_name):
		ProjectSettings.set_setting(setting_name, DEFAULT_SERVER_URL)
	ProjectSettings.set_initial_value(setting_name, DEFAULT_SERVER_URL)
	ProjectSettings.set_as_basic(setting_name, true)
	ProjectSettings.add_property_info({
		"name": setting_name,
		"type": TYPE_STRING,
		"hint": PROPERTY_HINT_NONE,
		"doc": "URL to a pytholytics server."
	})
	
	var a = ProjectSettings.get_setting_with_override(&"addons/pycolythics/api_key")
	
	var error: int = ProjectSettings.save()
	if error: push_error("Encountered error %d when saving project settings." % error)
	
	add_autoload_singleton(AUTOLOAD_NAME, "pyco_log.gd")


func _exit_tree() -> void:
	remove_autoload_singleton(AUTOLOAD_NAME)
