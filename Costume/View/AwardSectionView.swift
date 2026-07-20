//
//  AwardSectionView.swift
//  Costume
//
//  Created by Matthew Regan Hadiwidjaja on 15/07/26.
//

import SwiftUI

struct AwardSectionView: View {
    @Bindable var viewModel: EditProfileViewModel

    private let CARD_PADDING: CGFloat = 32
    private let ROW_SPACING: CGFloat = 12

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            SectionHeaderView(title: "Awards") {
                Button("+ Add Award") {
                    viewModel.startAddingAward()
                }
                .buttonStyle(.borderedProminent)
                .tint(Color("PrimaryColor"))
            }

            if viewModel.profile.awards.isEmpty {
                SectionEmptyStateView(
                    imageName: "AwardsEmptyState",
                    message: "No awards yet."
                )
            } else {
                VStack(spacing: ROW_SPACING) {
                    ForEach(viewModel.profile.awards) { award in
                        ListItemCard(
                            title: award.title,
                            subtitle: award.issuer,
                            action: { viewModel.startEditingAward(award) }
                        )
                        .contextMenu {
                            Button("Delete", role: .destructive) {
                                viewModel.deleteAward(award)
                            }
                        }
                    }
                }
            }
        }
        .padding(CARD_PADDING)
        .cardBackground()
        .sheet(isPresented: $viewModel.isAwardModalPresented) {
            AwardFormModal(
                award: viewModel.awardBeingEdited,
                onSave: viewModel.saveAward,
                onCancel: viewModel.cancelAwardEdit,
                onDelete: viewModel.awardBeingEdited.map { award in
                    {
                        viewModel.deleteAward(award)
                        viewModel.cancelAwardEdit()
                    }
                }
            )
        }
    }
}
