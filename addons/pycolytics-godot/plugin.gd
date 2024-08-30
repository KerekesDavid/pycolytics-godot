@tool
extends EditorPlugin

const AUTOLOAD_NAME = "PycoLog"
const DEFAULT_API_KEY := "I-am-an-unsecure-dev-key-REPLACE_ME"
const DEFAULT_SERVER_URL := "http://127.0.0.1:8000/v1.0/events"


func _enter_tree():
	var setting_name := &"addons/pycolithics/api_key"
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
	
	setting_name = &"addons/pycolithics/server_url"
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
	
	var a = ProjectSettings.get_setting_with_override(&"addons/pycolithics/api_key")
	print(a)
	
	var error: int = ProjectSettings.save()
	if error: push_error("Encountered error %d when saving project settings." % error)
	
	add_autoload_singleton(AUTOLOAD_NAME, "pyco_log.gd")
	find_child(AUTOLOAD_NAME)._plugin = self


func _exit_tree():
	remove_autoload_singleton(AUTOLOAD_NAME)
