//
//  NodeConsole.swift
//  NodeSwiftLogging
//
//  Created by Steven Harris on 3/22/25.
//  Copyright © 2025 Steven Harris. All rights reserved.
//

import NodeAPI
import Logging

/// A facade for the NodeConsole class used in node.js.
@NodeClass public final class NodeConsoleFacade {

    /// Errors that might be thrown, which will be reported in the node.js console by node-swift.
    enum NodeSwiftLoggingError: Error {
        case console(String)
        case level(String)
    }
    
    /// The queue to run the callback on (see https://github.com/kabiroberai/node-swift/issues/17)
    private let nodeQueue: NodeAsyncQueue
    
    /// Initialize the `nodeQueue` callback queue when the instance is created on the node.js side.
    @NodeActor
    @NodeConstructor
    public init() throws {
        nodeQueue = try NodeAsyncQueue(label: "nodeConsoleQueue")
    }
    
    /// Initialize the NodeConsole singleton that will execute `callback` on `nodeQueue`.
    ///
    /// - Parameters:
    ///   - callback: The NodeFunction defined in node.js.
    @NodeActor
    @NodeMethod
    public func registerLogCallback(callback: NodeFunction) throws {
        NodeConsole.init(nodeQueue: nodeQueue, callback: callback)
    }

    /// Bootstrap the NodeConsoleLogger as the backend for SwiftLog.
    ///
    /// The NodeConsole instance must exist when this method is called or an error is thrown.
    /// This means you must call `registerLogCallback(callback:)` *before*
    /// `bootstrapLoggingSystem(loggerLevel:)`.
    ///
    /// The loggerLevel (passed as a String from node.js) must resolve to a Logger.Level or an
    /// error is thrown.
    ///
    /// - Parameters:
    ///   - loggerLevel: A string corresponding to one of the Logger.Levels. Default if not provided is "debug",
    ///   so all log messages will be shown.
    @NodeActor
    @NodeMethod
    public func bootstrapLoggingSystem(loggerLevel: String = "debug") throws {
        guard let console = NodeConsole.console  else {
            throw NodeSwiftLoggingError.console("No NodeConsole. Register log callback before bootstrapping LoggingSystem.")
        }
        guard let level = Logger.Level(rawValue: loggerLevel) else {
            throw NodeSwiftLoggingError.level("Invalid Logger level (\(loggerLevel)). See https://github.com/apple/swift-log.")
        }
        LoggingSystem.bootstrap(console: console, level: level)
    }

}

/// A class that can be used to show a message in the node.js console via `NodeConsole.log`.
public struct NodeConsole: Sendable {
    
    private let nodeQueue: NodeAsyncQueue
    private let callback: NodeFunction
    
    /// The singleton `NodeConsole`, which will be the same instance created in NodeConsoleFacade
    /// and used by the NodeConsoleLogger.
    @NodeActor
    fileprivate static var console: NodeConsole?
    
    /// Log a message in the node.js console using the `console` singleton that can be called
    /// from anywhere.
    ///
    /// The `console.log` will be run async on @NodeActor. Thus, `NodeConsole.log`
    /// messages may arrive in the node console after messages logged by the `NodeConsoleLogger`
    /// SwiftLog backend.
    public static func log(_ message: String) {
        Task { @NodeActor in
            try? console?.log(message)
        }
    }
    
    /// Initialize the NodeConsole singleton when the callback is registered from node.js.
    @NodeActor
    @discardableResult
    fileprivate init(nodeQueue: NodeAsyncQueue, callback: NodeFunction) {
        self.nodeQueue = nodeQueue
        self.callback = callback
        Self.console = self
    }
    
    /// Run the `callback` on the `nodeQueue`, passing the `message`.
    ///
    /// Note that the NodeConsoleLogger uses this instance method directly, since it holds onto the NodeConsole.
    ///
    /// The callback function defined in node.js when registering the callback will be called with the argument `message`.
    /// For example, in node.js, you would have done something like (where `NodeConsole` is imported from `Module.node`):
    ///
    ///     const nodeConsole = new NodeConsole();
    ///     nodeConsole.registerLogCallback((message) => {
    ///         console.log("Swift> " + message);
    ///     });
    public func log(_ message: String) throws {
        try nodeQueue.run {
            try callback.call([message])
        }
    }
}
