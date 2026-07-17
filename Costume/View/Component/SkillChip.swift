//
//  SkillChip.swift
//  Costume
//
//  Created by Matthew Regan Hadiwidjaja on 15/07/26.
//

import SwiftUI

struct SkillChip: View {
    let name: String
    let onRemove: () -> Void

    private let HORIZONTAL_PADDING: CGFloat = 12
    private let VERTICAL_PADDING: CGFloat = 6

    var body: some View {
        HStack(spacing: 6) {
            Text(name)
                .font(.subheadline)
            Button(action: onRemove) {
                Image(systemName: "xmark.circle.fill")
                    .foregroundStyle(.secondary)
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, HORIZONTAL_PADDING)
        .padding(.vertical, VERTICAL_PADDING)
        .background(Color("BackgroundColor"))
        .clipShape(Capsule())
        .overlay(
            Capsule()
                .stroke(Color.black.opacity(0.2), lineWidth: 1)
        )
    }
}
