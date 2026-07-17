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
    
    init(profile: Profile, modelContext: ModelContext? = nil) {
            _viewModel = State(
                initialValue: EditProfileViewModel(
                    profile: profile,
                    modelContext: modelContext!
                )
            )
        }

    var body: some View {
            NavigationSplitView {
                if let vm = viewModel {
                    // Creates a bindable reference to pass bindings like $bindableVM.selectedSection
                    @Bindable var bindableVM = vm
                    ProfileSidebarView(selectedSection: $bindableVM.selectedSection)
                } else {
                    ProgressView()
                }
            } detail: {
                ZStack {
                    Color("BackgroundColor")
                        .ignoresSafeArea()

                    if let vm = viewModel {
                        // Extract Bindable once at the top level of the detail view
                        @Bindable var bindableVM = vm
                        
                        ScrollView {
                            VStack(alignment: .leading) {
                                switch bindableVM.selectedSection {
                                case .personalInfo, .none:
                                    PersonalInfoFormView(viewModel: vm)
                                case .education:
                                    EducationSectionView(viewModel: vm)
                                case .skills:
                                    SkillsSectionView(skills: $bindableVM.profile.skills, onSave: vm.save)
                                case .experience:
                                    ExperienceSectionView(viewModel: vm)
                                case .project:
                                    ProjectSectionView(viewModel: vm)
                                case .certification:
                                    CertificationSectionView(viewModel: vm)
                                case .awards:
                                    AwardSectionView(viewModel: vm)
                                }
                            }
                            .frame(maxWidth: CARD_MAX_WIDTH, alignment: .top)
                            .padding(OUTER_PADDING)
                            .frame(maxWidth: .infinity, alignment: .top)
                        }
                    } else {
                        ProgressView()
                    }
                }
            }
            .navigationSplitViewColumnWidth(min: 220, ideal: 260, max: 300)
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
