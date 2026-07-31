//
//  SchemaBuilder.swift
//  Costume
//
//  Created by Saujana Shafi on 22/07/26.
//

import Foundation

// MARK: - Schema Descriptions

protocol SchemaDescribing {
    static var propertyDescriptions: [String: String] { get }
}

// MARK: - OpenAI Schema Types

struct JSONSchemaBody: Encodable {
    let name: String
    let strict: Bool
    let schema: JSONSchemaProperty
}

indirect enum JSONSchemaProperty: Encodable {
    case string(
        format: String? = nil,
        isRequired: Bool = true,
        enumValues: [String]? = nil,
        description: String? = nil
    )
    case integer(isRequired: Bool = true, description: String? = nil)
    case number(isRequired: Bool = true, description: String? = nil)
    case boolean(isRequired: Bool = true, description: String? = nil)
    case null(isRequired: Bool = false, description: String? = nil)
    case array(
        items: JSONSchemaProperty?,
        isRequired: Bool = true,
        description: String? = nil
    )
    case object(
        properties: [String: JSONSchemaProperty],
        required: [String]?,
        additionalProperties: Bool?,
        isRequired: Bool = true,
        description: String? = nil
    )

    var isRequired: Bool {
        switch self {
        case .string(_, let isRequired, _, _): return isRequired
        case .integer(let isRequired, _): return isRequired
        case .number(let isRequired, _): return isRequired
        case .boolean(let isRequired, _): return isRequired
        case .null(let isRequired, _): return isRequired
        case .array(_, let isRequired, _): return isRequired
        case .object(_, _, _, let isRequired, _): return isRequired
        }
    }

    var description: String? {
        switch self {
        case .string(_, _, _, let description): return description
        case .integer(_, let description): return description
        case .number(_, let description): return description
        case .boolean(_, let description): return description
        case .null(_, let description): return description
        case .array(_, _, let description): return description
        case .object(_, _, _, _, let description): return description
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case .string(let format, _, let enumValues, let description):
            try container.encode("string", forKey: .type)
            if let format { try container.encode(format, forKey: .format) }
            if let enumValues { try container.encode(enumValues, forKey: .enumValues) }
            if let description { try container.encode(description, forKey: .description) }
        case .integer(_, let description):
            try container.encode("integer", forKey: .type)
            if let description { try container.encode(description, forKey: .description) }
        case .number(_, let description):
            try container.encode("number", forKey: .type)
            if let description { try container.encode(description, forKey: .description) }
        case .boolean(_, let description):
            try container.encode("boolean", forKey: .type)
            if let description { try container.encode(description, forKey: .description) }
        case .null(_, let description):
            try container.encode("null", forKey: .type)
            if let description { try container.encode(description, forKey: .description) }
        case .array(let items, _, let description):
            try container.encode("array", forKey: .type)
            if let items { try container.encode(items, forKey: .items) }
            if let description { try container.encode(description, forKey: .description) }
        case .object(let properties, let required, let additionalProperties, _, let description):
            try container.encode("object", forKey: .type)
            try container.encode(properties, forKey: .properties)
            if let required, !required.isEmpty { try container.encode(required, forKey: .required) }
            if let additionalProperties { try container.encode(additionalProperties, forKey: .additionalProperties) }
            if let description { try container.encode(description, forKey: .description) }
        }
    }

    private enum CodingKeys: String, CodingKey {
        case type, properties, items, required, additionalProperties, format, description
        case enumValues = "enum"
    }

    init(
        type: String,
        properties: [String: JSONSchemaProperty]? = nil,
        items: JSONSchemaProperty? = nil,
        required: [String]? = nil,
        additionalProperties: Bool? = nil,
        enum: [String]? = nil,
        format: String? = nil,
        isRequired: Bool = true,
        description: String? = nil
    ) {
        switch type {
        case "string":
            self = .string(format: format, isRequired: isRequired, enumValues: `enum`, description: description)
        case "integer":
            self = .integer(isRequired: isRequired, description: description)
        case "number":
            self = .number(isRequired: isRequired, description: description)
        case "boolean":
            self = .boolean(isRequired: isRequired, description: description)
        case "null":
            self = .null(isRequired: isRequired, description: description)
        case "array":
            self = .array(items: items, isRequired: isRequired, description: description)
        case "object":
            self = .object(properties: properties ?? [:], required: required, additionalProperties: additionalProperties, isRequired: isRequired, description: description)
        default:
            self = .string(format: format, isRequired: isRequired, enumValues: `enum`, description: description)
        }
    }
}

