//
//  Skill.swift
//  Costume
//
//  Created by William Constantine Jioe on 10/07/26.
//

import Foundation
import SwiftData

@Model
final class Skill {
    @Attribute(.unique)
    var name: String

    init(name: String) {
        self.name = name
    }
}
