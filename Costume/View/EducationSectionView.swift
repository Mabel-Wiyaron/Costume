//
//  EducationSectionView.swift
//  Costume
//
//  Created by Matthew Regan Hadiwidjaja on 14/07/26.
//

import SwiftUI

struct EducationSectionView: View {
    @Bindable var viewModel: EditProfileViewModel

    private let CARD_PADDING: CGFloat = 32
    private let ROW_SPACING: CGFloat = 12

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            SectionHeaderView(title: "Education") {
                Button("+ Add Education") {
                    viewModel.startAddingEducation()
                }
                .buttonStyle(.borderedProminent)
                .tint(Color("PrimaryColor"))
            }

            VStack(spacing: ROW_SPACING) {
                ForEach(viewModel.profile.educations) { education in
                    ListItemCard(
                        title: education.school,
                        subtitle: "\(education.degree), \(education.fieldOfStudy)",
                        action: { viewModel.startEditingEducation(education) }
                    )
                    .contextMenu {
                        Button("Delete", role: .destructive) {
                            viewModel.deleteEducation(education)
                        }
                    }
                }
            }
        }
        .padding(CARD_PADDING)
        .cardBackground()
        .sheet(isPresented: $viewModel.isEducationModalPresented) {
            EducationFormModal(
                education: viewModel.educationBeingEdited,
                onSave: viewModel.saveEducation,
                onCancel: viewModel.cancelEducationEdit
            )
        }
    }
}
