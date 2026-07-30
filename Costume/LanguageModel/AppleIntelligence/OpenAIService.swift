//
//  OpenAIService.swift
//  Costume
//
//  Created by Saujana Shafi on 22/07/26.
//

import Foundation
import FoundationModels

// MARK: - Errors

enum OpenAIError: Error, LocalizedError {
    case noContent
    case invalidResponse

    var errorDescription: String? {
        switch self {
        case .noContent:
            return "The response did not contain any content."
        case .invalidResponse:
            return "Received an invalid response from the server."
        }
    }
}

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
        let responseFormat: ResponseFormat
        if var schema = try? SchemaBuilder.jsonSchema(for: type) {
            if let describing = type as? SchemaDescribing.Type {
                SchemaBuilder.enrichSchema(
                    &schema,
                    with: describing.propertyDescriptions
                )
            }
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
        request.timeoutInterval = 300

        let (data, _) = try await URLSession.shared.data(for: request)
        return try JSONDecoder().decode(ChatCompletionResponse.self, from: data)
    }
}

// MARK: - OpenAI API Models

struct ResponseFormat: Encodable {
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
