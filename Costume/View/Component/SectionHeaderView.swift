//
//  SectionHeaderView.swift
//  Costume
//
//  Created by Matthew Regan Hadiwidjaja on 14/07/26.
//

import SwiftUI

struct SectionHeaderView<Trailing: View>: View {
    let title: String
    @ViewBuilder var trailing: () -> Trailing

    private let RULE_HEIGHT: CGFloat = 2
    private let TRAILING_SPACING: CGFloat = 16

    var body: some View {
        HStack(alignment: .bottom, spacing: TRAILING_SPACING) {
            VStack(alignment: .leading, spacing: 10) {
                Text(title)
                    .font(.title2)
                    .fontWeight(.bold)
                
                Rectangle()
                    .fill(Color("AccentColor"))
                    .frame(height: RULE_HEIGHT)
            }
            trailing()
        }
    }
}

extension SectionHeaderView where Trailing == EmptyView {
    init(title: String) {
        self.title = title
        self.trailing = { EmptyView() }
    }
}
