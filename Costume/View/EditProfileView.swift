// MARK: - EditProfileView.swift

import SwiftUI

struct EditProfileView: View {
    @StateObject private var viewModel = EditProfileViewModel()

    var body: some View {
        NavigationSplitView {
            ProfileSidebarView(selectedSection: $viewModel.selectedSection)
        } detail: {
            switch viewModel.selectedSection {
            case .personalInfo, .none:
                PersonalInfoFormView(viewModel: viewModel)
            case .education:
                Text("Education")
            case .skills:
                Text("Skills")
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
        .navigationSplitViewColumnWidth(min: 220, ideal: 260, max: 300)
    }
}

#Preview {
    EditProfileView()
}