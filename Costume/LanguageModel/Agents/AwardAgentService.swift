//
//  AwardAgentService.swift
//  Costume
//
//  Created by Saujana Shafi on 17/07/26.
//

import Foundation

struct AwardGenerable: Codable {
    let title: String
    let issuer: String
    let issueDate: String
}

struct AwardAgentService: AgentProtocol {
    func invoke(for message: String) async throws -> AwardGenerable {
        let data = Data(message.utf8)

        return try JSONDecoder().decode(AwardGenerable.self, from: data)
    }
}
