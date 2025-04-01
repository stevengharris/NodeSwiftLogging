//
//  NodeConsoleLogger.swift
//  NSLogging
//
//  Modeled on https://github.com/vapor/console-kit/blob/main/Sources/ConsoleKitTerminal/Utilities/ConsoleLogger.swift
//
//  Created by Steven Harris on 3/31/25.
//  Copyright © 2025 Steven Harris. All rights reserved.
//

import Logging

/// Outputs logs to a `NodeConsole`.
public struct NodeConsoleLogger: LogHandler, Sendable {
    public let label: String
    
    /// See `LogHandler.metadata`.
    public var metadata: Logger.Metadata
    
    /// See `LogHandler.logLevel`.
    public var logLevel: Logger.Level
    
    /// The console that the messages will get logged to.
    public let console: NodeConsole
    
    /// Creates a new `ConsoleLogger` instance.
    ///
    /// - Parameters:
    ///   - label: Unique identifier for this logger.
    ///   - console: The console to log the messages to.
    ///   - level: The minimum level of message that the logger will output. This defaults to `.debug`, the lowest level.
    ///   - metadata: Extra metadata to log with the message. This defaults to an empty dictionary.
    public init(label: String, console: NodeConsole, level: Logger.Level = .debug, metadata: Logger.Metadata = [:]) {
        self.label = label
        self.metadata = metadata
        self.logLevel = level
        self.console = console
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
    /// For the NodeConsole, we are (for now) passing only the level and message.
    public func log(
        level: Logger.Level,
        message: Logger.Message,
        metadata: Logger.Metadata?,
        source: String,
        file: String,
        function: String,
        line: UInt
    ) {
        try? console.log("\(level): \(message.description)")
    }
}

extension LoggingSystem {
    /// Bootstraps a `NodeConsoleLogger` to the `LoggingSystem`, so that logger will be used in `Logger.init(label:)`.
    ///
    ///     LoggingSystem.bootstrap(console: console)
    ///
    /// - Parameters:
    ///   - console: The console the logger will log the messages to.
    ///   - level: The minimum level of message that the logger will output. This defaults to `.debug`.
    public static func bootstrap(
        console: NodeConsole,
        level: Logger.Level = .debug
    ) {
        self.bootstrap({ (label) in
            return NodeConsoleLogger(label: label, console: console, level: level)
        })
    }
    
}
