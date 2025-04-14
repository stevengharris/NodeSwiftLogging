//
//  NodeLogger.swift
//  NodeSwiftLogging
//
//  Created by Steven Harris on 3/22/25.
//  Copyright © 2025 Steven Harris. All rights reserved.
//

import NodeAPI
import Logging
import Foundation

/// The NodeLogger class used in node.js.
@NodeClass public final class NodeLogger {

    /// The singleton `NodeLogger`
    private static var nodeLogger: NodeLogger?

    /// A public property that provides access to the Logger instance or a default if it doesn't exist.
    ///
    /// If you have instantiated a NodeLogger and later want to use it via something like `logger.info`,
    /// then you can use `NodeLogger.backend.info` directly or pass `NodeLogger.backend` to
    /// your code or library that uses SwiftLog.
    public static var backend: Logger { nodeLogger?.logger ?? Logger(label: "DefaultNodeLogger") }

    /// The queue to run the callback on (see https://github.com/kabiroberai/node-swift/issues/17)
    private let nodeQueue: NodeAsyncQueue
    
    /// The NodeFunction that was passed from node.js when instantiating the NodeLogger.
    private let callback: NodeFunction

    /// The instance of Logger created when this NodeLogger was created from node.js, which has been bootstrapped to
    /// the NodeLogHandler. For convenience, it can be accessed using NodeLogger.backend.
    private let logger: Logger
    
    /// Create an instance of NodeLogger, keeping that instance in a static singleton `nodeLogger`.
    ///
    /// The NodeLogger instance is accessed via standard SwiftLog functionality on `NodeLogger.backend`,
    /// the only public access to NodeLogger other than `init`.
    ///
    /// We also initialize the `nodeQueue` callback queue to use for async calls back into node.js
    /// from anywhere.
    ///
    ///- Parameters:
    ///  - callback: The NodeFunction you provided from node.js. For example, in node.js, you
    ///              would have done something like this (where `NodeLogger` is imported from
    ///              `Module.node`):
    ///
    ///         NodeLogger( (message) => {
    ///             console.log(message);
    ///         });
    ///  - jsonConfig: The JSON stringified NodeLoggerConfig from node.js if needed.
    @NodeActor
    @NodeConstructor
    init(callback: NodeFunction, jsonConfig: String? = nil) throws {
        nodeQueue = try NodeAsyncQueue(label: "nodeLoggerQueue")
        self.callback = callback
        let config = try NodeLoggerConfig.from(json: jsonConfig)
        LoggingSystem.bootstrap({ label in
            NodeLogHandler(config: config)
        })
        var logger = Logger(label: config.label)
        for (key, value) in config.metadata {
            logger[metadataKey: key] = Logger.MetadataValue.string(value)
        }
        self.logger = logger
        Self.nodeLogger = self
    }
    
    /// Pass the log data from provided by the Logger to node.js.
    ///
    /// This public method can be called from anywhere, since it runs a Task on a NodeActor using
    /// the singleton NodeLogger in `nodeLogger`.
    ///
    /// - Parameters:
    ///     - loggerData: The `NodeLoggerData` created when the NodeLogHandler was called
    public static func log(_ loggerData: NodeLoggerData) {
        Task { @NodeActor in
            try? nodeLogger?.log(loggerData)
        }
    }

    /// Execute the `callback` (provided to this NodeLogger at instantiation time) on the `nodeQueue`,
    /// passing all data from the Logger.
    ///
    /// Note that the Logger filtered messages for the `level` provided at instantiation time, so `level`
    /// identified here is at or higher-than that `level`.
    ///
    /// - Parameters:
    ///     - loggerData: The `NodeLoggerData` created when the NodeLogHandler was called
    private func log(_ loggerData: NodeLoggerData) throws {
        try nodeQueue.run {
            try callback.call([loggerData.json()])
        }
    }

}
