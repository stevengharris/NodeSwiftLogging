# NodeSwiftLogging

Log to the node.js console directly from Swift or with a [SwiftLog](https://github.com/apple/swift-log) backend when using [NodeSwift](https://github.com/kabiroberai/node-swift).

If you're using [NodeSwift](https://github.com/kabiroberai/node-swift) to interact between Swift and node.js, understanding what is happening on the Swift side can be a challenge. NodeSwiftLogging provides two mechanisms to display messages from the Swift side in the node console.

### A Swift-equivalent of `console.log`

```
NodeConsole.log("This is a message from Swift.")
```

This approach is useful from any Swift code that has access to `NodeConsole` by importing `NodeSwiftLogging`. So, for example, you can use `NodeConsole.log` in code you put in `#NodeModule(exports:[])`. However, most of your Swift library code will be blissfully ignorant of NodeSwiftLogging or the fact that is it being executed from a node server. In this case, you can use the SwiftLog backend and invoke `Logger`. 

### Show [SwiftLog](https://github.com/apple/swift-log) messages in the node console

Just use the "normal" style of [SwiftLog](https://github.com/apple/swift-log) logging in your Swift code, with whatever `label` makes sense in the context of your Swift app:

```
import Logging
Logger(label: "NodeSwiftLogger").info("This is a message from Swift.")
```

To have `Logger` messages show up in the node console, you need to bootstrap NodeSwiftLogging's SwiftLog backend from node.js. Once you do that, your existing calls to `Logger` (or the calls to it from libraries you use) will all show up in the node.js console, with no modifications to your Swift code.

## Installation and Set Up

You need to have node.js and npm installed.

You should already be using [node-swift](https://github.com/kabiroberai/node-swift) in a Swift package. That means you will have a project that includes both `Package.swift` and `package.json`. In your `Package.swift`, add `swift-log` and `NodeSwiftLogging` as package and target dependencies along with your existing dependencies (which will include `node-swift`). 

You can use the project in the `Example` directory as a model for using NodeSwiftLogging. The example uses both `NodeConsole.log` and `Logger` to write to the node console. The example includes `index.js` that can be loaded into the node server. It shows how to access the `NodeConsole` class and Swift entry points from node.js. The discussion below follows what is illustrated in the example.

## Registering the log callback to node.js

To use the `NodeConsole` or the `NodeConsoleLogger` backend, you *must* first call `registerLogCallback` from node.js, passing a callback function. To do this, you first need to get an instance of `NodeConsole`. For example:

```
const { NodeConsole } = require('./.build/Module.node');
const nodeConsole = new NodeConsole();
nodeConsole.registerLogCallback((message) => {
    console.log("Swift> " + message);   // Make it obvious this message came from Swift
});
```

## Bootstrapping the LoggingSystem backend

Optionally, you can tell the SwiftLog `LoggingSystem` to use the `NodeConsoleLogger` backend using the same NodeConsole instance you used to register the callback. You can pass the Logger.Level to use, or the NodeConsoleLogger will use a default of "debug" if you don't specify it. The string you pass from node.js must resolve properly to a SwiftLog Logger.Level value or an error will be thrown:

```
nodeConsole.bootstrapLoggingSystem("info");
```

If you don't bootstrap the `LoggingSystem` to set up the `NodeConsoleLogger` backend, then Swift calls to `Logger` will use whatever backend it is already using or its default, `StreamLogHandler.standardError`. The messages to `stderr` generally won't show up in the node console (although if you're running node.js from the command line you will still see them).

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

The `index.js` file shows how to access the `Module.node` you just built. `Module.node` provides access to `NodeConsole` and the two Swift endpoints that were exported in `NodeModuleExports.swift`.

```
const { NodeConsole, testLogger, testConsole } = require('./.build/Module.node');

const nodeConsole = new NodeConsole();

// Register the callback from Swift
nodeConsole.registerLogCallback((message) => {
    console.log("Swift> " + message);   // Make it obvious this message came from Swift
});
console.log("Registered the NodeConsole.logCallback");

// Bootstrap the SwiftLog LoggingSystem, showing logging of .info level or higher
nodeConsole.bootstrapLoggingSystem("info");
console.log("Bootstrapped the LoggingSystem");

// Invoke the two test functions that execute and use the callback registered above and
// the SwiftLog backend that was bootstrapped.
testLogger();   // Swift> info: Invoked Logger(label: "NodeSwiftLogger").info from Swift!
testConsole();  // Swift> Invoked NodeConsole.log from Swift!
```

Run node on the supplied `index.js`:

```
node index.js
```

This will produce:

```
$ node index.js
Registered the NodeConsole.logCallback
Bootstrapped the LoggingSystem
Swift> info: Invoked Logger(label: "NodeSwiftLogger").info from Swift!
Swift> Invoked NodeConsole.log from Swift!
$
```
