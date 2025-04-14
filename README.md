# NodeSwiftLogging

Log to the node.js console directly from Swift or log with a [SwiftLog](https://github.com/apple/swift-log) backend when using [NodeSwift](https://github.com/kabiroberai/node-swift).

If you're using [NodeSwift](https://github.com/kabiroberai/node-swift) to interact between Swift and node.js, it's helpful to have an easy way get information from Swift into the node console or to capture logging data from Swift in a node.js log. NodeSwiftLogging provides both of these mechanisms.

### A Swift-equivalent of `console.log`

```
NodeConsole.log("This is a message from Swift.")
```

This approach is useful from any Swift code that has access to `NodeConsole` by importing `NodeSwiftLogging`. So, for example, you can use `NodeConsole.log` in code you put in `#NodeModule(exports:[])`. However, it's likely that most of your Swift library code will be blissfully ignorant of NodeSwiftLogging or the fact that is it being executed from a node server. In this case, you can use the SwiftLog backend and invoke `Logger`. 

### Log [SwiftLog](https://github.com/apple/swift-log) data in node.js

Just use the "normal" style of [SwiftLog](https://github.com/apple/swift-log) logging in your Swift code, using the `NodeLogger.backend` instance:

```
let logger = NodeLogger.backend
logger.info("This is a message from Swift.")
```

To have `Logger` data show up in the node.js, you need to have access to the singleton `NodeLogger.backend` that is created when you instantiate the `NodeLogger` in node.js. If you have a library that uses SwiftLog, and that library provides an API to set the `Logger` instance, then you can pass `NodeLogger.backend` to it. Once you do that, existing calls to that `Logger` instance will all show up in node.js, with no modifications to your Swift code.

## Installation and Set Up

You need to have node.js and npm installed.

You should already be using [node-swift](https://github.com/kabiroberai/node-swift) in a Swift package. That means you will have a project that includes both `Package.swift` and `package.json`. In your `Package.swift`, add `swift-log` and `NodeSwiftLogging` as package and target dependencies along with your existing dependencies (which will include `node-swift`). 

You can use the project in the `Example` directory as a model for using NodeSwiftLogging. The example uses both `NodeConsole.log` and `Logger` to write to node.js. The example includes `index.js` that can be loaded into the node server. It shows how to access the `NodeConsole` and `NodeLogger` classes and Swift entry points from node.js. The discussion below follows what is illustrated in the example.

## Instantiating NodeConsole and specifying the callback for it

To use the `NodeConsole`, you *must* first instantiate it from node.js, passing a callback function. For example:

```
const { NodeConsole } = require('./.build/Module.node');
new NodeConsole((message) => {
    console.log(message);
});
```

Once you instantiate it from node.js, you can use the `NodeConsole.log(_ message: String)` method in Swift, which in turn will execute the callback you provided in node.js.

## Instantiating NodeLogger and specifying the callback for it

Instead of a string message, the callback for the `NodeLogger` is passed JSON that can be parsed to extract the data provided by SwiftLog. You can use that data to do whatever you want; for example, you might just log it to the console, or you could hook it into a node.js logging library like [Pino](https://github.com/pinojs/pino) or [Winston](https://github.com/winstonjs/winston). The [log data](https://apple.github.io/swift-log/docs/current/Logging/Protocols/LogHandler.html) from SwiftLog consists of:

    | `level`       | The log level the message was logged at.                                          |
    | `message`     | The message to log.                                                               |
    | `metadata`    | Optional [String : String] dictionary of metadata from logger and the log message.|
    | `source`      | The source where the log message originated, for example the logging module.      |
    | `file`        | The file the log message was emitted from.                                        |
    | `function`    | The function the log line was emitted from.                                       |
    | `line`        | The line the log message was emitted from.                                        |

A minimally useful callback for the `NodeLogger` would mirror the one for `NodeConsole`, but has to extract the `message` from the JSON. For example:

```
const { NodeLogger } = require('./.build/Module.node');
new NodeLogger((json) => {
    const data = JSON.parse(json);
    console.log(data.message);
});
```

See the example below for a more useful version that shows a timestamp, the `level`, and any `metadata` along with the `message`.

### Configuring the NodeLogger

The `NodeLogger.init` method accepts an *optional* configuration argument that allows you to control:

* The minimum log level to report ("debug" by default)
* The label used for the instance of `Logger` ("NodeSwiftLogger" by default)
* Any metadata to associate with the `Logger` instance (Swift `nil` by default)

For example, a custom configuration could consist of:

```
const loggingConfig = {
    level: "info",
    label: "MyLabel",
    metadata: {myKey : "myValue"}
}
```

and be passed in string form to the minimal `NodeLogger` we just set up as:

```
new NodeLogger((json) => {
    const data = JSON.parse(json);
    console.log(data.message);
}, JSON.stringify(loggingConfig));
```

## Example

The `Example` directory contains a complete NodeSwift project that uses NodeSwiftLogging. Clone the repository, move into the `Example` directory, and then install and build the `Module.node` that is used by node.js and the corresponding Swift library:

```
npm install
```

The initial install/build will take a long time because of node-swift's dependency on [swift-syntax](https://github.com/swiftlang/swift-syntax). After installation, subsequent invocations of:

```
npm run build
```

will be quick to produce a new `Module.node` that can be used from node.js and a new Swift library with the Swift code from `Sources`. NodeSwift places `Module.node` in the `.build` directory as a symlink that can be imported or required in JavaScript depending on your usage.

### Testing NodeSwiftLogging

The `index.js` file shows how to access the `Module.node` you just built. `Module.node` provides access to `NodeConsole`, `NodeLogger`, and the two Swift endpoints that were exported in `NodeModuleExports.swift`.

```
const { NodeConsole, testConsole, NodeLogger, testLogger } = require('./.build/Module.node');

// Instantiate the NodeConsole, passing the callback
new NodeConsole((message) => {
    console.log(message);
});

// Instantiate the NodeLogger, passing the callback
new NodeLogger(nsLogHandler)

// A callback function to parse the LogSwift json and log it to the console
function nsLogHandler(json) {
    const data = JSON.parse(json);
    const metadata = (data.metadata) ? JSON.stringify(data.metadata) + ' ' : '';
    const date = new Date();
    // CA, because the only sane way to show a timestamp is yyyy-mm-dd, not US style mm/dd/yyyy
    const timestamp = date.toLocaleDateString('en-CA') + ' ' + date.toLocaleTimeString('en-CA', { hour12: false });
    console.log(timestamp + ' [' + data.level.toUpperCase() + '] ' + metadata + data.message);
};

// Invoke the two test functions that execute and cause the callbacks to be invoked from Swift
testConsole();  // Invoked NodeConsole.log from Swift!
testLogger();   // <Local en-CA timestamp> [INFO] Invoked logger.info from Swift!
```

Run node on the supplied `index.js`:

```
node index.js
```

This will produce (with a specific timestamp):

```
$ node index.js
Invoked NodeConsole.log from Swift!
2025-04-14 14:55:11 [INFO] Invoked logger.info from Swift!
$
```
