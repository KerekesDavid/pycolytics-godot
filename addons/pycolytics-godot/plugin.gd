@tool
extends EditorPlugin

const AUTOLOAD_NAME = "PycoLog"
const Settings = preload("settings.gd")


func _enter_tree() -> void:
	Settings.init_defaults()
	add_autoload_singleton(AUTOLOAD_NAME, "pyco_log.gd")


func _exit_tree() -> void:
	remove_autoload_singleton(AUTOLOAD_NAME)
