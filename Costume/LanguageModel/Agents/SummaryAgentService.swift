//
//  SummaryAgentService.swift
//  Costume
//
//  Created by Saujana Shafi on 15/07/26.
//

import Foundation

struct SummaryGenerable: Codable {
    let content: String
}

struct SummaryAgentService: AgentProtocol {
    func invoke(for message: String) async throws -> SummaryGenerable {
        let data = Data(message.utf8)

        return try JSONDecoder().decode(SummaryGenerable.self, from: data)
    }
}
