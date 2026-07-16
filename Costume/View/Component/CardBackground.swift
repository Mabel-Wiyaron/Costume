//
//  CardBackground.swift
//  Costume
//
//  Created by Matthew Regan Hadiwidjaja on 14/07/26.
//

import SwiftUI

struct CardBackground: ViewModifier {
    private let CORNER_RADIUS: CGFloat = 16
    private let SHADOW_RADIUS: CGFloat = 10
    private let SHADOW_OPACITY: CGFloat = 0.08

    func body(content: Content) -> some View {
        content
            .background(Color.card)
            .clipShape(RoundedRectangle(cornerRadius: CORNER_RADIUS))
            .shadow(color: .black.opacity(SHADOW_OPACITY), radius: SHADOW_RADIUS, y: 2)
            .background(
                RoundedRectangle(cornerRadius: CORNER_RADIUS)
                    .fill(Color.accentColor)
                    .offset(y: 8)
            )
            .padding(.bottom, 8)
    }
}

extension View {
    func cardBackground() -> some View {
        modifier(CardBackground())
    }
}
