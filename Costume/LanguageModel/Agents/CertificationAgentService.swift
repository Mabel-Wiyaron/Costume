//
//  CertificationAgentService.swift
//  Costume
//
//  Created by Saujana Shafi on 15/07/26.
//

import Foundation

struct CertificationGenerable: Codable {
    let name: String
    let issuer: String
    let issueDate: String
    let expirationDate: String?
    let credentialId: String
    let credentialUrl: String
    let skill: [String]
}

struct CertificationAgentService: AgentProtocol {
    func invoke(for message: String) async throws -> CertificationGenerable {
        let data = Data(message.utf8)

        return try JSONDecoder().decode(CertificationGenerable.self, from: data)
    }
}
