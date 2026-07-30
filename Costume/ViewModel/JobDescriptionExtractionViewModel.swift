//
//   JobDescriptionExtractionViewModel.swift
//   Costume
//
//   Created by Saujana Shafi on 15/07/26.
//

import Foundation
import SwiftData
import SwiftUI

@Observable
final class JobDescriptionExtractionViewModel {
    @ObservationIgnored @AppStorage("useExternalAPI") private var persistedUseExternalAPI = false
    @ObservationIgnored @AppStorage("externalAPIBaseURL") private var persistedBaseURL = ""
    @ObservationIgnored @AppStorage("externalAPIKey") private var persistedApiKey = ""
    @ObservationIgnored @AppStorage("externalAPIModel") private var persistedModel = ""

    var isLoading: Bool = false
    var isFinished: Bool = false
    var createdProfile: Profile? = nil
    var extractionResult: JobDescriptionGenerable? = nil
    
    private let agentService = JobDescriptionAgentService()
    
    // Reference model context from SwiftUI View
    var modelContext: ModelContext?

    func extract(from text: String) async throws -> JobDescriptionGenerable {
        return try await runJobDescriptionAgent(for: text)
    }
    
    @MainActor
    func onSubmit(jobDescription: String) {
        guard let context = modelContext else {
            print("❌ Error: ModelContext hasn't been injected into ViewModel")
            return
        }
        
        // 1. Reset state & start loading
        isLoading = true
        isFinished = false
        createdProfile = nil
        
        let newJobDesc = JobDescription(
            content: jobDescription,
            role: "",
            company: "",
            extractionStatus: "processing"
        )
        context.insert(newJobDesc)
        
        Task {
            do {
                // 2. Perform AI Extraction (Background Service)
                let result = try await extract(from: jobDescription)
                
                await MainActor.run {
                    self.extractionResult = result
                    newJobDesc.role = result.role
                    newJobDesc.company = result.company
                    
                    // A. Fetch Master Profile
                    let masterProfile = fetchMasterProfile(using: context)
                    
                    // B. Duplicate Master Profile
                    var profileToTailor: Profile?
                    if let master = masterProfile {
                        let duplicatedProfile = duplicate(profile: master, for: result, using: context)
                        newJobDesc.profile = duplicatedProfile
                        profileToTailor = duplicatedProfile
                    } else {
                        // Fallback profile if no master exists
                        let fallback = Profile(name: "Your Name", email: "", location: "", phone: "")
                        context.insert(fallback)
                        newJobDesc.profile = fallback
                        profileToTailor = fallback
                    }
                    
                    // C. Map Keywords
                    let mappedKeywords = result.keywords.map { keywordText in
                        Keyword(name: keywordText, status: KeywordStatus.missing)
                    }
                    newJobDesc.keywords = mappedKeywords
                    
                    // D. Backup JSON
                    if let encodedData = try? JSONEncoder().encode(result) {
                        newJobDesc.extractedData = encodedData
                    }
                    
                    newJobDesc.extractionStatus = "completed"
                    newJobDesc.updatedAt = Date()
                    try? context.save()
                    
                    // E. Continue to Agent Orchestration (Tailoring Section)
                    if let targetProfile = profileToTailor {
                        Task {
                            do {
                                let orchestrationVM = AgentOrchestrationViewModel()
                                let tailoredProfile = try await orchestrationVM.tailor(for: result, from: targetProfile)
                                
                                await MainActor.run {
                                    // 💡 CRITICAL FIX: Set createdProfile so navigation doesn't fail!
                                    self.createdProfile = tailoredProfile
                                    
                                    // Trigger navigation push
                                    self.isFinished = true
                                }
                                
                                // Brief delay so SwiftUI handles the push animation gracefully
                                try? await Task.sleep(nanoseconds: 300_000_000)
                                
                                await MainActor.run {
                                    self.isLoading = false
                                }
                            } catch {
                                await MainActor.run {
                                    // Fallback to basic duplicated profile if tailoring agent fails
                                    self.createdProfile = targetProfile
                                    self.isFinished = true
                                    self.isLoading = false
                                }
                            }
                        }
                    }
                }
                
            } catch {
                await MainActor.run {
                    self.isLoading = false
                    self.isFinished = false
                    newJobDesc.extractionStatus = "failed"
                    newJobDesc.updatedAt = Date()
                    try? context.save()
                    print("❌ Extraction failed: \(error.localizedDescription)")
                }
            }
        }
    }
    
