//
//  NodeConsoleLogger.swift
//  NodeSwiftLogging
//
//  A simplified LogHandler implementation loosely based on https://github.com/vapor/console-kit/blob/main/Sources/ConsoleKitTerminal/Utilities/ConsoleLogger.swift
//
//  Created by Steven Harris on 3/31/25.
//  Copyright © 2025 Steven Harris. All rights reserved.
//

import Logging
import Foundation

/// Outputs logs to a `NodeConsole`.
public struct NodeConsoleLogger: LogHandler, Sendable {
    
    public var logLevel: Logging.Logger.Level
    
    public let config: NodeSwiftLoggingConfig
    
    /// See `LogHandler.metadata`.
    public var metadata: Logger.Metadata
    
    /// The console that the messages will get logged to.
    public let console: NodeConsole
    
    /// Creates a new `ConsoleLogger` instance.
    ///
    /// - Parameters:
    ///   - console: The console to log the messages to.
    ///   - config: The NodeConsoleLoggingConfig holding the label, level, etc. Note
    ///                 that config can include metadata for the logger.
    public init(console: NodeConsole, config: NodeSwiftLoggingConfig) {
        self.console = console
        self.logLevel = config.level
        self.config = config
        self.metadata = (config.metadata as? Logger.Metadata) ?? [:]
    }
    
    /// See `LogHandler[metadataKey:]`.
    ///
    /// This just acts as a getter/setter for the `.metadata` property.
    public subscript(metadataKey key: String) -> Logger.Metadata.Value? {
        get { return self.metadata[key] }
        set { self.metadata[key] = newValue }
    }
    
    /// See `LogHandler.log(level:message:metadata:source:file:function:line:)`.
    ///
    /// The config.format controls the detail of message that is logged.
    public func log(
        level: Logger.Level,
        message: Logger.Message,
        metadata: Logger.Metadata?,
        source: String,
        file: String,
        function: String,
        line: UInt
    ) {
        switch config.format {
        case .minimum:
            // Log only the message
            try? console.log(message.description)
        case .medium:
            // Log the level, any metadata, and the message
            var string = "\(level):"
            for (key, value) in self.metadata {
                string += " \(key)=\"\(value)\""
            }
            if let metadata {
                for (key, value) in metadata {
                    string += " \(key)=\"\(value)\""
                }
            }
            string += " \(message.description)"
            try? console.log(string)
        case .maximum:
            // Log the UTC time along with everything we have access to
            var string = ISO8601DateFormatter().string(from: Date()) + " \(level):"
            for (key, value) in self.metadata {
                string += " \(key)=\"\(value)\""
            }
            if let metadata {
                for (key, value) in metadata {
                    string += " \(key)=\"\(value)\""
                }
            }
            string += " \(file)"
            string += " \(function)"
            string += " \(line)"
            string += " [\(source)] \(message.description)"
            try? console.log(string)
        }
        
    }
}

extension LoggingSystem {
    
    /// Bootstraps a `NodeConsoleLogger` to the `LoggingSystem`, so that logger will be used in `Logger.init(label:)`.
    ///
    ///     LoggingSystem.bootstrap(console: console, config: config)
    ///
    /// - Parameters:
    ///   - console: The console the logger will log the messages to.
    ///   - config: The NodeSwiftLoggingConfig that was originally passed from node.js as JSON.
    public static func bootstrap(
        console: NodeConsole,
        config: NodeSwiftLoggingConfig
    ) {
        self.bootstrap({ (label) in
            return NodeConsoleLogger(console: console, config: config)
        })
    }
    
}
