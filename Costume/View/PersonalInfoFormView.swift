//
//  PersonalInfoFormView.swift
//  Costume
//
//  Created by Matthew Regan Hadiwidjaja on 14/07/26.
//

import SwiftUI

struct PersonalInfoFormView: View {
    @Bindable var viewModel: EditProfileViewModel

    private let CARD_PADDING: CGFloat = 32
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
                        text: $viewModel.profile.name
                    )

                    HStack(alignment: .top, spacing: COLUMN_SPACING) {
                        LabeledTextField(
                            label: "Contact",
                            isRequired: true,
                            placeholder: "+62 1234567890",
                            text: $viewModel.profile.phone
                        )
                        LabeledTextField(
                            label: "LinkedIn",
                            text: $viewModel.profile.linkedin.stringValue
                        )
                    }

                    HStack(alignment: .top, spacing: COLUMN_SPACING) {
                        LabeledTextField(
                            label: "Email",
                            isRequired: true,
                            text: $viewModel.profile.email
                        )
                        LabeledTextField(
                            label: "Personal Website",
                            text: $viewModel.profile.website.stringValue
                        )
                    }

                    HStack(alignment: .top, spacing: COLUMN_SPACING) {
                        LabeledTextField(
                            label: "Location",
                            text: $viewModel.profile.location
                        )
                        LabeledTextField(
                            label: "Github",
                            text: $viewModel.profile.links.urlString(forPlatform: .github)
                        )
                    }
                }

                VStack(alignment: .leading, spacing: 16) {
                    SectionHeaderView(title: "Summary")
                    LabeledTextEditor(
                        label: "About Me",
                        text: $viewModel.profile.summary.stringValue
                    )
                }

                HStack {
                    Spacer()
                    Button("Save") {
                        viewModel.Save()
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(Color("PrimaryColor"))
                    .controlSize(.large)
                    .keyboardShortcut(.defaultAction)
                    .disabled(!viewModel.isSaveEnabled)
                }
            }
            .padding(CARD_PADDING)
            .cardBackground()
        }
    }
}
