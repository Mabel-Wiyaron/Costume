//
//  AwardSectionView.swift
//  Costume
//
//  Created by Matthew Regan Hadiwidjaja on 15/07/26.
//

import SwiftUI

struct AwardSectionView: View {
    @Bindable var viewModel: EditProfileViewModel

    var body: some View {
        ProfileEntrySectionView(
            title: "Awards",
            addButtonLabel: "+ Add Award",
            emptyStateImage: "AwardsEmptyState",
            emptyStateMessage: "No awards yet.",
            items: viewModel.profile.awards,
            itemTitle: { $0.title },
            itemSubtitle: { $0.issuer },
            onAdd: viewModel.startAddingAward,
            onSelect: viewModel.startEditingAward,
            onDelete: viewModel.deleteAward,
            isModalPresented: $viewModel.isAwardModalPresented
        ) {
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
