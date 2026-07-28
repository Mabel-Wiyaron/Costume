import SwiftData
import SwiftUI

struct EditProfileView: View {
    @Environment(\.modelContext) private var mainContext
    @Environment(\.dismiss) private var dismiss
    
    var profile: Profile? = nil
    @State private var viewModel: EditProfileViewModel? = nil
    @State private var cvViewModel: CVParsingViewModel? = nil

    private let OUTER_PADDING: CGFloat = 40
    private let CARD_MAX_WIDTH: CGFloat = 800

    var body: some View {
        NavigationSplitView {
            if let vm = viewModel {
                @Bindable var bindableVM = vm
                ProfileSidebarView(
                    selectedSection: $bindableVM.selectedSection,
                    onSelect: { section in attemptNavigate(to: section) }
                )
            } else {
                ProgressView()
            }
        } detail: {
            ZStack(alignment: .top) {
                Color("BackgroundColor")
                    .ignoresSafeArea()
                
                if let vm = viewModel {
                    @Bindable var bindableVM = vm
                    
                    ScrollView {
                        VStack(alignment: .leading) {
                            switch bindableVM.selectedSection {
                            case .uploadCV, .none:
                                if let cvViewModel = cvViewModel {
                                    let mainProfile = (try? mainContext.model(for: vm.profile.persistentModelID) as? Profile) ?? vm.profile
                                    
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
                                SkillsSectionView(skills: $bindableVM.profile.skills, isSaveEnabled: vm.isSkillsSaveEnabled, onSave: vm.saveWithConfirmation)
                            case .project:
                                ProjectSectionView(viewModel: vm)
                            case .certification:
                                CertificationSectionView(viewModel: vm)
                            case .awards:
                                AwardSectionView(viewModel: vm)
                            case .llmSettings:
                                LLMSettingsView()
                            }
                        }
                        .frame(maxWidth: CARD_MAX_WIDTH, alignment: .top)
                        .padding(OUTER_PADDING)
                        .frame(maxWidth: .infinity, alignment: .top)
                    }
                    
                    if vm.showSaveConfirmation {
                        SaveConfirmationToast()
                            .frame(maxWidth: CARD_MAX_WIDTH)
                            .padding(.horizontal, OUTER_PADDING)
                            .padding(.top, OUTER_PADDING)
                            .transition(.move(edge: .top).combined(with: .opacity))
                            .zIndex(1)
                            .allowsHitTesting(false)
                    }
                } else {
                    ProgressView()
                }
            }
            .animation(.easeInOut(duration: 0.25), value: viewModel?.showSaveConfirmation)
        }
        .navigationSplitViewColumnWidth(min: 220, ideal: 260, max: 300)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigation) {
                Button(action: attemptBack) {
                    Image(systemName: "chevron.left")
                }
            }
        }
        .onAppear {
            setupViewModel()
        }
    }

    private func attemptNavigate(to section: ProfileSection) {
        guard viewModel?.selectedSection != section else { return }
        proceedIfConfirmed { viewModel?.selectedSection = section }
    }

    private func attemptBack() {
        proceedIfConfirmed { dismiss() }
    }

    private func proceedIfConfirmed(action: () -> Void) {
        guard let vm = viewModel, vm.hasUnsavedChanges else {
            action()
            return
        }
        switch UnsavedChangesAlert.present() {
        case .save:
            vm.save()
            action()
        case .discardChanges:
            vm.discardChanges()
            action()
        case .cancel:
            break
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
