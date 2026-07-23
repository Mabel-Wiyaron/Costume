//
//  OpenAIService.swift
//  Costume
//
//  Created by Saujana Shafi on 22/07/26.
//

import Foundation
import FoundationModels

struct OpenAIService: LanguageModelProtocol {
    var instructions: String
    var temperature: Double

    private let endpoint: URL
    private let apiKey: String
    private let model: String
    
    init(instructions: String = "", temperature: Double = 0.5) {
        self.instructions = instructions
        self.temperature = temperature

        self.endpoint = URL(string: "http://localhost:8081")!
        self.apiKey = ""
        self.model = "gpt-4o"
    }

    init(
        instructions: String = "",
        temperature: Double = 0.5,
        endpoint: URL = URL(string: "http://localhost:8081")!,
        apiKey: String = "",
        model: String = "gpt-4o"
    ) {
        self.instructions = instructions
        self.temperature = temperature

        self.endpoint = endpoint
        self.apiKey = apiKey
        self.model = model
    }

    func invoke(for message: String) async throws -> String {
        let body = ChatCompletionBody(
            model: model,
            messages: [
                .init(role: "system", content: instructions),
                .init(role: "user", content: message),
            ],
            responseFormat: nil,
            temperature: temperature
        )

        let response = try await performRequest(body: body)
        return try response.content
    }

    func generate<Content>(
        content type: Content.Type,
        for message: String
    ) async throws -> Content where Content: Generable & Decodable {

        // TODO: Find out a way to include the @Guide in the response format
        let responseFormat: ResponseFormat
        if let schema = try? jsonSchema(for: type) {
            responseFormat = .jsonSchema(
                JSONSchemaBody(
                    name: "\(type)",
                    strict: true,
                    schema: schema
                )
            )
        } else {
            responseFormat = .jsonObject
        }

        let body = ChatCompletionBody(
            model: model,
            messages: [
                .init(role: "system", content: instructions),
                .init(role: "user", content: message),
            ],
            responseFormat: responseFormat,
            temperature: temperature
        )

        let response = try await performRequest(body: body)
        let jsonString = try response.content
        let jsonData = Data(jsonString.utf8)

        return try JSONDecoder().decode(Content.self, from: jsonData)
    }

    private func performRequest(body: ChatCompletionBody) async throws
        -> ChatCompletionResponse
    {
        var request = URLRequest(
            url: endpoint.appendingPathComponent("chat/completions")
        )

        request.httpMethod = "POST"

        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(
            "Bearer \(apiKey)",
            forHTTPHeaderField: "Authorization"
        )

        request.httpBody = try JSONEncoder().encode(body)

        let (data, _) = try await URLSession.shared.data(for: request)
        return try JSONDecoder().decode(ChatCompletionResponse.self, from: data)
    }

    private func jsonSchema<T: Decodable>(for type: T.Type) throws
        -> JSONSchemaProperty
    {
        let instance = try T(from: PlaceholderDecoder())
        return try schemaProperty(for: instance)
    }

    private func schemaProperty(for value: Any) throws -> JSONSchemaProperty {
        let mirror = Mirror(reflecting: value)

        if mirror.displayStyle == .optional {
            if let child = mirror.children.first {
                let prop = try schemaProperty(for: child.value)
                // Return the same schema node but mark isRequired = false
                switch prop {
                case .string(let format, _, let enumValues):
                    return .string(
                        format: format,
                        isRequired: false,
                        enumValues: enumValues
                    )
                case .integer(_): return .integer(isRequired: false)
                case .number(_): return .number(isRequired: false)
                case .boolean(_): return .boolean(isRequired: false)
                case .null(_): return .null(isRequired: false)
                case .array(let items, _):
                    return .array(items: items, isRequired: false)
                case .object(
                    let properties,
                    let required,
                    let additionalProperties,
                    _
                ):
                    return .object(
                        properties: properties,
                        required: required,
                        additionalProperties: additionalProperties,
                        isRequired: false
                    )
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
                if prop.isRequired {
                    requiredKeys.append(label)
                }
                properties[label] = prop
            }

            return .object(
                properties: properties,
                required: requiredKeys.isEmpty ? nil : requiredKeys,
                additionalProperties: false,
                isRequired: true
            )
        }

        return .string()
    }

    private func arrayElementType(for value: Any) throws -> JSONSchemaProperty?
    {
        let mirror = Mirror(reflecting: value)
        guard let first = mirror.children.first else { return nil }
        return try schemaProperty(for: first.value)
    }

}

enum OpenAIError: Error {
    case noContent
    case invalidJSON
}

// MARK: - OpenAI API Models

private struct ChatCompletionBody: Encodable {
    let model: String
    let messages: [Message]
    let responseFormat: ResponseFormat?
    let temperature: Double

