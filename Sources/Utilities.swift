//
//  Utilities.swift
//  NodeSwiftLogging
//
//  Created by Steven Harris on 4/8/25.
//  Copyright © 2025 Steven Harris. All rights reserved.
//

import Logging
import Foundation

/// The logging configuration passed from node.js as JSON.
public struct NodeSwiftLoggingConfig: Decodable, Sendable {
    let level: Logger.Level
    let label: String
    let format: NodeSwiftLoggingFormat
    let metadata: [String : String]
    
    /// Default values when not passed from node.js
    private static let defaultLevel: Logger.Level = .debug
    private static let defaultLabel = "NodeSwiftLogging"
    private static let defaultFormat: NodeSwiftLoggingFormat = .medium
    
    enum CodingKeys: String, CodingKey {
        case level
        case label
        case format
        case metadata
    }
    
    public init(level: Logger.Level, label: String, format: NodeSwiftLoggingFormat, metadata: [String : String] = [:]) {
        self.level = level
        self.label = label
        self.format = format
        self.metadata = metadata
    }

    /// Initialize from a Decoder, providing defaults for all missing values
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        level = try container.decodeIfPresent(Logger.Level.self, forKey: .level) ?? Self.defaultLevel
        label = try container.decodeIfPresent(String.self, forKey: .label) ?? Self.defaultLabel
        format = try container.decodeIfPresent(NodeSwiftLoggingFormat.self, forKey: .format) ?? Self.defaultFormat
        metadata = try container.decodeIfPresent([String : String].self, forKey: .metadata) ?? [:]
    }
    
    /// Return a NodeSwiftLoggingConfig decoded from the JSON passed from node.js.
    ///
    /// The defaults if not provided are level="debug" and label="NodeSwiftLogging"
    ///
    /// - Parameters:
    ///  - json: The JSON containing any/all of level, label, format, and metadata
    static func from(json: String?) throws -> NodeSwiftLoggingConfig {
        
        // Decode what was passed as JSON
        guard let data = json?.data(using: .utf8) else {
            // Always return a reasonable configuration
            return NodeSwiftLoggingConfig(level: defaultLevel, label: defaultLabel, format: defaultFormat)
        }
        let decoder = JSONDecoder()
        let config = try decoder.decode(NodeSwiftLoggingConfig.self, from: data)
        
        // After decoding config, make sure the values passed are acceptable, else insert defaults
        let level = Logger.Level(rawValue: config.level.rawValue) ?? defaultLevel
        let label = config.label
        let format = NodeSwiftLoggingFormat(rawValue: config.format.rawValue) ?? defaultFormat
        let metadata = config.metadata
        
        return NodeSwiftLoggingConfig(level: level, label: label, format: format, metadata: metadata)
    }
}

/// Named formats for log messages sent via the callback to the node.js console.
///
/// See NodeConsoleLogger.log(level:message:metadata:source:file:function:line:) for
/// details of message construction based on these formats.
public enum NodeSwiftLoggingFormat: String, Decodable, Sendable {
    case minimum
    case medium
    case maximum
}

/// Errors that might be thrown, which will be reported in the node.js console by node-swift.
public enum NodeSwiftLoggingError: Error {
    case console(String)
    case level(String)
}