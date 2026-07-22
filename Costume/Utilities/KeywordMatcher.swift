import Foundation

struct KeywordMatcher {

    static func updateStatus(for keywords: [Keyword], using profile: Profile) {
        let corpus = buildCorpus(profile)

        for keyword in keywords {
            guard !keyword.name.isEmpty else { continue }
            let pattern = regexPattern(for: keyword.name)
            keyword.status = patternMatches(pattern, in: corpus) ? .included : .missing
        }
    }

    private static func regexPattern(for keyword: String) -> String {
        let escaped = NSRegularExpression.escapedPattern(for: keyword)
        let flexible = escaped
            .components(separatedBy: .whitespacesAndNewlines)
            .filter { !$0.isEmpty }
            .joined(separator: "\\s+")
        return "(?i)(?:^|(?<!\\w))" + flexible + "(?:$|(?!\\w))"
    }

    private static func patternMatches(_ pattern: String, in text: String) -> Bool {
        guard let regex = try? NSRegularExpression(pattern: pattern) else { return false }
        let range = NSRange(text.startIndex..., in: text)
        return regex.firstMatch(in: text, range: range) != nil
    }

    private static func buildCorpus(_ profile: Profile) -> String {
        var parts: [String] = []

        parts.append(profile.name)
        parts.append(profile.email)
        parts.append(profile.location)
        parts.append(profile.phone)

        if let summary = profile.summary { parts.append(summary) }

        for link in profile.links {
            parts.append(link.platform.rawValue)
            parts.append(link.url.absoluteString)
        }

        for exp in profile.experiences {
            parts.append(exp.role)
            parts.append(exp.company)
            parts.append(exp.location)
            parts.append(exp.employmentType.rawValue)
            parts.append(contentsOf: exp.descriptionText)
        }

        for edu in profile.educations {
            parts.append(edu.school)
            parts.append(edu.degree)
            parts.append(edu.fieldOfStudy)
        }

        for cert in profile.certifications {
            parts.append(cert.name)
            parts.append(cert.issuer)
            parts.append(cert.credentialID)
        }

        for project in profile.projects {
            parts.append(project.role)
            parts.append(project.name)
            parts.append(contentsOf: project.descriptionText)
        }

        for award in profile.awards {
            parts.append(award.title)
            parts.append(award.issuer)
        }

        for skill in profile.skills {
            parts.append(skill.name)
        }

        for lang in profile.languages {
            parts.append(lang.name)
            parts.append(lang.proficiency)
        }

        return parts.joined(separator: " ")
    }
}
