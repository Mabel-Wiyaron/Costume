//
//  Language.swift
//  Costume
//
//  Created by William Constantine Jioe on 10/07/26.
//

import Foundation
import SwiftData

@Model
final class Language {
    var name: String
    var proficiency: String

    init(
        name: String,
        proficiency: String
    ) {
        self.name = name
        self.proficiency = proficiency
    }
}
