//
//  SectionEmptyStateView.swift
//  Costume
//
//  Created by Matthew Regan Hadiwidjaja on 20/07/26.
//

import SwiftUI

struct SectionEmptyStateView: View {
    let imageName: String
    let message: String

    private let IMAGE_HEIGHT: CGFloat = 100
    private let VERTICAL_PADDING: CGFloat = 24

    var body: some View {
        VStack(spacing: 8) {
            Image(imageName)
                .resizable()
                .scaledToFit()
                .frame(height: IMAGE_HEIGHT)
            Text(message)
                .font(.body)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, VERTICAL_PADDING)
    }
}
