import SwiftData
import SwiftUI

struct EditProfileView: View {
    @Environment(\.modelContext) private var mainContext
    
    var profile: Profile? = nil
    @State private var viewModel: EditProfileViewModel? = nil
    @State private var cvViewModel: CVParsingViewModel? = nil

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
                            case .uploadCV, .none:
                                if let cvViewModel = cvViewModel {
                                    // 1. Fetch mainContext profile
                                    let mainProfile = (try? mainContext.model(for: vm.profile.persistentModelID) as? Profile) ?? vm.profile
                                        
                                    // 2. Pass both sandboxedProfile (child context) & mainProfile (main context)
                                    UploadCVView(
                                        viewModel: cvViewModel,
                                        sandboxedProfile: vm.profile,
                                        masterProfile: mainProfile,
                                        mainContext: mainContext
                                    )
                                } else {
                                    ProgressView("Initializing parser...")
                                }
                            case .personalInfo:
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
        
        self.cvViewModel = CVParsingViewModel()

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
                try? mainContext.save()
                targetProfile = newProfile
            }
        }

        let childContext = ModelContext(mainContext.container)
        childContext.autosaveEnabled = false

        let targetID = targetProfile.persistentModelID
        let activeViewModel: EditProfileViewModel

        if let sandboxedProfile = childContext.model(for: targetID) as? Profile {
            activeViewModel = EditProfileViewModel(profile: sandboxedProfile, modelContext: childContext)
        } else {
            activeViewModel = EditProfileViewModel(profile: targetProfile, modelContext: mainContext)
        }

        let hasMasterProfileData = !targetProfile.name.trimmingCharacters(in: .whitespaces).isEmpty ||
                                   !targetProfile.email.trimmingCharacters(in: .whitespaces).isEmpty

        activeViewModel.selectedSection = hasMasterProfileData ? .personalInfo : .uploadCV

        self.viewModel = activeViewModel
    }
}
