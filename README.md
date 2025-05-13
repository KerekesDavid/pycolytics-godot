# Pycolytics Godot Client - Event Analytics

A Godot plugin for interfacing with [pycolytics](https://github.com/KerekesDavid/pycolytics), a tiny, open source event logging webservice. It provides anonymized event logging with as little as a single function call.

_Requires Godot 4.4 or higher._

## Getting Started

- Install this plugin from the [asset library](https://godotengine.org/asset-library/asset/3292), or by copying the addons folder from this repository into your project root folder.
- Enable the plugin (`pycolytics-godot`) under `ProjectSettings/Plugins`.
- Install [pycolytics](https://github.com/KerekesDavid/pycolytics)
- Use the `PycoLog` autoload, for example `PycoLog.log_event(...)` to log your events.

For more examples, see [examples/example.gd](example/example.gd), or open up [example.tscn](example/example.tscn) in Godot!

![The simplest way to log an event.](screenshots/example_screenshot.png)

## Key Features

- **Events are resources:** You can export them, reuse them, set them from the editor!
- **Automatic user-id and session-id generation,** without requiring persistent storage.
- **Automatic batched submission:** Minimal performance impact.
- **Autoload included:** For convenient logging.
- **Built-in startup and shutdown events.** With customizable callbacks.

## Configuration for Production

To log to a remote server, set `addons/pycolytics/server_url` and `addons/pycolytics/api_key` under project settings.

## Contributing

Open an issue if you wish to contribute, or buy me a coffee if you find my work useful.

<a href='https://ko-fi.com/E1E712JJXK' target='_blank'><img height='36' style='border:0px;height:36px;' src='https://storage.ko-fi.com/cdn/kofi3.png?v=3' border='0' alt='Buy Me a Coffee at ko-fi.com' /></a>

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