    enum CodingKeys: String, CodingKey {
        case model, messages, temperature
        case responseFormat = "response_format"
    }
}

private struct Message: Encodable {
    let role: String
    let content: String
}

private struct ResponseFormat: Encodable {
    let type: String
    let jsonSchema: JSONSchemaBody?

    enum CodingKeys: String, CodingKey {
        case type
        case jsonSchema = "json_schema"
    }

    static let jsonObject = ResponseFormat(type: "json_object", jsonSchema: nil)

    static func jsonSchema(_ body: JSONSchemaBody) -> ResponseFormat {
        ResponseFormat(type: "json_schema", jsonSchema: body)
    }
}

private struct JSONSchemaBody: Encodable {
    let name: String
    let strict: Bool
    let schema: JSONSchemaProperty
}

private indirect enum JSONSchemaProperty: Encodable {
    case string(
        format: String? = nil,
        isRequired: Bool = true,
        enumValues: [String]? = nil
    )
    case integer(isRequired: Bool = true)
    case number(isRequired: Bool = true)
    case boolean(isRequired: Bool = true)
    case null(isRequired: Bool = false)
    case array(items: JSONSchemaProperty?, isRequired: Bool = true)
    case object(
        properties: [String: JSONSchemaProperty],
        required: [String]?,
        additionalProperties: Bool?,
        isRequired: Bool = true
    )

    // Convenience to access isRequired uniformly
    var isRequired: Bool {
        switch self {
        case .string(_, let isRequired, _): return isRequired
        case .integer(let isRequired): return isRequired
        case .number(let isRequired): return isRequired
        case .boolean(let isRequired): return isRequired
        case .null(let isRequired): return isRequired
        case .array(_, let isRequired): return isRequired
        case .object(_, _, _, let isRequired): return isRequired
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case .string(let format, _, let enumValues):
            try container.encode("string", forKey: .type)
            if let format { try container.encode(format, forKey: .format) }
            if let enumValues {
                try container.encode(enumValues, forKey: .enumValues)
            }
        case .integer:
            try container.encode("integer", forKey: .type)
        case .number:
            try container.encode("number", forKey: .type)
        case .boolean:
            try container.encode("boolean", forKey: .type)
        case .null:
            try container.encode("null", forKey: .type)
        case .array(let items, _):
            try container.encode("array", forKey: .type)
            if let items { try container.encode(items, forKey: .items) }
        case .object(let properties, let required, let additionalProperties, _):
            try container.encode("object", forKey: .type)
            try container.encode(properties, forKey: .properties)
            if let required, !required.isEmpty {
                try container.encode(required, forKey: .required)
            }
            if let additionalProperties {
                try container.encode(
                    additionalProperties,
                    forKey: .additionalProperties
                )
            }
        }
    }

    private enum CodingKeys: String, CodingKey {
        case type, properties, items, required, additionalProperties, format
        case enumValues = "enum"
    }

    // Factory initializers to maintain existing call sites
    init(
        type: String,
        properties: [String: JSONSchemaProperty]? = nil,
        items: JSONSchemaProperty? = nil,
        required: [String]? = nil,
        additionalProperties: Bool? = nil,
        enum: [String]? = nil,
        format: String? = nil,
        isRequired: Bool = true
    ) {
        switch type {
        case "string":
            self = .string(
                format: format,
                isRequired: isRequired,
                enumValues: `enum`
            )
        case "integer":
            self = .integer(isRequired: isRequired)
        case "number":
            self = .number(isRequired: isRequired)
        case "boolean":
            self = .boolean(isRequired: isRequired)
        case "null":
            self = .null(isRequired: isRequired)
        case "array":
            self = .array(items: items, isRequired: isRequired)
        case "object":
            self = .object(
                properties: properties ?? [:],
                required: required,
                additionalProperties: additionalProperties,
                isRequired: isRequired
            )
        default:
            self = .string(
                format: format,
                isRequired: isRequired,
                enumValues: `enum`
            )
        }
    }
}

private struct ChatCompletionResponse: Decodable {
    let choices: [Choice]

