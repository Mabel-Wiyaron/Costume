//
//  LanguageModelProtocol.swift
//  Costume
//
//  Created by Saujana Shafi on 13/07/26.
//

import Foundation
import FoundationModels

protocol LanguageModelProtocol {
    var instructions: String { get set }
    var temperature: Double { get set }

    init(instructions: String, temperature: Double)

    func invoke(for message: String) async throws -> String
    func generate<Content>(content type: Content.Type, for message: String)
        async throws -> Content where Content: Generable & Decodable
}
