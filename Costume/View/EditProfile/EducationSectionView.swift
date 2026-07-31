//
//  EducationSectionView.swift
//  Costume
//
//  Created by Matthew Regan Hadiwidjaja on 14/07/26.
//

import SwiftUI

struct EducationSectionView: View {
    @Bindable var viewModel: EditProfileViewModel

    var body: some View {
        ProfileEntrySectionView(
            title: "Education",
            addButtonLabel: "+ Add Education",
            emptyStateImage: "EducationEmptyState",
            emptyStateMessage: "No education yet.",
            items: viewModel.profile.educations,
            itemTitle: { $0.school },
            itemSubtitle: { "\($0.degree), \($0.fieldOfStudy)" },
            onAdd: viewModel.startAddingEducation,
            onSelect: viewModel.startEditingEducation,
            onDelete: viewModel.deleteEducation,
            isModalPresented: $viewModel.isEducationModalPresented
        ) {
            EducationFormModal(
                education: viewModel.educationBeingEdited,
                onSave: viewModel.saveEducation,
                onCancel: viewModel.cancelEducationEdit,
                onDelete: viewModel.educationBeingEdited.map { education in
                    {
                        viewModel.deleteEducation(education)
                        viewModel.cancelEducationEdit()
                    }
                }
            )
        }
    }
}
