//
//  ProfileAgentService.swift
//  Costume
//
//  Created by Saujana Shafi on 14/07/26.
//

import Foundation

struct ProfileGenerable: Codable {
    let name: String
    let role: String
    let email: String
    let location: String
    let phone: String
    let link1: String
    let link2: String
    let link3: String
}

struct ProfileAgentService: AgentProtocol {
    func invoke(for message: String) async throws -> ProfileGenerable {
        let data = Data(message.utf8)

        return try JSONDecoder().decode(ProfileGenerable.self, from: data)
    }
}
