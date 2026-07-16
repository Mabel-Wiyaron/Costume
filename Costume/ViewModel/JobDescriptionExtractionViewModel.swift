//
//  JobDescriptionExtractionViewModel.swift
//  Costume
//
//  Created by Saujana Shafi on 15/07/26.
//

import Foundation

@Observable
final class JobDescriptionExtractionViewModel {
    private let agentService = JobDescriptionAgentService()

    func extract(from text: String) async throws -> JobDescriptionGenerable {
        return try await agentService.invoke(for: text)
    }
}
