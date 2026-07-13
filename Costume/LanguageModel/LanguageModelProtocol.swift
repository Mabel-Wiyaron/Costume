//
//  LanguageModelProtocol.swift
//  Costume
//
//  Created by Saujana Shafi on 13/07/26.
//

import Foundation
import FoundationModels

protocol LanguageModelProtocol {
    func invoke(for message: String) async throws -> String
    func generate<Content>(content type: Content.Type, for message: String)
        async throws -> Content where Content: Generable
    // TODO: Refine this reset method.
    // Might need mutating
    func reset()
}
