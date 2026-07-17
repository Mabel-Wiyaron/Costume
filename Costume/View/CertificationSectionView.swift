//
//  CertificationSectionView.swift
//  Costume
//
//  Created by Matthew Regan Hadiwidjaja on 15/07/26.
//

import SwiftUI

struct CertificationSectionView: View {
    @Bindable var viewModel: EditProfileViewModel

    private let CARD_PADDING: CGFloat = 32
    private let ROW_SPACING: CGFloat = 12

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            SectionHeaderView(title: "Certifications") {
                Button("+ Add Certification") {
                    viewModel.startAddingCertification()
                }
                .buttonStyle(.borderedProminent)
                .tint(Color("PrimaryColor"))
            }

            VStack(spacing: ROW_SPACING) {
                ForEach(viewModel.profile.certifications) { certification in
                    ListItemCard(
                        title: certification.name,
                        subtitle: certification.issuer,
                        action: { viewModel.startEditingCertification(certification) }
                    )
                    .contextMenu {
                        Button("Delete", role: .destructive) {
                            viewModel.deleteCertification(certification)
                        }
                    }
                }
            }
        }
        .padding(CARD_PADDING)
        .cardBackground()
        .sheet(isPresented: $viewModel.isCertificationModalPresented) {
            CertificationFormModal(
                certification: viewModel.certificationBeingEdited,
                onSave: viewModel.saveCertification,
                onCancel: viewModel.cancelCertificationEdit
            )
        }
    }
}
