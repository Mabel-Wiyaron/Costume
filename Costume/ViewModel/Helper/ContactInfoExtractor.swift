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
    let streetAddress: String?
    let city: String?
    let region: String?  // country/state
}

enum ContactInfoExtractor {

    private static let emailPattern = #"[\w.+-]+@[\w-]+\.[\w.-]+"#
    private static let phonePattern = #"\+?[\d][\d\s().-]{6,}\d"#
    private static let linkedinPattern = #"(?:https?://)?(?:www\.)?linkedin\.com/\S+"#
    private static let githubPattern = #"(?:https?://)?(?:www\.)?github\.com/\S+"#
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

        // Strip already-known tokens from the header BEFORE parsing address/
        // city/region, so phone digits or the linkedin URL can't be
        // misread as part of a street address.
        var header = headerBlock(from: text)
        for token in [email, phone, linkedin, github, website].compactMap({ $0 }) {
            header = header.replacingOccurrences(of: token, with: "")
        }

        let (address, city, region) = extractLocationComponents(from: header)

        return ExtractedContactInfo(
            email: email, phone: phone, linkedin: linkedin,
            github: github, website: website,
            streetAddress: address, city: city, region: region
        )
    }

    /// Isolates the name/contact/address block. Works directly on the flat
    /// text since PDF extraction may produce zero newlines (the whole
    /// document as one continuous string). Bounded by the earliest of:
    /// a known section heading, or the first standalone "I" (professional
    /// summaries almost always open with "I am/I'm...", while name/address
    /// text never contains a bare "I"). Falls back to a hard character cap
    /// so it can never scan/return the entire document.
    private static func headerBlock(from text: String) -> String {
        let sectionMarkers = ["SUMMARY", "WORK EXPERIENCES", "WORK EXPERIENCE", "EXPERIENCE", "EDUCATION LEVEL", "EDUCATION"]
        var endIndex = text.endIndex

        for marker in sectionMarkers {
            let pattern = "\\b\(NSRegularExpression.escapedPattern(for: marker))\\b"
            if let range = text.range(of: pattern, options: [.regularExpression, .caseInsensitive]),
               range.lowerBound < endIndex {
                endIndex = range.lowerBound
            }
        }

        if let range = text.range(of: #"\bI\b"#, options: .regularExpression),
           range.lowerBound < endIndex {
            endIndex = range.lowerBound
        }

        let header = String(text[text.startIndex..<endIndex])
        return header.count > 300 ? String(header.prefix(300)) : header
    }

    /// True for a comma-separated segment that looks like a street/building
    /// address rather than a city or country — building codes, unit numbers,
    /// street prefixes, or any digit run. e.g. "Puri Surya Jaya B7/23", "Jl. Sudirman No. 5".
    private static func looksLikeStreetAddress(_ segment: String) -> Bool {
        let patterns = [
            #"[A-Za-z]\d+/\d+"#,           // "B7/23"
            #"(?i)\bNo\.?\s*\d+"#,          // "No. 12"
            #"(?i)\bJl\.?\s"#,               // "Jl. Sudirman"
            #"(?i)\b(?:Street|St\.|Road|Rd\.|Avenue|Ave\.|Block|Blok)\b"#,
            #"\d{2,}"#                       // any 2+ digit run (unit/building/postal numbers)
        ]
        return patterns.contains { segment.range(of: $0, options: .regularExpression) != nil }
    }

    /// True for a short, digit-free, "@"-free segment — the shape of a name
    /// ("WILLIAM CONSTANTINE JIOE"), which should never be parsed as an
    /// address/city/region even if NER fails to classify it separately.
    private static func isLikelyNameSegment(_ segment: String) -> Bool {
        guard !segment.contains("@"), segment.rangeOfCharacter(from: .decimalDigits) == nil else {
            return false
        }
        return segment.split(separator: " ").count <= 5
    }

    /// Splits the header into comma segments (treating any stray newlines
    /// as separators too), drops a leading name segment, then buckets the
    /// rest into street-address vs. city/region, running NER place-name
    /// detection only on the city/region segments.
    private static func extractLocationComponents(from header: String) -> (address: String?, city: String?, region: String?) {
        // 1. Normalize newlines, dashes used as separators, and commas into a standard delimiter
        let normalizedHeader = header
            .replacingOccurrences(of: "\n", with: ", ")
            .replacingOccurrences(of: #"\s*-\s*"#, with: ", ", options: .regularExpression)
        
        var segments = normalizedHeader.components(separatedBy: ",")
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .filter { !$0.isEmpty && $0.rangeOfCharacter(from: .letters) != nil }

        guard !segments.isEmpty else { return (nil, nil, nil) }

        // 2. Safely drop the name segment if it matches
        if isLikelyNameSegment(segments[0]) {
            segments.removeFirst()
        }

        var addressSegments: [String] = []
        var locationSegments: [String] = []
        for segment in segments {
            if looksLikeStreetAddress(segment) {
                addressSegments.append(segment)
            } else {
                locationSegments.append(segment)
            }
        }

        let address = addressSegments.isEmpty ? nil : addressSegments.joined(separator: ", ")
        let (city, region) = extractLocation(from: locationSegments.joined(separator: ", "))
        return (address, city, region)
    }

    /// Uses NaturalLanguage's NER to find place names, then classifies each
    /// as a recognized country (-> region) or not (-> city).
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

        let countryNames = Set(
            Locale.Region.isoRegions.compactMap {
                Locale(identifier: "en_US").localizedString(forRegionCode: $0.identifier)?.lowercased()
            }
        )

        if !placeNames.isEmpty {
            let region = placeNames.first { countryNames.contains($0.lowercased()) }
            let city = placeNames.first { !countryNames.contains($0.lowercased()) } ?? placeNames.first
            return (city, region)
        }

        // Fallback if NER finds nothing (e.g. small towns not in Apple's
        // gazetteer, like "Gedangan" or "Sidoarjo") — treat remaining
        // comma-separated words positionally: first as city, rest as region.
        let segments = text.components(separatedBy: ",")
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .filter { !$0.isEmpty }

        guard !segments.isEmpty else { return (nil, nil) }
        if segments.count == 1 { return (segments[0], nil) }
        return (segments.first, segments.last)
    }

    static func strippingContactInfo(from text: String, using info: ExtractedContactInfo) -> String {
        var result = text
        let literalTokens = [
            info.email, info.phone, info.linkedin, info.github,
            info.website, info.streetAddress
        ].compactMap { $0 }
        for token in literalTokens {
            result = result.replacingOccurrences(of: token, with: " ")
        }

        for word in [info.city, info.region].compactMap({ $0 }) {
            let pattern = "\\b\(NSRegularExpression.escapedPattern(for: word))\\b"
            result = result.replacingOccurrences(of: pattern, with: " ", options: .regularExpression)
        }

        return cleanupPunctuation(result)
    }

    private static func cleanupPunctuation(_ text: String) -> String {
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