    var content: String {
        get throws {
            guard let content = choices.first?.message.content else {
                throw OpenAIError.noContent
            }
            return content
        }
    }
}

private struct Choice: Decodable {
    let message: MessageResponse
}

private struct MessageResponse: Decodable {
    let content: String?
}

// MARK: - Placeholder Decoder

private class PlaceholderDecoder: Decoder {
    var codingPath: [CodingKey] = []
    var userInfo: [CodingUserInfoKey: Any] = [:]

    func container<Key: CodingKey>(keyedBy type: Key.Type) throws
        -> KeyedDecodingContainer<Key>
    {
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
        try T(from: PlaceholderDecoder())
    }
}

private class PlaceholderKeyedDecoder<Key: CodingKey>:
    KeyedDecodingContainerProtocol
{
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
        try T(from: PlaceholderDecoder())
    }

    func nestedContainer<NestedKey: CodingKey>(
        keyedBy type: NestedKey.Type,
        forKey key: Key
    ) throws -> KeyedDecodingContainer<NestedKey> {
        KeyedDecodingContainer(PlaceholderKeyedDecoder<NestedKey>())
    }

    func nestedUnkeyedContainer(forKey key: Key) throws
        -> UnkeyedDecodingContainer
    {
        PlaceholderUnkeyedDecoder()
    }

    func superDecoder() throws -> Decoder { PlaceholderDecoder() }
    func superDecoder(forKey key: Key) throws -> Decoder {
        PlaceholderDecoder()
    }
}

private class PlaceholderUnkeyedDecoder: UnkeyedDecodingContainer {
    var codingPath: [CodingKey] = []
    var count: Int? { 1 }
    var isAtEnd: Bool { currentIndex >= 1 }
    var currentIndex: Int = 0

    func decodeNil() throws -> Bool {
        advance()
        return false
    }

    func decode(_ type: Bool.Type) throws -> Bool {
        advance()
        return false
    }
    func decode(_ type: String.Type) throws -> String {
        advance()
        return ""
    }
    func decode(_ type: Double.Type) throws -> Double {
        advance()
        return 0
    }
    func decode(_ type: Float.Type) throws -> Float {
        advance()
        return 0
    }
    func decode(_ type: Int.Type) throws -> Int {
        advance()
        return 0
    }
    func decode(_ type: Int8.Type) throws -> Int8 {
        advance()
        return 0
    }
    func decode(_ type: Int16.Type) throws -> Int16 {
        advance()
        return 0
    }
    func decode(_ type: Int32.Type) throws -> Int32 {
        advance()
        return 0
    }
    func decode(_ type: Int64.Type) throws -> Int64 {
        advance()
        return 0
    }
    func decode(_ type: UInt.Type) throws -> UInt {
        advance()
        return 0
    }
    func decode(_ type: UInt8.Type) throws -> UInt8 {
        advance()
        return 0
    }
    func decode(_ type: UInt16.Type) throws -> UInt16 {
        advance()
        return 0
    }
    func decode(_ type: UInt32.Type) throws -> UInt32 {
        advance()
        return 0
    }
    func decode(_ type: UInt64.Type) throws -> UInt64 {
        advance()
        return 0
    }

    func decode<T: Decodable>(_ type: T.Type) throws -> T {
        advance()
        return try T(from: PlaceholderDecoder())
    }

    func nestedContainer<NestedKey: CodingKey>(
        keyedBy type: NestedKey.Type
    ) throws -> KeyedDecodingContainer<NestedKey> {
        KeyedDecodingContainer(PlaceholderKeyedDecoder<NestedKey>())
    }

    func nestedUnkeyedContainer() throws -> UnkeyedDecodingContainer { self }

    func superDecoder() throws -> Decoder { PlaceholderDecoder() }

    private func advance() { currentIndex += 1 }
}
