# pycolytics-godot
A Godot 4.3 plugin for interfacing with pycolytics, a tiny open source event logging webservice. By default it provides anonymized event logging with a single function call.

[Pycolytics](https://github.com/KerekesDavid/pycolytics) is a tiny open source tool, made to collect software usage statistics with the least amount of hassle possible.

## Getting Started
- Install [pycolytics](https://github.com/KerekesDavid/pycolytics) on a local machine, or a remote server. 
- Install this addon by copying the addons folder in this repository into your project root folder. (Coming to the Godot asset library soon!)
- Enable the pycolytics-godot under `ProjectSettings/Plugins`
- Use `PycoLog.log_event(...)` to log your events.

For more examples, see [examples/example.gd](example/example.gd), or open up [example.tscn](example/example.tscn) in Godot!

![The simplest way to log an event.](example_screenshot.png)

## Key Features
- __Event properties are resources:__ You can export them, reuse them, set them from the editor!
- __Automatic batched submission:__ Minimal performance impact.
- __Autoload included:__ For convinient logging.
- __Built-in startup and shutdown events.__ With customizable callbacks.
- __Automatic user-id and session-id generation.__


## Contibuting
Open an issue if you wish to contribute, or buy me a coffe if you find my work useful.

<a href='https://ko-fi.com/E1E712JJXK' target='_blank'><img height='36' style='border:0px;height:36px;' src='https://storage.ko-fi.com/cdn/kofi3.png?v=3' border='0' alt='Buy Me a Coffee at ko-fi.com' /></a>


## License
This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
