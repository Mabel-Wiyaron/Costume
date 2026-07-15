//
//  EditProfileView.swift
//  Costume
//
//  Created by Matthew Regan Hadiwidjaja on 14/07/26.
//

import SwiftData
import SwiftUI

struct EditProfileView: View {
    @State private var viewModel: EditProfileViewModel

    private let OUTER_PADDING: CGFloat = 40
    private let CARD_MAX_WIDTH: CGFloat = 800

    init(profile: Profile, modelContext: ModelContext? = nil) {
        _viewModel = State(
            initialValue: EditProfileViewModel(
                profile: profile,
                modelContext: modelContext
            )
        )
    }

    var body: some View {
        NavigationSplitView {
            ProfileSidebarView(selectedSection: $viewModel.selectedSection)
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
                            SkillsSectionView(viewModel: viewModel)
                        case .experience:
                            Text("Experience")
                        case .project:
                            Text("Project")
                        case .certificationAndAwards:
                            Text("Certification & Awards")
                        case .volunteers:
                            Text("Volunteers")
                        }
                    }
                    .frame(maxWidth: CARD_MAX_WIDTH, alignment: .top)
                    .padding(OUTER_PADDING)
                    .frame(maxWidth: .infinity, alignment: .top)
                }
            }
        }
        .navigationSplitViewColumnWidth(min: 220, ideal: 260, max: 300)
    }
}

#Preview {
    let container = try! ModelContainer(
        for: Profile.self,
        configurations: ModelConfiguration(isStoredInMemoryOnly: true)
    )
    let sampleProfile = Profile(
        name: "",
        role: "",
        email: "",
        location: "",
        phone: ""
    )
    return EditProfileView(
        profile: sampleProfile,
        modelContext: container.mainContext
    )
    .modelContainer(container)
}