    @MainActor
    private func fetchMasterProfile(using context: ModelContext) -> Profile? {
        let descriptor = FetchDescriptor<Profile>(
            predicate: #Predicate<Profile> { $0.jobDescription == nil }
        )
        
        do {
            let matches = try context.fetch(descriptor)
            if matches.count > 1 {
                assertionFailure("❌ [DEBUG ERROR] Found \(matches.count) Master Profiles!")
            }
            return matches.first
        } catch {
            print("❌ Failed to fetch master profile: \(error)")
            return nil
        }
    }
    
    @MainActor
    private func duplicate(profile: Profile, for result: JobDescriptionGenerable, using context: ModelContext) -> Profile {
        let newProfile = Profile(
            name: profile.name,
            email: profile.email,
            location: profile.location,
            phone: profile.phone,
            linkedin: profile.linkedin,
            website: profile.website,
            summary: profile.summary
        )
        
        context.insert(newProfile)
        
        var skillCopies: [ObjectIdentifier: Skill] = [:]
        func copiedSkills(_ originals: [Skill]) -> [Skill] {
            originals.map { original in
                let key = ObjectIdentifier(original)
                if let existing = skillCopies[key] { return existing }
                let copy = Skill(name: original.name)
                context.insert(copy)
                skillCopies[key] = copy
                return copy
            }
        }
        
        newProfile.links = profile.links.map { link in
            let newLink = ProfileLink(platform: link.platform, url: link.url)
            context.insert(newLink)
            return newLink
        }
        
        newProfile.experiences = profile.experiences.map { exp in
            let newExp = Experience(
                role: exp.role,
                employmentType: exp.employmentType,
                company: exp.company,
                location: exp.location,
                startDate: exp.startDate,
                endDate: exp.endDate,
                descriptionText: exp.descriptionText,
                skills: copiedSkills(exp.skills)
            )
            context.insert(newExp)
            return newExp
        }
        
        newProfile.educations = profile.educations.map { edu in
            let newEdu = Education(
                school: edu.school,
                degree: edu.degree,
                fieldOfStudy: edu.fieldOfStudy,
                startDate: edu.startDate,
                endDate: edu.endDate,
                grade: edu.grade,
                skills: copiedSkills(edu.skills)
            )
            context.insert(newEdu)
            return newEdu
        }
        
        newProfile.certifications = profile.certifications.map { cert in
            let newCert = Certification(
                name: cert.name,
                issuer: cert.issuer,
                issueDate: cert.issueDate,
                expirationDate: cert.expirationDate,
                credentialID: cert.credentialID,
                credentialURL: cert.credentialURL,
                skills: copiedSkills(cert.skills)
            )
            context.insert(newCert)
            return newCert
        }
        
        newProfile.projects = profile.projects.map { proj in
            let newProj = Project(
                role: proj.role,
                name: proj.name,
                startDate: proj.startDate,
                endDate: proj.endDate,
                website: proj.website,
                descriptionText: proj.descriptionText,
                skills: copiedSkills(proj.skills)
            )
            context.insert(newProj)
            return newProj
        }
        
        newProfile.awards = profile.awards.map { award in
            let newAward = Award(
                title: award.title,
                issuer: award.issuer,
                issueDate: award.issueDate
            )
            context.insert(newAward)
            return newAward
        }
        
        newProfile.languages = profile.languages.map { lang in
            let newLang = Language(
                name: lang.name,
                proficiency: lang.proficiency
            )
            context.insert(newLang)
            return newLang
        }
        
        newProfile.skills = copiedSkills(profile.skills)
        
        return newProfile
    }
    
    func isSubmitDisabled(for text: String) -> Bool {
        isLoading || text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    func getLanguageModel() async -> LanguageModelProtocol {
        if persistedUseExternalAPI {
            return OpenAIService(
                endpoint: URL(string: persistedBaseURL)!,
                apiKey: persistedApiKey,
                model: persistedModel
            )
        }

        return AppleIntelligenceService()
    }

    func runJobDescriptionAgent(for message: String) async throws -> JobDescriptionGenerable
    {
        let jobDescriptionAgent: JobDescriptionAgentService = .init(
            languageModel: await getLanguageModel()
        )

        return try await jobDescriptionAgent.invoke(for: message)
    }

}

