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

    enum NodeSwiftLoggingError: Error {
        case console
        case logLevel
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
    /// If loggerLevel is set to a string that matches a Logger.Level, then the LoggingSystem will
    /// be set up to log to the NodeConsole using the NodeConsoleLogger. In that case, code -
    /// (including that executed in Swift libraries) using the `swift-log` function
    /// `Logger(label:"<whatever>").<loggerLevel>("<message>")` will
    /// show up in the node.js console.
    ///
    /// - Parameters:
    ///   - callback: The NodeFunction defined in node.js.
    ///   - loggerLevel: One of (in order) `trace`, `debug`, `info`, `notice`,
    ///     `warning`, `error`, or `critical`; else the `LoggingSystem` will
    ///     not be connected to the NodeConsole.
    @NodeActor
    @NodeMethod
    public func registerLogCallback(callback: NodeFunction) throws {
        NodeConsole.init(nodeQueue: nodeQueue, callback: callback)
    }

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
    private static var console: NodeConsole?
    
    /// Log a message in the node.js console using the `console` singleton that can be called
    /// from anywhere, since the `console.log` will be run on @NodeActor.
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
    ///         console.log("Swift> " + message)
    ///     });
    public func log(_ message: String) throws {
        try nodeQueue.run {
            try callback.call([message])
        }
    }
}
