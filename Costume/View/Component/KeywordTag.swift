//
//  KeywordTag.swift
//  Costume
//
//  Created by Nayla Abel Sabathyani on 14/07/26.
//

import SwiftUI


enum KeywordStatus {
    case included     // Hijau: Sudah ada di CV
    case match // Kuning: Profil & Job desc cocok, belum ada di CV
    case missing      // Merah: Relate dengan Job desc, belum ada di profil & CV
    
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
        KeywordTag(text: "Packaging Design", status: .included)
    }
    .padding()
}
