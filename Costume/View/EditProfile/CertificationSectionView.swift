//
//  CertificationSectionView.swift
//  Costume
//
//  Created by Matthew Regan Hadiwidjaja on 15/07/26.
//

import SwiftUI

struct CertificationSectionView: View {
    @Bindable var viewModel: EditProfileViewModel

    var body: some View {
        ProfileEntrySectionView(
            title: "Certifications",
            addButtonLabel: "+ Add Certification",
            emptyStateImage: "CertificationEmptyState",
            emptyStateMessage: "No certifications yet.",
            items: viewModel.profile.certifications,
            itemTitle: { $0.name },
            itemSubtitle: { $0.issuer },
            onAdd: viewModel.startAddingCertification,
            onSelect: viewModel.startEditingCertification,
            onDelete: viewModel.deleteCertification,
            isModalPresented: $viewModel.isCertificationModalPresented
        ) {
            CertificationFormModal(
                certification: viewModel.certificationBeingEdited,
                onSave: viewModel.saveCertification,
                onCancel: viewModel.cancelCertificationEdit,
                onDelete: viewModel.certificationBeingEdited.map { certification in
                    {
                        viewModel.deleteCertification(certification)
                        viewModel.cancelCertificationEdit()
                    }
                }
            )
        }
    }
}