// MARK: - Schema Builder

struct SchemaBuilder {

    static func jsonSchema<T: Decodable>(for type: T.Type) throws -> JSONSchemaProperty {
        let instance = try T(from: PlaceholderDecoder())
        return try schemaProperty(for: instance)
    }

    static func responseFormatInstruction<T: Decodable>(
        for type: T.Type,
        propertyDescriptions: [String: String]? = nil
    ) throws -> String {
        let instance = try T(from: PlaceholderDecoder())
        let jsonObject = try reflectToJSONValue(instance)
        let data = try JSONSerialization.data(
            withJSONObject: jsonObject,
            options: [.prettyPrinted, .sortedKeys]
        )
        var result = String(data: data, encoding: .utf8) ?? "{}"
        if let descriptions = propertyDescriptions, !descriptions.isEmpty {
            let fields = descriptions.map { key, value in
                "  - \(key): \(value)"
            }.sorted().joined(separator: "\n")
            result += "\n\nField descriptions:\n\(fields)"
        }
        return result
    }

    private static func reflectToJSONValue(_ value: Any) throws -> Any {
        let mirror = Mirror(reflecting: value)
        if mirror.displayStyle == .optional {
            if let child = mirror.children.first {
                return try reflectToJSONValue(child.value)
            }
            return NSNull()
        }
        if let dict = value as? [String: Any] {
            var result: [String: Any] = [:]
            for (key, val) in dict {
                result[key] = try reflectToJSONValue(val)
            }
            return result
        }
        if let array = value as? [Any] {
            if array.isEmpty {
                return ["string"]
            }
            return try array.map { try reflectToJSONValue($0) }
        }
        if value is Int || value is Int8 || value is Int16 || value is Int32 || value is Int64
            || value is UInt || value is UInt8 || value is UInt16 || value is UInt32 || value is UInt64
        {
            return 0
        }
        if value is Float || value is Double || value is Float16 {
            return 0
        }
        if value is Bool {
            return false
        }
        if value is String {
            return "string"
        }
        if value is NSNumber {
            return 0
        }
        if value is NSString {
            return "string"
        }
        if mirror.displayStyle == .struct || mirror.displayStyle == .class {
            var result: [String: Any] = [:]
            for child in mirror.children {
                guard let label = child.label else { continue }
                result[label] = try reflectToJSONValue(child.value)
            }
            return result
        }
        if mirror.displayStyle == .enum {
            return String(describing: value)
        }
        return String(describing: value)
    }

    static func enrichSchema(
        _ schema: inout JSONSchemaProperty,
        with descriptions: [String: String]
    ) {
        guard case .object(let properties, let required, let additionalProperties, let isRequired, _) = schema
        else { return }

        var enriched: [String: JSONSchemaProperty] = [:]
        for (key, var prop) in properties {
            if let desc = descriptions[key] {
                setDescription(&prop, desc)
            }
            enriched[key] = prop
        }
        schema = .object(properties: enriched, required: required, additionalProperties: additionalProperties, isRequired: isRequired)
    }

    private static func setDescription(_ prop: inout JSONSchemaProperty, _ description: String) {
        switch prop {
        case .string(let format, let isRequired, let enumValues, _):
            prop = .string(format: format, isRequired: isRequired, enumValues: enumValues, description: description)
        case .integer(let isRequired, _):
            prop = .integer(isRequired: isRequired, description: description)
        case .number(let isRequired, _):
            prop = .number(isRequired: isRequired, description: description)
        case .boolean(let isRequired, _):
            prop = .boolean(isRequired: isRequired, description: description)
        case .null(let isRequired, _):
            prop = .null(isRequired: isRequired, description: description)
        case .array(let items, let isRequired, _):
            prop = .array(items: items, isRequired: isRequired, description: description)
        case .object(let properties, let required, let additionalProperties, let isRequired, _):
            prop = .object(properties: properties, required: required, additionalProperties: additionalProperties, isRequired: isRequired, description: description)
        }
    }

