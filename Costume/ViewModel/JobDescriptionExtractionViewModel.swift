//
//  JobDescriptionExtractionViewModel.swift
//  Costume
//
//  Created by Saujana Shafi on 15/07/26.
//

import Foundation
import SwiftData

@Observable
final class JobDescriptionExtractionViewModel {
    var isLoading: Bool = false
    var extractionResult: JobDescriptionGenerable? = nil
    
    private let agentService = JobDescriptionAgentService()
    
    // Simpan reference model context dari SwiftUI View
    var modelContext: ModelContext?

    func extract(from text: String) async throws -> JobDescriptionGenerable {
        return try await agentService.invoke(for: text)
    }
    
    @MainActor
    func onSubmit(jobDescription: String) {
        guard let context = modelContext else {
            print("❌ Error: ModelContext belum di-inject ke ViewModel")
            return
        }
        
        // 1. Inisialisasi Model JobDescription awal dengan status 'processing'
        let newJobDesc = JobDescription(
            content: jobDescription,
            extractionStatus: "processing"
        )
        context.insert(newJobDesc)
        
        isLoading = true
        
        Task {
            do {
                // 2. Lakukan API/Agent Call di Background
                let result = try await extract(from: jobDescription)
                
                // 3. Proses data SwiftData kembali di MainActor
                await MainActor.run {
                    self.extractionResult = result
                    
                    // A. Cari Master Profile (Profile yang tidak memiliki JobDescription)
                    let masterProfile = fetchMasterProfile(using: context)
                    
                    // B. Duplikasi Master Profile untuk JobDescription ini jika ditemukan
                    if let master = masterProfile {
                        let duplicatedProfile = duplicate(profile: master, for: result, using: context)
                        newJobDesc.profile = duplicatedProfile
                    }
                    
                    // C. Petakan Keywords dari array String ke entitas Model [Keyword]
                    let mappedKeywords = result.keywords.map { keywordText in
                        Keyword(name: keywordText, isMatched: false)
                        // Catatan: Sesuaikan init Keyword Anda, pastikan relasi inverse ke newJobDesc terpasang
                    }
                    newJobDesc.keywords = mappedKeywords
                    
                    // D. Encode data struct asli ke JSON Data sebagai backup cadangan
                    if let encodedData = try? JSONEncoder().encode(result) {
                        newJobDesc.extractedData = encodedData
                    }
                    
                    // E. Perbarui status penyelesaian sukses
                    newJobDesc.extractionStatus = "completed"
                    newJobDesc.updatedAt = Date()
                    
                    // Save perubahan ke disk
                    try? context.save()
                    
                    self.isLoading = false
                    print("✅ Extraction & Cloning Sukses: \(result.role) at \(result.company)")
                }
                
            } catch {
                await MainActor.run {
                    self.isLoading = false
                    newJobDesc.extractionStatus = "failed"
                    newJobDesc.updatedAt = Date()
                    try? context.save()
                    print("❌ Extraction gagal: \(error.localizedDescription)")
                }
            }
        }
    }
    
    /// Mencari Master Profile berdasarkan kondisi: tidak memiliki relasi dengan JobDescription.
    /// Memberikan trigger fatalError/assertionFailure jika ditemukan lebih dari satu master.
    @MainActor
    private func fetchMasterProfile(using context: ModelContext) -> Profile? {
        // Asumsi properti relasi di model Profile bernama `jobDescription`
        // Kita filter profile yang jobDescription-nya nil
        let descriptor = FetchDescriptor<Profile>(
            predicate: #Predicate<Profile> { $0.jobDescription == nil }
        )
        
        do {
            let matches = try context.fetch(descriptor)
            
            if matches.count > 1 {
                // Trigger error saat debug jika terdapat lebih dari 1 Master Profile
                assertionFailure("❌ [DEBUG ERROR] Ditemukan \(matches.count) Master Profile! Seharusnya hanya ada 1 profile tanpa Job Description.")
            }
            
            return matches.first
        } catch {
            print("❌ Gagal mengambil master profile: \(error)")
            return nil
        }
    }
    
