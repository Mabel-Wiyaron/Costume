//
//  AppleIntelligenceService.swift
//  Costume
//
//  Created by Saujana Shafi on 13/07/26.
//

import Foundation
import FoundationModels

struct AppleIntelligenceService: LanguageModelProtocol {
    var instructions: String
    var temperature: Double

    init(instructions: String = "", temperature: Double = 0.5) {
        self.instructions = instructions
        self.temperature = temperature
    }

    private func getSession() async throws -> LanguageModelSession {
        return LanguageModelSession(
            model: SystemLanguageModel(),
            instructions: self.instructions
        )
    }

    func invoke(for message: String) async throws -> String {
        return try await self.getSession().respond(
            to: message,
            options: .init(temperature: self.temperature)
        ).content
    }

    func generate<Content>(content type: Content.Type, for message: String)
        async throws -> Content where Content: Generable & Decodable
    {
        return try await self.getSession().respond(
            to: message,
            generating: type,
            options: .init(temperature: self.temperature)
        )
        .content
    }

    func generate(schema: GenerationSchema, for message: String) async throws
        -> GeneratedContent
    {
        return try await self.getSession().respond(
            to: message,
            schema: schema,
            options: .init(temperature: self.temperature)
        )
        .content
    }
}
