//
//  MLXService.swift
//  Costume
//
//  Created by Saujana Shafi on 24/07/26.
//

import Foundation
import FoundationModels
import HuggingFace
import MLXHuggingFace
import MLXLLM
import MLXLMCommon
import SwiftUI
import Tokenizers

class MLXService: LanguageModelProtocol {

    enum State {
        case idle
        case loading(Task<ModelContainer, Error>)
        case loaded(ModelContainer)
    }

    var instructions: String
    var temperature: Double

    public var progress = 0.0
    public var isLoaded: Bool {
        switch state {
        case .idle, .loading: false
        case .loaded: true
        }
    }

    private var state = State.idle

    private let modelConfiguration = LLMRegistry.gemma3_1B_qat_4bit

    required init(instructions: String = "", temperature: Double = 0.5) {
        self.instructions = instructions
        self.temperature = temperature
    }

    func invoke(for message: String) async throws -> String {
        let messages: [Chat.Message] = [
            .init(role: .system, content: instructions),
            .init(role: .user, content: message)
        ]
        let response = try await getSession().respond(to: messages)

        return Self.sanitize(response)
    }

    func generate<Content>(content type: Content.Type, for message: String)
        async throws -> Content where Content: Generable, Content: Decodable
    {
        let propertyDescriptions = (type as? SchemaDescribing.Type)?.propertyDescriptions
        let responseFormatInstruction = try SchemaBuilder.responseFormatInstruction(
            for: type,
            propertyDescriptions: propertyDescriptions
        )

        let messages: [Chat.Message] = [
            .init(
                role: .system,
                content: instructions + "\n\n" + responseFormatInstruction + "\n\nRespond with JSON only, no other text."
            ),
            .init(role: .user, content: message),
        ]

        let response = try await getSession().respond(to: messages)
        
        print(response)

        let jsonData = Data(Self.sanitize(response).utf8)

        return try JSONDecoder().decode(Content.self, from: jsonData)
    }

    private static func sanitize(_ text: String) -> String {
        guard let startRange = text.range(of: "```"),
              let endRange = text.range(of: "```", range: startRange.upperBound..<text.endIndex)
        else {
            return text
        }
        var sanitized = String(text[startRange.upperBound..<endRange.lowerBound])
        if sanitized.hasPrefix("json") {
            sanitized = String(sanitized.dropFirst(4))
        }
        if sanitized.hasPrefix("\n") {
            sanitized = String(sanitized.dropFirst())
        }
        if sanitized.hasSuffix("\n") {
            sanitized = String(sanitized.dropLast())
        }
        return sanitized
    }

    private func loadModel() async throws -> ModelContainer {
        switch self.state {
        case .idle:
            let task = Task {
                // download and report progress
                try await #huggingFaceLoadModelContainer(
                    configuration: modelConfiguration
                ) { value in
                    Task { @MainActor in
                        self.progress = value.fractionCompleted
                    }
                }
            }
            self.state = .loading(task)
            let model = try await task.value

            self.state = .loaded(model)
            return model

        case .loading(let task):
            return try await task.value

        case .loaded(let model):
            return model
        }
    }
    
    private func unloadModel() {
        self.state = .idle
        
        
    }

    private func getSession() async throws -> ChatSession {
        return ChatSession(
            try await loadModel(),
            generateParameters: GenerateParameters(
                temperature: Float(temperature)
            )
        )
    }
}
