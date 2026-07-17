//
//  KeywordTag.swift
//  Costume
//
//  Created by Nayla Abel Sabathyani on 14/07/26.
//

import SwiftUI

extension KeywordStatus {
    var backgroundColor: Color {
        switch self {
        case .included: return Color.green.opacity(0.2)
        case .match: return Color.yellow.opacity(0.2)
        case .missing: return Color.red.opacity(0.2)
        }
    }

    var foregroundColor: Color {
        switch self {
        case .included: return Color.green
        case .match: return Color.orange
        case .missing: return Color.red
        }
    }

    var legendLabel: String {
        switch self {
        case .included: return "Included in CV"
        case .match: return "Match with Profile / Recommended"
        case .missing: return "Missing but Relevant"
        }
    }
}

struct KeywordTag: View {
    let text: String
    let status: KeywordStatus

    var body: some View {
        Text(text)
            .font(.callout)
            .fontWeight(.semibold)
            .foregroundColor(status.foregroundColor)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(status.backgroundColor)
            .clipShape(Capsule())
            .overlay(
                Capsule()
                    .stroke(status.foregroundColor, lineWidth: 1)
            )
    }
}

#Preview {
    VStack(spacing: 16) {
        KeywordTag(text: "Software Design", status: .included)
        KeywordTag(text: "Coding", status: .match)
        KeywordTag(text: "UI UX", status: .missing)
    }
    .padding()
}
