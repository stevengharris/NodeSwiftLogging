//
//  NodeLoggerConfig.swift
//  NodeSwiftLogging
//
//  Created by Steven Harris on 4/8/25.
//  Copyright © 2025 Steven Harris. All rights reserved.
//

import Logging
import Foundation

/// The logging configuration passed from node.js as JSON.
public struct NodeLoggerConfig: Decodable, Sendable {
    let level: Logger.Level
    let label: String
    let metadata: [String : String]
    
    /// Default values when not passed from node.js
    private static let defaultLevel: Logger.Level = .debug
    private static let defaultLabel = "NodeSwiftLogger"
    
    enum CodingKeys: String, CodingKey {
        case level
        case label
        case metadata
    }
    
    public init(level: Logger.Level, label: String, metadata: [String : String] = [:]) {
        self.level = level
        self.label = label
        self.metadata = metadata
    }

    /// Initialize from a Decoder, providing defaults for all missing values
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        level = try container.decodeIfPresent(Logger.Level.self, forKey: .level) ?? Self.defaultLevel
        label = try container.decodeIfPresent(String.self, forKey: .label) ?? Self.defaultLabel
        metadata = try container.decodeIfPresent([String : String].self, forKey: .metadata) ?? [:]
    }
    
    /// Return a NodeLoggerConfig decoded from the JSON passed from node.js.
    ///
    /// The defaults if not provided are level="debug" and label="NodeSwiftLogger"
    ///
    /// - Parameters:
    ///  - json: The JSON containing any/all of level, label, and metadata
    static func from(json: String?) throws -> NodeLoggerConfig {
        
        // Decode what was passed as JSON
        guard let data = json?.data(using: .utf8) else {
            // Always return a reasonable configuration
            return NodeLoggerConfig(level: defaultLevel, label: defaultLabel)
        }
        let decoder = JSONDecoder()
        let config = try decoder.decode(NodeLoggerConfig.self, from: data)
        
        // After decoding config, make sure the values passed are acceptable, else insert defaults
        let level = Logger.Level(rawValue: config.level.rawValue) ?? defaultLevel
        let label = config.label
        let metadata = config.metadata
        
        return NodeLoggerConfig(level: level, label: label, metadata: metadata)
    }
}
