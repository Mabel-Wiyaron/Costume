//
//  SkillTagField.swift
//  Costume
//
//  Created by Matthew Regan Hadiwidjaja on 15/07/26.
//

import SwiftUI

struct SkillTagField: View {
    let label: String
    var isRequired: Bool = false
    var helperText: String = ""
    @Binding var skills: [Skill]

    @State private var draftText: String = ""
    @FocusState private var isFocused: Bool

    private let CORNER_RADIUS: CGFloat = 8
    private let CONTAINER_MIN_HEIGHT: CGFloat = 160
    private let CHIP_SPACING: CGFloat = 8

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 2) {
                Text(label)
                    .font(.title3)
                    .fontWeight(.semibold)
                if isRequired {
                    Text("*")
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundStyle(.red)
                }
            }
            if !helperText.isEmpty {
                Text(helperText)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }

            VStack(alignment: .leading, spacing: 12) {
                if !skills.isEmpty {
                    FlowLayout(spacing: CHIP_SPACING) {
                        ForEach(skills) { skill in
                            SkillChip(name: skill.name) {
                                removeSkill(skill)
                            }
                        }
                    }
                }

                TextField("", text: $draftText)
                    .textFieldStyle(.plain)
                    .focused($isFocused)
                    .onSubmit(commitDraft)
            }
            .padding(12)
            .frame(minHeight: CONTAINER_MIN_HEIGHT, alignment: .topLeading)
            .frame(maxWidth: .infinity, alignment: .topLeading)
            .contentShape(Rectangle())
            .onTapGesture { isFocused = true }
            .overlay(
                RoundedRectangle(cornerRadius: CORNER_RADIUS)
                    .stroke(
                        isFocused ? Color.orange : Color.black,
                        lineWidth: isFocused ? 2 : 1
                    )
            )
            .animation(.easeInOut(duration: 0.2), value: isFocused)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func commitDraft() {
        let trimmedName = draftText.trimmingCharacters(
            in: .whitespacesAndNewlines
        )
        guard !trimmedName.isEmpty else { return }
        guard
            !skills.contains(where: {
                $0.name.caseInsensitiveCompare(trimmedName) == .orderedSame
            })
        else {
            draftText = ""
            return
        }
        skills.append(Skill(name: trimmedName))
        draftText = ""
    }

    private func removeSkill(_ skill: Skill) {
        skills.removeAll { $0 === skill }
    }
}
