//  EditProfileView.swift

import SwiftData
import SwiftUI

struct EditProfileView: View {
    @Environment(\.modelContext) private var mainContext
    
    var profile: Profile? = nil
    @State private var viewModel: EditProfileViewModel? = nil

    private let OUTER_PADDING: CGFloat = 40
    private let CARD_MAX_WIDTH: CGFloat = 800

    var body: some View {
        NavigationSplitView {
            if let vm = viewModel {
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
                    @Bindable var bindableVM = vm
                    
                    ScrollView {
                        VStack(alignment: .leading) {
                            switch bindableVM.selectedSection {
                            case .personalInfo, .none:
                                PersonalInfoFormView(viewModel: vm)
                            case .education:
                                EducationSectionView(viewModel: vm)
                            case .experience:
                                ExperienceSectionView(viewModel: vm)
                            case .skills:
                                SkillsSectionView(skills: $bindableVM.profile.skills, isSaveEnabled: vm.isSkillsSaveEnabled, onSave: vm.save)
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
        
        // 1. Fetch/Find target profile from main context
        let targetProfile: Profile
        if let profile = profile {
            targetProfile = profile
        } else {
            let descriptor = FetchDescriptor<Profile>()
            let fetchedProfiles = (try? mainContext.fetch(descriptor)) ?? []
            
            let matchedProfile = fetchedProfiles.first(where: { $0.jobDescription == nil })
            
            if let existing = matchedProfile {
                targetProfile = existing
            } else if let fallbackFirst = fetchedProfiles.first {
                targetProfile = fallbackFirst
            } else {
                let newProfile = Profile(name: "", email: "", location: "", phone: "")
                mainContext.insert(newProfile)
                targetProfile = newProfile
            }
        }
        
        // 2. Create an isolated Child Context (Sandboxed Draft)
        let childContext = ModelContext(mainContext.container)
        
        // Disable autosave explicitly on the draft context
        childContext.autosaveEnabled = false
        
        // 3. Fetch the sandboxed instance of the profile
        let targetID = targetProfile.persistentModelID
        if let sandboxedProfile = childContext.model(for: targetID) as? Profile {
            self.viewModel = EditProfileViewModel(profile: sandboxedProfile, modelContext: childContext)
        } else {
            // Fallback if sandboxing isn't available
            self.viewModel = EditProfileViewModel(profile: targetProfile, modelContext: mainContext)
        }
    }
}
