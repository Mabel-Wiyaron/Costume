// MARK: - PersonalInfoFormView.swift

import SwiftUI

struct PersonalInfoFormView: View {
    @ObservedObject var viewModel: EditProfileViewModel

    private let COLUMN_SPACING: CGFloat = 32
    private let SECTION_SPACING: CGFloat = 32

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: SECTION_SPACING) {
                VStack(alignment: .leading, spacing: 16) {
                    SectionHeaderView(title: "Personal Information")

                    Text("Tip: The more detailed your profile is, the better our AI can personalize your CV. Include specific responsibilities, skills, tools, certifications, and measurable achievements whenever possible.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)

                    LabeledTextField(
                        label: "Name",
                        isRequired: true,
                        text: $viewModel.personalInfo.name
                    )

                    HStack(alignment: .top, spacing: COLUMN_SPACING) {
                        LabeledTextField(
                            label: "Contact",
                            isRequired: true,
                            placeholder: "+62 1234567890",
                            text: $viewModel.personalInfo.contact
                        )
                        LabeledTextField(
                            label: "LinkedIn",
                            text: $viewModel.personalInfo.linkedIn
                        )
                    }

                    HStack(alignment: .top, spacing: COLUMN_SPACING) {
                        LabeledTextField(
                            label: "Email",
                            isRequired: true,
                            text: $viewModel.personalInfo.email
                        )
                        LabeledTextField(
                            label: "Personal Website",
                            text: $viewModel.personalInfo.personalWebsite
                        )
                    }

                    HStack(alignment: .top, spacing: COLUMN_SPACING) {
                        LabeledTextField(
                            label: "Location",
                            text: $viewModel.personalInfo.location
                        )
                        LabeledTextField(
                            label: "Github",
                            text: $viewModel.personalInfo.github
                        )
                    }
                }

                VStack(alignment: .leading, spacing: 16) {
                    SectionHeaderView(title: "Summary")
                    LabeledTextEditor(
                        label: "About Me",
                        text: $viewModel.personalInfo.aboutMe
                    )
                }

                HStack {
                    Spacer()
                    Button("Save") {
                        viewModel.Save()
                    }
                    .keyboardShortcut(.defaultAction)
                    .disabled(!viewModel.isSaveEnabled)
                }
            }
            .padding(32)
        }
    }
}