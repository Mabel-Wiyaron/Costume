//
//  EditProfileView.swift
//  Costume
//
//  Created by Matthew Regan Hadiwidjaja on 14/07/26.
//

import SwiftData
import SwiftUI

struct EditProfileView: View {
    // Gunakan @Environment untuk mendapatkan ModelContext bawaan sistem
    @Environment(\.modelContext) private var modelContext
    
    // Inisialisasi ViewModel secara kosong dulu menggunakan @State
    @State private var viewModel: EditProfileViewModel? = nil

    private let OUTER_PADDING: CGFloat = 40
    private let CARD_MAX_WIDTH: CGFloat = 800

    var body: some View {
        NavigationSplitView {
            // Kita butuh viewModel siap dulu sebelum menampilkan sidebar
            if let viewModel = Binding($viewModel) {
                ProfileSidebarView(selectedSection: viewModel.selectedSection)
            } else {
                ProgressView() // Tampilan loading sementara data disiapkan
            }
        } detail: {
            ZStack {
                Color("BackgroundColor")
                    .ignoresSafeArea()

                ScrollView {
                    Group {
                        switch viewModel.selectedSection {
                        case .personalInfo, .none:
                            PersonalInfoFormView(viewModel: viewModel)
                        case .education:
                            EducationSectionView(viewModel: viewModel)
                        case .skills:
                            SkillsSectionView(skills: $viewModel.profile.skills, onSave: viewModel.Save)
                        case .experience:
                            ExperienceSectionView(viewModel: viewModel)
                        case .project:
                            ProjectSectionView(viewModel: viewModel)
                        case .certification:
                            CertificationSectionView(viewModel: viewModel)
                        case .awards:
                            AwardSectionView(viewModel: viewModel)
                        }
                        .frame(maxWidth: CARD_MAX_WIDTH, alignment: .top)
                        .padding(OUTER_PADDING)
                        .frame(maxWidth: .infinity, alignment: .top)
                    }
                }
            }
        }
        .navigationSplitViewColumnWidth(min: 220, ideal: 260, max: 300)
        // Pindahkan logika database ke .onAppear di bawah ini!
        .onAppear {
            setupViewModel()
        }
    }

    private func setupViewModel() {
        guard viewModel == nil else { return }
        
        let descriptor = FetchDescriptor<Profile>()
        let fetchedProfiles = (try? modelContext.fetch(descriptor)) ?? []
        
        // DEBUG: Cetak jumlah profil yang sukses dibaca dari SQLite
        print("DEBUG: Total profile ditemukan di DB = \(fetchedProfiles.count)")
        for (index, p) in fetchedProfiles.enumerated() {
            print("[\(index)] Nama: '\(p.name)', JobDesc: '\(String(describing: p.jobDescription))'")
        }
        
        // Perbaikan logika: Cari profile utama.
        // Jika jobDescription nil ATAU kosong, kita anggap itu profil utama pengguna.
        let matchedProfile = fetchedProfiles.first(where: {
            $0.jobDescription == nil
        })
        
        let finalProfile: Profile
        if let existing = matchedProfile {
            print("DEBUG: Berhasil memakai data lama -> \(existing.name)")
            finalProfile = existing
        } else if let fallbackFirst = fetchedProfiles.first {
            // Fallback darurat: jika filter di atas meleset tapi DB punya data, pakai data pertama yang ada
            print("DEBUG: Fallback memakai profile pertama yang ada -> \(fallbackFirst.name)")
            finalProfile = fallbackFirst
        } else {
            // Jika database benar-benar kosong melompong, baru buat baru
            print("DEBUG: Database kosong. Membuat profile baru.")
            let newProfile = Profile(name: "", email: "", location: "", phone: "")
            modelContext.insert(newProfile)
            finalProfile = newProfile
        }
        
        self.viewModel = EditProfileViewModel(profile: finalProfile, modelContext: modelContext)
    }
}
