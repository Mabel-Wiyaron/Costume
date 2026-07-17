//
//  SkillsSectionView.swift
//  Costume
//
//  Created by Matthew Regan Hadiwidjaja on 15/07/26.
//

import SwiftUI

struct SkillsSectionView: View {
    @Bindable var viewModel: EditProfileViewModel

    private let CARD_PADDING: CGFloat = 32

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            SectionHeaderView(title: "Skills")

            SkillTagField(
                label: "Add skills",
                helperText: "Press enter for each new skill",
                skills: $viewModel.profile.skills
            )

            HStack {
                Spacer()
                Button("Save") {
                    viewModel.save()
                }
                .buttonStyle(.borderedProminent)
                .tint(Color("PrimaryColor"))
                .controlSize(.large)
                .keyboardShortcut(.defaultAction)
                .disabled(!viewModel.isSkillsSaveEnabled)
            }
        }
        .padding(CARD_PADDING)
        .cardBackground()
    }
}
