# pycolytics-godot
A Godot 4.x plugin for interfacing with pycolytics, a tiny, open source event logging webservice. By default it provides anonymized event logging with a single function call.

Pycolytics is tiny open source tool, allowing developers to start collecting software usage statistics with the least amount of hassle possible.

## Getting Started
- Install [pycolytics](https://github.com/KerekesDavid/pycolytics) on a local machine, or a remote server. 
- Install pycolytics-godot directly from the Godot asset store, or by copying the addons folder in this repository into your project root.
- Enable the pycolytics-godot under `ProjectSettings/Plugins`
- Use `PycoLog.log_event(...)` to log your events.