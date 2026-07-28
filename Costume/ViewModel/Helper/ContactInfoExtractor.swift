//
//  ContactInfoExtractor.swift
//  Costume
//
//  Created by William Constantine Jioe on 28/07/26.
//

import Foundation
import NaturalLanguage

struct ExtractedContactInfo {
    let email: String?
    let phone: String?
    let linkedin: String?
    let github: String?
    let website: String?
    let city: String?
    let region: String?  // country/state
}

enum ContactInfoExtractor {

    private static let emailPattern = #"[\w.+-]+@[\w-]+\.[\w.-]+"#
    private static let phonePattern = #"\+?[\d][\d\s().-]{6,}\d"#
    private static let linkedinPattern = #"(?:https?://)?(?:www\.)?linkedin\.com/\S+"#
    private static let githubPattern = #"(?:https?://)?(?:www\.)?github\.com/\S+"#
    // Bare domain, excluding linkedin/github (handled separately above)
    // and not preceded by "@" (so it won't re-match the email's domain).
    private static let websitePattern = #"(?<!@)\b(?:https?://)?(?:www\.)?(?!linkedin\.com|github\.com)[\w-]+\.(?:com|net|org|io|dev|me|id|co)\b\S*"#

    static func extract(from text: String) -> ExtractedContactInfo {
        let email = firstMatch(of: emailPattern, in: text)
        let phone = firstMatch(of: phonePattern, in: text)
        let linkedin = firstMatch(of: linkedinPattern, in: text)
        let github = firstMatch(of: githubPattern, in: text)

        var remainder = text
        for token in [email, linkedin, github].compactMap({ $0 }) {
            remainder = remainder.replacingOccurrences(of: token, with: "")
        }
        let website = firstMatch(of: websitePattern, in: remainder)

        let header = headerBlock(from: text)
        let (city, region) = extractLocation(from: header)

        return ExtractedContactInfo(
            email: email, phone: phone, linkedin: linkedin,
            github: github, website: website,
            city: city, region: region
        )
    }

    /// Text before the first section heading, where contact/address info lives.
    /// Prevents job-location place names (e.g. "Nara, Japan") in the body
    /// from being mistaken for the person's home city/region.
    private static func headerBlock(from text: String) -> String {
        let sectionMarkers = ["SUMMARY", "EXPERIENCE", "WORK EXPERIENCE", "EDUCATION"]
        var endIndex = text.endIndex
        for marker in sectionMarkers {
            if let range = text.range(of: marker, options: .caseInsensitive),
               range.lowerBound < endIndex {
                endIndex = range.lowerBound
            }
        }
        let header = String(text[text.startIndex..<endIndex])
        return header.count > 500 ? String(header.prefix(500)) : header
    }

    /// Uses NaturalLanguage's NER to find place names, then classifies each
    /// as a recognized country (-> region) or not (-> city). Avoids needing
    /// a hardcoded gazetteer of cities, so it isn't limited to Indonesia.
    private static func extractLocation(from text: String) -> (city: String?, region: String?) {
        var placeNames: [String] = []
        let tagger = NLTagger(tagSchemes: [.nameType])
        tagger.string = text

        tagger.enumerateTags(
            in: text.startIndex..<text.endIndex,
            unit: .word,
            scheme: .nameType,
            options: [.omitWhitespace, .omitPunctuation, .joinNames]
        ) { tag, range in
            if tag == .placeName {
                placeNames.append(String(text[range]))
            }
            return true
        }

        guard !placeNames.isEmpty else { return (nil, nil) }

        let countryNames = Set(
            Locale.Region.isoRegions.compactMap {
                Locale(identifier: "en_US").localizedString(forRegionCode: $0.identifier)?.lowercased()
            }
        )

        let region = placeNames.first { countryNames.contains($0.lowercased()) }
        let city = placeNames.first { !countryNames.contains($0.lowercased()) } ?? placeNames.first

        return (city, region)
    }

    static func strippingContactInfo(from text: String, using info: ExtractedContactInfo) -> String {
        var result = text
        let literalTokens = [info.email, info.phone, info.linkedin, info.github, info.website].compactMap { $0 }
        for token in literalTokens {
            result = result.replacingOccurrences(of: token, with: " ")
        }

        // city/region are plain words, so use word-boundary matching to avoid
        // accidentally clipping a longer word that merely contains the same substring.
        for word in [info.city, info.region].compactMap({ $0 }) {
            let pattern = "\\b\(NSRegularExpression.escapedPattern(for: word))\\b"
            result = result.replacingOccurrences(of: pattern, with: " ", options: .regularExpression)
        }

        return cleanupPunctuation(result)
    }

    private static func cleanupPunctuation(_ text: String) -> String {
        // Turn every separator-like boundary into one marker character.
        let normalized = text.replacingOccurrences(
            of: #"[,|]|(?<=\s)-(?=\s)"#,
            with: "\u{0}",
            options: .regularExpression
        )

        let pieces = normalized
            .components(separatedBy: "\u{0}")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }

        return pieces.joined(separator: ", ")
    }

    private static func firstMatch(of pattern: String, in text: String) -> String? {
        guard let range = text.range(of: pattern, options: .regularExpression) else { return nil }
        let match = String(text[range]).trimmingCharacters(in: .whitespacesAndNewlines)
        return match.isEmpty ? nil : match
    }
}
