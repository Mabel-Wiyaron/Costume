//
//  ProfileEntrySectionView.swift
//  Costume
//
//  Created by Matthew Regan Hadiwidjaja on 21/07/26.
//

import SwiftUI

struct ProfileEntrySectionView<Item: Identifiable & AnyObject, Modal: View>: View {
    let title: String
    let addButtonLabel: String
    let emptyStateImage: String
    let emptyStateMessage: String
    let items: [Item]
    let itemTitle: (Item) -> String
    let itemSubtitle: (Item) -> String
    let onAdd: () -> Void
    let onSelect: (Item) -> Void
    let onDelete: (Item) -> Void
    @Binding var isModalPresented: Bool
    @ViewBuilder var modal: () -> Modal

    private let CARD_PADDING: CGFloat = 32
    private let ROW_SPACING: CGFloat = 12

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            SectionHeaderView(title: title) {
                Button(addButtonLabel, action: onAdd)
                    .buttonStyle(.borderedProminent)
                    .tint(Color("PrimaryColor"))
            }

            if items.isEmpty {
                SectionEmptyStateView(imageName: emptyStateImage, message: emptyStateMessage)
            } else {
                VStack(spacing: ROW_SPACING) {
                    ForEach(items) { item in
                        ListItemCard(
                            title: itemTitle(item),
                            subtitle: itemSubtitle(item),
                            action: { onSelect(item) }
                        )
                        .contextMenu {
                            Button("Delete", role: .destructive) {
                                onDelete(item)
                            }
                        }
                    }
                }
            }
        }
        .padding(CARD_PADDING)
        .cardBackground()
        .sheet(isPresented: $isModalPresented, content: modal)
    }
}
