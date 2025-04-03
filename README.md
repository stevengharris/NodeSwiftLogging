# NodeSwiftLogging

Log to the node.js console directly or with a [SwiftLog](https://github.com/apple/swift-log) backend when using [NodeSwift](https://github.com/kabiroberai/node-swift).

If you're using [NodeSwift](https://github.com/kabiroberai/node-swift) to interact between Swift and node.js, understanding what is happening on the Swift side can be a challenge. NodeSwiftLogging provides two mechanisms to display messages from the Swift side in the node.js console.

### A Swift-equivalent of `console.log`

```
NodeConsole.log("This is a message from Swift.")
```

This approach is useful from any Swift code that has access to `NodeConsole` by importing `NodeSwiftLogging`. So, for example, you can use `NodeConsole.log` in code you put in `#NodeModule(exports:[])`. Most of your Swift code will be blissfully ignorant of NodeSwiftLogging or the fact that is it being executed from a node.js server. In this case, you can use the SwiftLog backend and invoke `Logger`. 

### Show [SwiftLog](https://github.com/apple/swift-log) messages in the node.js console

Just use the "normal" style of [SwiftLog](https://github.com/apple/swift-log) logging in your Swift code, with whatever `label` makes sense in the context of your Swift app:

```
import Logging
Logger(label: "NSLogger").info("This is a message from Swift.")
```

When (from your node app) you register the callback to be used by `NodeConsole`, it will optionally bootstrap SwiftLog's `LoggingSystem` to use the `NodeConsoleLogger` backend, Your existing calls to `Logger` (or the calls to it from libraries you use) will all show up in the node.js console, with no modifications to your Swift code.

## Installation and Set Up

You need to have node.js and npm installed.

You should already be using [node-swift](https://github.com/kabiroberai/node-swift) in a Swift package. That means you will have a project that includes both `Package.swift` and `package.json`. In your `Package.swift`, add `swift-log` and `NodeSwiftLogging` as package dependencies along with your existing dependencies (which will include `node-swift`). You can use the project in the `Example` directory as a model, which also uses both `NodeConsole.log` and `Logger` to write to the node console.

## Example

The `Example` directory contains a complete NodeSwift project that uses NodeSwiftLogging. Clone the repository or copy the files in it to your local file system, move into the `Example` directory, and then install and build the Module.node that is used by node.js and the corresponding Swift library:

```
npm install
```

The initial build will take a long time because of node-swift's dependency on [swift-syntax](https://github.com/swiftlang/swift-syntax). After installation, subsequent invocations of:

```
npm run build
```

will be quick to produce a new `Module.node` that can be used on the JavaScript side and a new Swift library with the Swift code from `Sources`.

### Testing NodeSwiftLogging

After `npm install` (or subsequently, `npm run build`) is complete, run node on the supplied `index.js`:

```
node index.js
```

This will produce:

```
$ node index.js
Registered the NodeConsole.logCallback
Swift> info: Invoked Logger(label: "NSLogger").info from Swift!
Swift> Invoked NodeConsole.log from Swift!
$
```
