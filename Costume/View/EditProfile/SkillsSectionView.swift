//
//  SkillsSectionView.swift
//  Costume
//
//  Created by Matthew Regan Hadiwidjaja on 15/07/26.
//

import SwiftUI

struct SkillsSectionView: View {
    @Binding var skills: [Skill]
    var onSave: (() -> Void)? = nil

    private let CARD_PADDING: CGFloat = 32

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            SectionHeaderView(title: "Skills")

            SkillTagField(
                label: "Add skills",
                helperText: "Press enter for each new skill",
                skills: $skills
            )

            if let onSave {
                HStack {
                    Spacer()
                    Button("Save") { onSave() }
                        .buttonStyle(.borderedProminent)
                        .tint(Color("PrimaryColor"))
                        .controlSize(.large)
                        .keyboardShortcut(.defaultAction)
                }
            }
        }
        .padding(CARD_PADDING)
        .cardBackground()
    }
}