    private static func schemaProperty(for value: Any) throws -> JSONSchemaProperty {
        let mirror = Mirror(reflecting: value)

        if mirror.displayStyle == .optional {
            if let child = mirror.children.first {
                let prop = try schemaProperty(for: child.value)
                switch prop {
                case .string(let format, _, let enumValues, let description):
                    return .string(format: format, isRequired: false, enumValues: enumValues, description: description)
                case .integer(_, let description):
                    return .integer(isRequired: false, description: description)
                case .number(_, let description):
                    return .number(isRequired: false, description: description)
                case .boolean(_, let description):
                    return .boolean(isRequired: false, description: description)
                case .null(_, let description):
                    return .null(isRequired: false, description: description)
                case .array(let items, _, let description):
                    return .array(items: items, isRequired: false, description: description)
                case .object(let properties, let required, let additionalProperties, _, let description):
                    return .object(properties: properties, required: required, additionalProperties: additionalProperties, isRequired: false, description: description)
                }
            }
            return .null(isRequired: false)
        }

        let typeName = String(describing: type(of: value))

        switch typeName {
        case "String":
            return .string()
        case "Int", "Int8", "Int16", "Int32", "Int64":
            return .integer()
        case "UInt", "UInt8", "UInt16", "UInt32", "UInt64":
            return .integer()
        case "Double", "Float", "Float16", "Float32", "Float64":
            return .number()
        case "Bool":
            return .boolean()
        case "Date":
            return .string(format: "date-time")
        case "Data":
            return .string()
        default:
            break
        }

        if mirror.displayStyle == .collection {
            let elementType = try arrayElementType(for: value)
            return .array(items: elementType, isRequired: true)
        }

        if mirror.displayStyle == .struct || mirror.displayStyle == .class {
            var properties: [String: JSONSchemaProperty] = [:]
            var requiredKeys: [String] = []

            for child in mirror.children {
                guard let label = child.label else { continue }
                let prop = try schemaProperty(for: child.value)
                if prop.isRequired { requiredKeys.append(label) }
                properties[label] = prop
            }

            return .object(properties: properties, required: requiredKeys.isEmpty ? nil : requiredKeys, additionalProperties: false, isRequired: true)
        }

        return .string()
    }

    private static func arrayElementType(for value: Any) throws -> JSONSchemaProperty? {
        let mirror = Mirror(reflecting: value)
        guard let first = mirror.children.first else { return nil }
        return try schemaProperty(for: first.value)
    }
}

// MARK: - Placeholder Decoder

private class PlaceholderDecoder: Decoder {
    var codingPath: [CodingKey] = []
    var userInfo: [CodingUserInfoKey: Any] = [:]

    func container<Key: CodingKey>(keyedBy type: Key.Type) throws -> KeyedDecodingContainer<Key> {
        KeyedDecodingContainer(PlaceholderKeyedDecoder<Key>())
    }

    func unkeyedContainer() throws -> UnkeyedDecodingContainer {
        PlaceholderUnkeyedDecoder()
    }

    func singleValueContainer() throws -> SingleValueDecodingContainer {
        PlaceholderSingleValueDecoder()
    }
}

private class PlaceholderSingleValueDecoder: SingleValueDecodingContainer {
    var codingPath: [CodingKey] = []

    func decodeNil() -> Bool { false }
    func decode(_ type: Bool.Type) throws -> Bool { false }
    func decode(_ type: String.Type) throws -> String { "" }
    func decode(_ type: Double.Type) throws -> Double { 0 }
    func decode(_ type: Float.Type) throws -> Float { 0 }
    func decode(_ type: Int.Type) throws -> Int { 0 }
    func decode(_ type: Int8.Type) throws -> Int8 { 0 }
    func decode(_ type: Int16.Type) throws -> Int16 { 0 }
    func decode(_ type: Int32.Type) throws -> Int32 { 0 }
    func decode(_ type: Int64.Type) throws -> Int64 { 0 }
    func decode(_ type: UInt.Type) throws -> UInt { 0 }
    func decode(_ type: UInt8.Type) throws -> UInt8 { 0 }
    func decode(_ type: UInt16.Type) throws -> UInt16 { 0 }
    func decode(_ type: UInt32.Type) throws -> UInt32 { 0 }
    func decode(_ type: UInt64.Type) throws -> UInt64 { 0 }

    func decode<T: Decodable>(_ type: T.Type) throws -> T {
        do {
            return try T(from: PlaceholderDecoder())
        } catch {
            if let caseIterableType = T.self as? any CaseIterable.Type,
               let first = caseIterableType.allCases.first as? T
            {
                return first
            }
            throw error
        }
    }
}

private class PlaceholderKeyedDecoder<Key: CodingKey>: KeyedDecodingContainerProtocol {
    var codingPath: [CodingKey] = []
    var allKeys: [Key] { [] }

    func contains(_ key: Key) -> Bool { true }

