//
//  ListItemCard.swift
//  Costume
//
//  Created by Matthew Regan Hadiwidjaja on 14/07/26.
//

import SwiftUI

struct ListItemCard: View {
    let title: String
    let subtitle: String
    let action: () -> Void

    private let CORNER_RADIUS: CGFloat = 8
    private let PADDING: CGFloat = 16

    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                Text(subtitle)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .contentShape(Rectangle())
            .padding(PADDING)
            .overlay(
                RoundedRectangle(cornerRadius: CORNER_RADIUS)
                    .stroke(Color.black.opacity(0.6), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
}
