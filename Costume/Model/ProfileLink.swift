//
//  ProfileLink.swift
//  Costume
//
//  Created by William Constantine Jioe on 13/07/26.
//
import Foundation
import SwiftData

//enum LinkPlatform: String, Codable {
//    case github
//    case behance
//    case dribbble
//    case figma
//    case kaggle
//    case medium
//    case devto
//    case stackoverflow
//    case researchGate
//    case googleScholar
//    case x
//    case instagram
//    case youtube
//    case other
//}

@Model
final class ProfileLink {
    var platform: String //Change to LinkPlatform if already know what platform need to be
    var url: URL

    init(platform: String, url: URL) {
        self.platform = platform
        self.url = url
    }
}
