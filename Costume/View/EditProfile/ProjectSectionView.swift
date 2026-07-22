//
//  ProjectSectionView.swift
//  Costume
//
//  Created by Matthew Regan Hadiwidjaja on 15/07/26.
//

import SwiftUI

struct ProjectSectionView: View {
    @Bindable var viewModel: EditProfileViewModel

    var body: some View {
        ProfileEntrySectionView(
            title: "Project",
            addButtonLabel: "+ Add Project",
            emptyStateImage: "ProjectEmptyState",
            emptyStateMessage: "No projects yet.",
            items: viewModel.profile.projects,
            itemTitle: { $0.name },
            itemSubtitle: { $0.role },
            onAdd: viewModel.startAddingProject,
            onSelect: viewModel.startEditingProject,
            onDelete: viewModel.deleteProject,
            isModalPresented: $viewModel.isProjectModalPresented
        ) {
            ProjectFormModal(
                project: viewModel.projectBeingEdited,
                onSave: viewModel.saveProject,
                onCancel: viewModel.cancelProjectEdit,
                onDelete: viewModel.projectBeingEdited.map { project in
                    {
                        viewModel.deleteProject(project)
                        viewModel.cancelProjectEdit()
                    }
                }
            )
        }
    }
}
