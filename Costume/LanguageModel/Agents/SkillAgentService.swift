//
//  SkillAgentService.swift
//  Costume
//
//  Created by Saujana Shafi on 15/07/26.
//

import Foundation

struct SkillGenerable: Codable {
    let content: [String]
}

struct SkillAgentService: AgentProtocol {
    func invoke(for message: String) async throws -> SkillGenerable {
        let data = Data(message.utf8)

        return try JSONDecoder().decode(SkillGenerable.self, from: data)
    }
}