    /// Menduplikasi profile lama menjadi profile baru yang terikat khusus ke hasil ekstraksi ini
    @MainActor
    private func duplicate(profile: Profile, for result: JobDescriptionGenerable, using context: ModelContext) -> Profile {
        // 1. Duplikasi properti dasar
        let newProfile = Profile(
            name: "\(profile.name) - \(result.role)",
            email: profile.email,
            location: profile.location,
            phone: profile.phone,
            linkedin: profile.linkedin,
            website: profile.website,
            summary: profile.summary
        )
        
        context.insert(newProfile)
        
        // 2. Deep Copy Relasi: ProfileLink (Aman untuk dibuat baru)
        newProfile.links = profile.links.map { link in
            let newLink = ProfileLink(platform: link.platform, url: link.url)
            context.insert(newLink)
            return newLink
        }
        
        // 3. Deep Copy Relasi: Experience (Gunakan kembali array Skill yang sudah ada agar tidak duplikat)
        newProfile.experiences = profile.experiences.map { exp in
            let newExp = Experience(
                role: exp.role,
                employmentType: exp.employmentType,
                company: exp.company,
                location: exp.location,
                startDate: exp.startDate,
                endDate: exp.endDate,
                descriptionText: exp.descriptionText,
                skills: exp.skills // 👈 Gak usah bikin Skill baru, pasang object Skill yang lama!
            )
            context.insert(newExp)
            return newExp
        }
        
        // 4. Deep Copy Relasi: Education
        newProfile.educations = profile.educations.map { edu in
            let newEdu = Education(
                school: edu.school,
                degree: edu.degree,
                fieldOfStudy: edu.fieldOfStudy,
                startDate: edu.startDate,
                endDate: edu.endDate,
                grade: edu.grade,
                skills: edu.skills // 👈 Gunakan kembali array skill lama
            )
            context.insert(newEdu)
            return newEdu
        }
        
        // 5. Deep Copy Relasi: Certification
        newProfile.certifications = profile.certifications.map { cert in
            let newCert = Certification(
                name: cert.name,
                issuer: cert.issuer,
                issueDate: cert.issueDate,
                expirationDate: cert.expirationDate,
                credentialID: cert.credentialID,
                credentialURL: cert.credentialURL,
                skills: cert.skills // 👈 Gunakan kembali array skill lama
            )
            context.insert(newCert)
            return newCert
        }
        
        // 6. Deep Copy Relasi: Project
        newProfile.projects = profile.projects.map { proj in
            let newProj = Project(
                role: proj.role,
                name: proj.name,
                startDate: proj.startDate,
                endDate: proj.endDate,
                website: proj.website,
                descriptionText: proj.descriptionText,
                skills: proj.skills // 👈 Gunakan kembali array skill lama
            )
            context.insert(newProj)
            return newProj
        }
        
        // 7. Deep Copy Relasi: Award
        newProfile.awards = profile.awards.map { award in
            let newAward = Award(
                title: award.title,
                issuer: award.issuer,
                issueDate: award.issueDate
            )
            context.insert(newAward)
            return newAward
        }
        
        // 8. Deep Copy Relasi: Language
        newProfile.languages = profile.languages.map { lang in
            let newLang = Language(
                name: lang.name,
                proficiency: lang.proficiency
            )
            context.insert(newLang)
            return newLang
        }
        
        // 9. Relasi Utama: Profile.skills
        // 💡 JANGAN dipetakan ke Skill(name:) baru. Langsung tunjuk ke object unik yang sudah ada di database!
        newProfile.skills = profile.skills
        
        return newProfile
    }
    
    func isSubmitDisabled(for text: String) -> Bool {
        isLoading || text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
}
