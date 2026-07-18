//
//  InlineEntryListCard.swift
//  Costume
//
//  Created by Matthew Regan Hadiwidjaja on 17/07/26.
//

import SwiftUI

struct InlineEntryListCard<Item: Identifiable & AnyObject, EntryFields: View>: View {
    let title: String
    let addButtonLabel: String
    let entryTitle: (Int) -> String
    let items: [Item]
    let onAdd: () -> Void
    let onDelete: (Item) -> Void
    @ViewBuilder var entryFields: (Item) -> EntryFields

    private let CARD_PADDING: CGFloat = 32
    private let ENTRY_SPACING: CGFloat = 20
    private let DIVIDER_HEIGHT: CGFloat = 1

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            SectionHeaderView(title: title) {
                Button(addButtonLabel, action: onAdd)
                    .buttonStyle(.borderedProminent)
                    .tint(Color("PrimaryColor"))
            }

            VStack(alignment: .leading, spacing: ENTRY_SPACING) {
                ForEach(Array(items.enumerated()), id: \.element.id) { index, item in
                    VStack(alignment: .leading, spacing: ENTRY_SPACING) {
                        entryHeader(index: index, item: item)
                        entryFields(item)
                    }

                    if index < items.count - 1 {
                        Rectangle()
                            .fill(Color("AccentColor"))
                            .frame(height: DIVIDER_HEIGHT)
                    }
                }
            }
        }
        .padding(CARD_PADDING)
        .cardBackground()
    }

    private func entryHeader(index: Int, item: Item) -> some View {
        HStack {
            Text(entryTitle(index))
                .font(.title3)
                .fontWeight(.bold)
            Spacer()
            Button {
                onDelete(item)
            } label: {
                Image(systemName: "trash")
                    .foregroundStyle(.red)
            }
            .buttonStyle(.plain)
        }
    }
}
