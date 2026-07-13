//
//  AppleIntelligenceService.swift
//  Costume
//
//  Created by Saujana Shafi on 13/07/26.
//

import Foundation
import FoundationModels

struct AppleIntelligenceService: LanguageModelProtocol {
    var session: LanguageModelSession

    private let instructions: String
    private let generationOptions: GenerationOptions

    init(instructions: String) {
        self.instructions = instructions
        self.session = LanguageModelSession(
            model: SystemLanguageModel(),
            instructions: instructions
        )
        self.generationOptions = .init()
    }

    func invoke(for message: String) async throws -> String {
        return try await self.session.respond(
            to: message,
            options: self.generationOptions
        ).content
    }
    func invoke<Content>(
        generating type: Content.Type = Content.self,
        @PromptBuilder prompt: () throws -> Prompt
    ) async throws -> LanguageModelSession.Response<Content>
    where Content: Generable {
        return try await self.session.respond(
            generating: type,
            prompt: prompt
        )
    }

    //    func invoke(for message: String, generating: any Generable.Type) {
    //        return try await self.session.respond(
    //            prompt: message,
    //            generating: generating.self
    //        ).content
    //    }

    func generate<Content>(content type: Content.Type, for message: String)
        async throws -> Content where Content: Generable
    {
        return try await self.session.respond(to: message, generating: type)
            .content
    }

    func generate(schema: GenerationSchema, for message: String) async throws
        -> GeneratedContent
    {
        return try await self.session.respond(to: message, schema: schema)
            .content
    }

    func reset() {
        // TODO: Reset the session
        // For now it could not mutate object
        // self.session = LanguageModelSession(instructions: self.instructions)
    }
}
