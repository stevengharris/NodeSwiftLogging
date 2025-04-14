//
//  NodeLoggerData.swift
//  NodeSwiftLogging
//
//  Created by Steven Harris on 4/13/25.
//

import Logging
import Foundation

/// The SwiftLog logging data passed to node.js as JSON.
public struct NodeLoggerData: Encodable, Sendable {
    let level: Logger.Level
    let message: Logger.Message
    let metadata: Logger.Metadata?
    let source: String
    let file: String
    let function: String
    let line: UInt
    
    enum CodingKeys: String, CodingKey {
        case level
        case message
        case metadata
        case source
        case file
        case function
        case line
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(level, forKey: .level)
        try container.encode("\(message)", forKey: .message)
        try container.encode(dictionary(from: metadata), forKey: .metadata)
        try container.encode(source, forKey: .source)
        try container.encode(file, forKey: .file)
        try container.encode(function, forKey: .function)
        try container.encode(line, forKey: .line)
    }
    
    /// Return a JSON string representation of this NodeLoggerData instance
    public func json() -> String {
        let encoder = JSONEncoder()
        let data = try! encoder.encode(self)
        return String(data: data, encoding: .utf8)!
    }
    
    /// Return a [String:String] dictionary derived from the event Logger.Metadata or nil
    private func dictionary(from metadata: Logger.Metadata?) -> [String : String]? {
        guard let metadata else { return nil }
        let stringAny = unpackMetadata(.dictionary(metadata)) as! [String : Any]
        return stringAny.mapValues { "\($0)" }
    }

    /// Return a Logger.MetadataValue as Any if it is a String or StringConvertible.
    /// Ref: https://github.com/apple/swift-log/issues/81#issuecomment-510115511
    private func unpackMetadata(_ value: Logger.MetadataValue) -> Any {
        switch value {
        case .string(let value):
            return value
        case .stringConvertible(let value):
            return value
        case .array(let value):
            return value.map { unpackMetadata($0) }
        case .dictionary(let value):
            return value.mapValues { unpackMetadata($0) }
        }
    }

}