    func decodeNil(forKey key: Key) throws -> Bool { false }
    func decode(_ type: Bool.Type, forKey key: Key) throws -> Bool { false }
    func decode(_ type: String.Type, forKey key: Key) throws -> String { "" }
    func decode(_ type: Double.Type, forKey key: Key) throws -> Double { 0 }
    func decode(_ type: Float.Type, forKey key: Key) throws -> Float { 0 }
    func decode(_ type: Int.Type, forKey key: Key) throws -> Int { 0 }
    func decode(_ type: Int8.Type, forKey key: Key) throws -> Int8 { 0 }
    func decode(_ type: Int16.Type, forKey key: Key) throws -> Int16 { 0 }
    func decode(_ type: Int32.Type, forKey key: Key) throws -> Int32 { 0 }
    func decode(_ type: Int64.Type, forKey key: Key) throws -> Int64 { 0 }
    func decode(_ type: UInt.Type, forKey key: Key) throws -> UInt { 0 }
    func decode(_ type: UInt8.Type, forKey key: Key) throws -> UInt8 { 0 }
    func decode(_ type: UInt16.Type, forKey key: Key) throws -> UInt16 { 0 }
    func decode(_ type: UInt32.Type, forKey key: Key) throws -> UInt32 { 0 }
    func decode(_ type: UInt64.Type, forKey key: Key) throws -> UInt64 { 0 }

    func decode<T: Decodable>(_ type: T.Type, forKey key: Key) throws -> T {
        do {
            return try T(from: PlaceholderDecoder())
        } catch {
            if let caseIterableType = T.self as? any CaseIterable.Type,
               let first = caseIterableType.allCases.first as? T
            {
                return first
            }
            throw error
        }
    }

    func nestedContainer<NestedKey: CodingKey>(keyedBy type: NestedKey.Type, forKey key: Key) throws -> KeyedDecodingContainer<NestedKey> {
        KeyedDecodingContainer(PlaceholderKeyedDecoder<NestedKey>())
    }

    func nestedUnkeyedContainer(forKey key: Key) throws -> UnkeyedDecodingContainer {
        PlaceholderUnkeyedDecoder()
    }

    func superDecoder() throws -> Decoder { PlaceholderDecoder() }
    func superDecoder(forKey key: Key) throws -> Decoder { PlaceholderDecoder() }
}

private class PlaceholderUnkeyedDecoder: UnkeyedDecodingContainer {
    var codingPath: [CodingKey] = []
    var count: Int? { 1 }
    var isAtEnd: Bool { currentIndex >= 1 }
    var currentIndex: Int = 0

    func decodeNil() throws -> Bool { advance(); return false }
    func decode(_ type: Bool.Type) throws -> Bool { advance(); return false }
    func decode(_ type: String.Type) throws -> String { advance(); return "" }
    func decode(_ type: Double.Type) throws -> Double { advance(); return 0 }
    func decode(_ type: Float.Type) throws -> Float { advance(); return 0 }
    func decode(_ type: Int.Type) throws -> Int { advance(); return 0 }
    func decode(_ type: Int8.Type) throws -> Int8 { advance(); return 0 }
    func decode(_ type: Int16.Type) throws -> Int16 { advance(); return 0 }
    func decode(_ type: Int32.Type) throws -> Int32 { advance(); return 0 }
    func decode(_ type: Int64.Type) throws -> Int64 { advance(); return 0 }
    func decode(_ type: UInt.Type) throws -> UInt { advance(); return 0 }
    func decode(_ type: UInt8.Type) throws -> UInt8 { advance(); return 0 }
    func decode(_ type: UInt16.Type) throws -> UInt16 { advance(); return 0 }
    func decode(_ type: UInt32.Type) throws -> UInt32 { advance(); return 0 }
    func decode(_ type: UInt64.Type) throws -> UInt64 { advance(); return 0 }

    func decode<T: Decodable>(_ type: T.Type) throws -> T {
        advance()
        do {
            return try T(from: PlaceholderDecoder())
        } catch {
            if let caseIterableType = T.self as? any CaseIterable.Type,
               let first = caseIterableType.allCases.first as? T
            {
                return first
            }
            throw error
        }
    }

    func nestedContainer<NestedKey: CodingKey>(keyedBy type: NestedKey.Type) throws -> KeyedDecodingContainer<NestedKey> {
        KeyedDecodingContainer(PlaceholderKeyedDecoder<NestedKey>())
    }

    func nestedUnkeyedContainer() throws -> UnkeyedDecodingContainer { self }
    func superDecoder() throws -> Decoder { PlaceholderDecoder() }

    private func advance() { currentIndex += 1 }
}
