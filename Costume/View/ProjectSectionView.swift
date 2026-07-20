//
//  ProjectSectionView.swift
//  Costume
//
//  Created by Matthew Regan Hadiwidjaja on 15/07/26.
//

import SwiftUI

struct ProjectSectionView: View {
    @Bindable var viewModel: EditProfileViewModel

    private let CARD_PADDING: CGFloat = 32
    private let ROW_SPACING: CGFloat = 12

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            SectionHeaderView(title: "Project") {
                Button("+ Add Project") {
                    viewModel.startAddingProject()
                }
                .buttonStyle(.borderedProminent)
                .tint(Color("PrimaryColor"))
            }

            if viewModel.profile.projects.isEmpty {
                SectionEmptyStateView(
                    imageName: "ProjectEmptyState",
                    message: "No projects yet."
                )
            } else {
                VStack(spacing: ROW_SPACING) {
                    ForEach(viewModel.profile.projects) { project in
                        ListItemCard(
                            title: project.name,
                            subtitle: project.role,
                            action: { viewModel.startEditingProject(project) }
                        )
                        .contextMenu {
                            Button("Delete", role: .destructive) {
                                viewModel.deleteProject(project)
                            }
                        }
                    }
                }
            }
        }
        .padding(CARD_PADDING)
        .cardBackground()
        .sheet(isPresented: $viewModel.isProjectModalPresented) {
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
