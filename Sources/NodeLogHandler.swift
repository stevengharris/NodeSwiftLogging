//
//  NodeLogHandler.swift
//  NodeSwiftLogging
//
//  Created by Steven Harris on 3/31/25.
//  Copyright © 2025 Steven Harris. All rights reserved.
//

import Logging

/// A SwiftLog backend that logs to node.js
public struct NodeLogHandler: LogHandler, Sendable {
    
    public var logLevel: Logging.Logger.Level
    
    public let config: NodeLoggerConfig
    
    /// See `LogHandler.metadata`.
    public var metadata: Logger.Metadata
    
    /// Creates a new `NodeLogHandler` instance.
    ///
    /// - Parameters:
    ///   - logger: The logger that can call back to node.js.
    ///   - config: The NodeLoggerConfig holding the label, level, etc. Note
    ///                 that config can include metadata for the logger.
    public init(config: NodeLoggerConfig) {
        self.logLevel = config.level
        self.config = config
        self.metadata = (config.metadata as? Logger.Metadata) ?? [:]
    }
    
    /// Add, remove, or change the logging metadata.
    ///
    /// - Note: A change in metadata must only affect this very `LogHandler`.
    ///
    /// - Parameters:
    ///    - metadataKey: The key for the metadata item
    public subscript(metadataKey key: String) -> Logger.Metadata.Value? {
        get { return self.metadata[key] }
        set { self.metadata[key] = newValue }
    }
    
    /// Called when `NodeLogHandler` must emit a log message. There is no need  to check if the
    /// `level` is above or below the configured `logLevel` as `Logger` already performed this
    /// check and determined that a message should be logged.
    ///
    /// The method merges the log handler's `metadata` (provided at instantiation time) with the `metadata`
    /// passed as a parameter in this method, so that the merged metadata is provided to node.js.
    ///
    /// - Parameters:
    ///     - level: The log level the message was logged at.
    ///     - message: The message to log. To obtain a `String` representation call `message.description`.
    ///     - metadata: The metadata associated to this log message.
    ///     - source: The source where the log message originated, for example the logging module.
    ///     - file: The file the log message was emitted from.
    ///     - function: The function the log line was emitted from.
    ///     - line: The line the log message was emitted from.
    public func log(
        level: Logger.Level,
        message: Logger.Message,
        metadata: Logger.Metadata?,
        source: String,
        file: String,
        function: String,
        line: UInt
    ) {
        // Consolidate the logging data into an Encodable type before passing on
        let loggerData = NodeLoggerData(
            level: level,
            message: message,
            metadata: entryMetadata(from: metadata),
            source: source,
            file: file,
            function: function,
            line: line
        )
        NodeLogger.log(loggerData)
    }
    
    /// Combine the `parameterMetadata` with the `metadata` provided at instantiation of this NodeLogHandler.
    private func entryMetadata(from parameterMetadata: Logger.Metadata?) -> Logger.Metadata? {
        if let parameterMetadata, !parameterMetadata.isEmpty {
            /// Merging both metadata dictionary, giving precedence to the parameter metadata during collisions.
            return metadata.merging(parameterMetadata) { $1 }
        } else if !metadata.isEmpty {
            return metadata
        } else {
            return nil
        }
    }

}
