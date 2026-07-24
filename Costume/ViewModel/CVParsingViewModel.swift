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
    
    /// Main entry point: Processes a dropped PDF file URL and overwrites the master profile
    @MainActor
    func processDroppedCV(fileURL: URL, masterProfile: Profile, modelContext: ModelContext) async {
        isProcessing = true
        errorMessage = nil
        
        defer { isProcessing = false }
        
        do {
            // 1. Extract text from PDF (PDFKit with Vision OCR fallback)
            let rawText = try await CVTextExtractor.extractText(from: fileURL)
            print(rawText)
            
            // 2. Invoke Foundation Model Agent
            let dto = try await agent.invoke(for: rawText)
            
            // 3. Map DTO onto master profile and save
            overwrite(masterProfile: masterProfile, with: dto, in: modelContext)
            
        } catch {
            self.errorMessage = error.localizedDescription
        }
    }

    // MARK: - SwiftData Master Profile Mapping

    @MainActor
    private func overwrite(masterProfile: Profile, with generable: CVImportGenerable, in context: ModelContext) {
        masterProfile.name = generable.name
        masterProfile.email = generable.email
        masterProfile.phone = generable.phone
        masterProfile.location = generable.location
        
        // Convert string representations to Swift URL objects
        if let linkedinString = generable.linkedin, let url = URL(string: linkedinString) {
            masterProfile.linkedin = url
        } else {
            masterProfile.linkedin = nil
        }
        
        if let websiteString = generable.website, let url = URL(string: websiteString) {
            masterProfile.website = url
        } else {
            masterProfile.website = nil
        }
        
        masterProfile.summary = generable.summary
        
        // Clear & overwrite Experiences
        masterProfile.experiences.forEach { context.delete($0) }
        masterProfile.experiences.removeAll()
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
            masterProfile.experiences.append(newExp)
        }
        
        // Clear & overwrite Educations
        masterProfile.educations.forEach { context.delete($0) }
        masterProfile.educations.removeAll()
        generable.educations.forEach { edu in
            let newEdu = Education(
                school: edu.school,
                degree: edu.degree,
                fieldOfStudy: edu.fieldOfStudy ?? "",
                startDate: parseDate(edu.startDate) ?? Date(),
                endDate: parseDate(edu.endDate)
            )
            masterProfile.educations.append(newEdu)
        }
        
        // Clear & overwrite Projects
        masterProfile.projects.forEach { context.delete($0) }
        masterProfile.projects.removeAll()
        generable.projects.forEach { proj in
            let newProj = Project(
                role: proj.role ?? "",
                name: proj.name,
                startDate: parseDate(proj.startDate) ?? Date(),
                endDate: parseDate(proj.endDate),
                descriptionText: proj.descriptionText
            )
            masterProfile.projects.append(newProj)
        }
        
        // Clear & overwrite Certifications
        masterProfile.certifications.forEach { context.delete($0) }
        masterProfile.certifications.removeAll()
        generable.certifications.forEach { cert in
            let newCert = Certification(
                name: cert.name,
                issuer: cert.issuer,
                issueDate: parseDate(cert.issueDate) ?? Date(),
                credentialID: cert.credentialID ?? ""
            )
            masterProfile.certifications.append(newCert)
        }

        // Clear & overwrite Awards
        masterProfile.awards.forEach { context.delete($0) }
        masterProfile.awards.removeAll()
        generable.awards.forEach { award in
            let newAward = Award(
                title: award.title,
                issuer: award.issuer,
                issueDate: parseDate(award.issueDate) ?? Date()
            )
            masterProfile.awards.append(newAward)
        }
        
        // Clear & overwrite Skills
        masterProfile.skills.forEach { context.delete($0) }
        masterProfile.skills.removeAll()
        generable.skills.forEach { skillName in
            masterProfile.skills.append(Skill(name: skillName))
        }

        // Clear & overwrite Languages
        masterProfile.languages.forEach { context.delete($0) }
        masterProfile.languages.removeAll()
        generable.languages.forEach { lang in
            masterProfile.languages.append(Language(name: lang.name, proficiency: lang.proficiency ?? ""))
        }
        
        try? context.save()
    }
    // MARK: - Date Parsing Helper
    
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
