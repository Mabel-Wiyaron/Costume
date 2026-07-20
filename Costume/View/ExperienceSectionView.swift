//
//  ExperienceSectionView.swift
//  Costume
//
//  Created by Matthew Regan Hadiwidjaja on 15/07/26.
//

import SwiftUI

struct ExperienceSectionView: View {
    @Bindable var viewModel: EditProfileViewModel

    private let CARD_PADDING: CGFloat = 32
    private let ROW_SPACING: CGFloat = 12

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            SectionHeaderView(title: "Experience") {
                Button("+ Add Experience") {
                    viewModel.startAddingExperience()
                }
                .buttonStyle(.borderedProminent)
                .tint(Color("PrimaryColor"))
            }

            if viewModel.profile.experiences.isEmpty {
                SectionEmptyStateView(
                    imageName: "ExperienceEmptyState",
                    message: "No experience yet."
                )
            } else {
                VStack(spacing: ROW_SPACING) {
                    ForEach(viewModel.profile.experiences) { experience in
                        ListItemCard(
                            title: experience.role,
                            subtitle: "\(experience.company) • \(experience.employmentType.title)",
                            action: {
                                viewModel.startEditingExperience(experience)
                            }
                        )
                        .contextMenu {
                            Button("Delete", role: .destructive) {
                                viewModel.deleteExperience(experience)
                            }
                        }
                    }
                }
            }
        }
        .padding(CARD_PADDING)
        .cardBackground()
        .sheet(isPresented: $viewModel.isExperienceModalPresented) {
            ExperienceFormModal(
                experience: viewModel.experienceBeingEdited,
                onSave: viewModel.saveExperience,
                onCancel: viewModel.cancelExperienceEdit,
                onDelete: viewModel.experienceBeingEdited.map { experience in
                    {
                        viewModel.deleteExperience(experience)
                        viewModel.cancelExperienceEdit()
                    }
                }
            )
        }
    }
}
