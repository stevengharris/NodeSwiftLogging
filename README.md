# NSLogging

A [SwiftLog](https://github.com/apple/swift-log) backend for [NodeSwift](https://github.com/kabiroberai/node-swift).

If you're using [NodeSwift](https://github.com/kabiroberai/node-swift) to interact between Swift and node.js, understanding what is happening on the Swift side can be a challenge. NSLogger provides two mechanisms to display messages from the Swift side in the node.js console.

### A Swift-equivalent of `console.log`

```
NodeConsole.log("This is a message from Swift.")
```

This approach is useful from any Swift code that has access to `NodeConsole`, which itself depends on NodeSwift's NodeAPI. So, for example, you can use `NodeConsole.log` in code you put in `#NodeModule(exports:[])`. However, most of your Swift code will be blissfully ignorant of NodeAPI or the fact that is it being executed from a node.js server. In this case, you can use the SwiftLog backend and invoke `Logger`. 

### Show [SwiftLog](https://github.com/apple/swift-log) messages in the node.js console

Just use the "normal" style of [SwiftLog](https://github.com/apple/swift-log) logging in your Swift code, with whatever `label` makes sense in the context of your Swift app:

```
import Logging
Logger(label: "NSLogger").info("This is a message from Swift.")
```

When (from your node app) you register the callback to be used by `NodeConsole`, it will optionally bootstrap SwiftLog's `LoggingSystem` to use the `NodeConsoleLogger` backend, Your existing calls to `Logger` (or the calls to it from libraries you use) will all show up in the node.js console, with no modifications to your Swift code.

## Installation and Set Up

You need to have node.js and npm installed.

You should already be using [node-swift](https://github.com/kabiroberai/node-swift) in a Swift package. That means you will have a project that includes both `Package.swift` and `package.json`. Add NSLogging as a dependency. 

## Example

The resulting `Package.swift` will look something like the one in the Example directory:

```
// swift-tools-version:5.9

import PackageDescription

let package = Package(
    name: "NSLoggingExample",
    platforms: [.macOS(.v14)],
    products: [
        .library(
            name: "NSLoggingExample",
            targets: ["NSLoggingExample"]
        ),
        .library(
            name: "Module",
            type: .dynamic,
            targets: ["NSLoggingExample"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/kabiroberai/node-swift.git", from: "1.3.0"),
        .package(url: "https://github.com/apple/swift-log.git", from: "1.0.0"),
        .package(url: "https://github.com/stevengharris/NSLogging.git", branch: "main"),
    ],
    targets: [
        .target(
            name: "NSLoggingExample",
            dependencies: [
                .product(name: "NodeAPI", package: "node-swift"),
                .product(name: "NodeModuleSupport", package: "node-swift"),
                .product(name: "Logging", package: "swift-log"),
                "NSLogging"
            ]
        )
    ]
)
```

Your `package.json` will look something like the one in the Example directory:

```
{
  "name": "nslogging-example",
  "version": "1.0.0",
  "description": "Example of using NSLogging",
  "main": "index.js",
  "scripts": {
    "install": "node-swift rebuild",
    "build": "node-swift build",
    "builddebug": "node-swift build --debug",
    "clean": "node-swift clean"
  },
  "author": "Steven G. Harris",
  "license": "CC0-1.0",
  "dependencies": {
    "node-swift": "https://github.com/kabiroberai/node-swift.git"
  }
}
```

Install the node dependencies and build the node Module:

```
npm install
```

The initial build will take a long time because of node-swift's dependency on [swift-syntax](https://github.com/swiftlang/swift-syntax). After installation, subsequent invocations of:

```
npm run build
```

will be quick to produce a new `Module.node` that can be used on the JavaScript side and a new package that can be consumed on the Swift side.

### Testing NSLogging

NSLogging itself is a NodeSwift package. You can build it and test that it's working.

Clone the NSLogging repository. After running (the long) `npm install` from the cloned repo, you can start up node.js on `index.js`:

```
node index.js
```

This will produce:

```
$ node index.js
Swift> info: Invoked Logger(label: "NSLogger").info from Swift!
Swift> Invoked NodeConsole.log from Swift!
$
```

## Using NSLogging

There is an example in the Example directory of the NSLogging repo, which is not part of the package.

### Swift

Expose NodeConsole as a #NodeModule export:

```
import NodeAPI
import NSLogging

#NodeModule(exports: [
    "NodeConsole": NodeConsoleFacade.deferredConstructor,
    // Your exports, but here are two examples:
    "testNodeConsole": try NodeFunction { _ in
        NodeConsole.log("Invoked NodeConsole.log from Swift!")
        return
    },
    "testLogger": try NodeFunction { _ in
        Logger(label: "NSLogger").info("Invoked Logger(label: \"NSLogger\").info from Swift!")
        return
    },
])
```

### Node.js

Use `import` to gain access to `NodeConsole` from `Module.node`, along with the other entry points you identified in Swift:

```
import { NodeConsole, testNodeConsole, testLogger } from './.build/Module.node';

// Register the callback from Swift, including SwiftLog Logger.info and higher messages
const nodeConsole = new NodeConsole();
nodeConsole.registerLogCallback((message) => {
    console.log("Swift> " + message);
}, "info");
```
and then execute your Swift code from node.js:

```
testLogger();
testNodeConsole();
```

which produces the following output in the node.js console:

```
Swift> info: Invoked Logger(label: "NSLogger").info from Swift!
Swift> Invoked NodeConsole.log from Swift!
```
