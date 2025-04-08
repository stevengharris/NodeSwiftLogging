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
    public func registerLogCallback(callback: NodeFunction, jsonConfig: String? = nil) throws {
        let config = try NodeSwiftLoggingConfig.from(json: jsonConfig)
        NodeConsole.init(nodeQueue: nodeQueue, callback: callback, config: config)
    }
}

/// A class that can be used to show a message in the node.js console via `NodeConsole.log`.
public struct NodeConsole: @unchecked Sendable {
    
    private let nodeQueue: NodeAsyncQueue
    private let callback: NodeFunction
    
    /// The singleton `NodeConsole`, which will be the same instance created in NodeConsoleFacade
    /// and used by the NodeConsoleLogger.
    @NodeActor
    fileprivate static var console: NodeConsole?

    @NodeActor
    public static var logger: Logger?

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
    fileprivate init(nodeQueue: NodeAsyncQueue, callback: NodeFunction, config: NodeSwiftLoggingConfig) {
        self.nodeQueue = nodeQueue
        self.callback = callback
        LoggingSystem.bootstrap(console: self, config: config)
        var logger = Logger(label: config.label)
        for (key, value) in config.metadata {
            logger[metadataKey: key] = Logger.MetadataValue.string(value)
        }
        Self.logger = logger
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
