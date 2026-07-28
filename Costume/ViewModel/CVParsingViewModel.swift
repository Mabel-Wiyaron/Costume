//
//  CVParsingViewModel.swift
//  Costume
//
//  Created by William Constantine Jioe on 24/07/26.
//

import Foundation
import SwiftData
import Observation

@Observable
final class CVParsingViewModel {
    var isProcessing = false
    var errorMessage: String? = nil
    
    private let agent = CVParsingAgentService()
    
    @MainActor
    func processDroppedCV(
        fileURL: URL,
        sandboxedProfile: Profile,
        masterProfile: Profile,
        childContext: ModelContext,
        mainContext: ModelContext
    ) async {
        isProcessing = true
        errorMessage = nil
        
        defer { isProcessing = false }
        
        do {
            // 1. Extract raw text
            let rawText = try await CVTextExtractor.extractText(from: fileURL)
            
            let contactInfo = ContactInfoExtractor.extract(from: rawText)
            let cleanedText = ContactInfoExtractor.strippingContactInfo(from: rawText, using: contactInfo)
//            print(cleanedText)
            // 2. Run Foundation Model Agent
            let dto = try await agent.invoke(for: cleanedText)
            
            // 3. Overwrite data in the child/sandbox context
            overwrite(profile: sandboxedProfile, with: dto, contactInfo: contactInfo, in: childContext)
            
            // 4. Overwrite data in the main context & save disk store
            overwrite(profile: masterProfile, with: dto, contactInfo: contactInfo, in: mainContext)
            
        } catch {
            self.errorMessage = error.localizedDescription
        }
    }

    // MARK: - SwiftData Master Profile Mapping

    @MainActor
    private func overwrite(profile: Profile, with generable: CVImportGenerable, contactInfo: ExtractedContactInfo, in context: ModelContext) {
        profile.name = generable.name
        profile.email = contactInfo.email ?? generable.email
        profile.phone = contactInfo.phone ?? generable.phone
        profile.location = combinedLocation(contactInfo: contactInfo, fallback: generable.location) ?? generable.location
        
        if let linkedinString = contactInfo.linkedin ?? generable.linkedin, let url = URL(string: linkedinString) {
            profile.linkedin = url
        } else {
            profile.linkedin = nil
        }
        
        if let websiteString = contactInfo.website ?? generable.website, let url = URL(string: websiteString) {
            profile.website = url
        } else {
            profile.website = nil
        }
        
        profile.summary = generable.summary
        
        // Clear & re-insert Experiences
        profile.experiences.forEach { context.delete($0) }
        profile.experiences.removeAll()
        generable.experiences.forEach { exp in
            let newExp = Experience(
                role: exp.role,
                employmentType: EmploymentType(rawValue: exp.employmentType ?? "") ?? .fullTime,
                company: exp.company,
                location: exp.location ?? "",
                startDate: parseDate(exp.startDate) ?? Date(),
                endDate: parseDate(exp.endDate),
                descriptionText: exp.descriptionText?.components(separatedBy: "\n") ?? []
            )
            context.insert(newExp)
            profile.experiences.append(newExp)
        }

        // Clear & re-insert Educations
        profile.educations.forEach { context.delete($0) }
        profile.educations.removeAll()
        generable.educations.forEach { edu in
            let newEdu = Education(
                school: edu.school,
                degree: edu.degree,
                fieldOfStudy: edu.fieldOfStudy ?? "",
                startDate: parseDate(edu.startDate) ?? Date(),
                endDate: parseDate(edu.endDate)
            )
            context.insert(newEdu)
            profile.educations.append(newEdu)
        }

        // Clear & re-insert Projects
        profile.projects.forEach { context.delete($0) }
        profile.projects.removeAll()
        generable.projects.forEach { proj in
            let newProj = Project(
                role: proj.role ?? "",
                name: proj.name,
                startDate: parseDate(proj.startDate) ?? Date(),
                endDate: parseDate(proj.endDate),
                descriptionText: proj.descriptionText
            )
            context.insert(newProj)
            profile.projects.append(newProj)
        }

        // Clear & re-insert Certifications
        profile.certifications.forEach { context.delete($0) }
        profile.certifications.removeAll()
        generable.certifications.forEach { cert in
            let newCert = Certification(
                name: cert.name,
                issuer: cert.issuer,
                issueDate: parseDate(cert.issueDate) ?? Date(),
                credentialID: cert.credentialID ?? ""
            )
            context.insert(newCert)
            profile.certifications.append(newCert)
        }

        // Clear & re-insert Awards
        profile.awards.forEach { context.delete($0) }
        profile.awards.removeAll()
        generable.awards.forEach { award in
            let newAward = Award(
                title: award.title,
                issuer: award.issuer,
                issueDate: parseDate(award.issueDate) ?? Date()
            )
            context.insert(newAward)
            profile.awards.append(newAward)
        }

        // Clear & re-insert Skills
        profile.skills.forEach { context.delete($0) }
        profile.skills.removeAll()
        generable.skills.forEach { skillName in
            let newSkill = Skill(name: skillName)
            context.insert(newSkill)
            profile.skills.append(newSkill)
        }

        // Clear & re-insert Languages
        profile.languages.forEach { context.delete($0) }
        profile.languages.removeAll()
        generable.languages.forEach { lang in
            let newLang = Language(name: lang.name, proficiency: lang.proficiency ?? "")
            context.insert(newLang)
            profile.languages.append(newLang)
        }
        
        do {
            try context.save()
        } catch {
            print("Failed to save context: \(error)")
        }
    }
    
    private func combinedLocation(contactInfo: ExtractedContactInfo, fallback: String?) -> String? {
        switch (contactInfo.city, contactInfo.region) {
        case let (city?, region?):
            return "\(city), \(region)"
        case let (city?, nil):
            return city
        case let (nil, region?):
            return region
        case (nil, nil):
            return fallback
        }
    }

    private func parseDate(_ dateString: String?) -> Date? {
        guard let dateString = dateString, !dateString.isEmpty else { return nil }
        
        let formatters: [DateFormatter] = [
            {
                let df = DateFormatter()
                df.dateFormat = "yyyy-MM"
                return df
            }(),
            {
                let df = DateFormatter()
                df.dateFormat = "yyyy"
                return df
            }()
        ]
        
        for formatter in formatters {
            if let date = formatter.date(from: dateString) {
                return date
            }
        }
        return nil
    }
}
