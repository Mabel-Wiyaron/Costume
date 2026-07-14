// MARK: - SectionHeaderView.swift

import SwiftUI

struct SectionHeaderView: View {
    let title: String

    private let RULE_HEIGHT: CGFloat = 2

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.title2.bold())
            Rectangle()
                .fill(Color.accentColor)
                .frame(height: RULE_HEIGHT)
        }
    }
}