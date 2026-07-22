//
//  ExperienceSectionView.swift
//  Costume
//
//  Created by Matthew Regan Hadiwidjaja on 15/07/26.
//

import SwiftUI

struct ExperienceSectionView: View {
    @Bindable var viewModel: EditProfileViewModel

    var body: some View {
        ProfileEntrySectionView(
            title: "Experience",
            addButtonLabel: "+ Add Experience",
            emptyStateImage: "ExperienceEmptyState",
            emptyStateMessage: "No experience yet.",
            items: viewModel.profile.experiences,
            itemTitle: { $0.role },
            itemSubtitle: { "\($0.company) • \($0.employmentType.title)" },
            onAdd: viewModel.startAddingExperience,
            onSelect: viewModel.startEditingExperience,
            onDelete: viewModel.deleteExperience,
            isModalPresented: $viewModel.isExperienceModalPresented
        ) {
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
