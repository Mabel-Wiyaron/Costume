//
//  LanguageAgentService.swift
//  Costume
//
//  Created by Saujana Shafi on 17/07/26.
//

import Foundation

struct LanguageGenerable: Codable {
    let name: String
    let proficiency: String
}

struct LanguageAgentService: AgentProtocol {
    func invoke(for message: String) async throws -> LanguageGenerable {
        let data = Data(message.utf8)

        return try JSONDecoder().decode(LanguageGenerable.self, from: data)
    }
}
