//
//  AgentProtocol.swift
//  Costume
//
//  Created by Saujana Shafi on 13/07/26.
//

import Foundation

protocol AgentProtocol {
    associatedtype Content
    func invoke(for message: String) async throws -> Content
}
