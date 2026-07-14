//
//  SectionHeaderView.swift
//  Costume
//
//  Created by Matthew Regan Hadiwidjaja on 14/07/26.
//

import SwiftUI

struct SectionHeaderView: View {
    let title: String

    private let RULE_HEIGHT: CGFloat = 2

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.title2)
                .fontWeight(.bold)
            Rectangle()
                .fill(Color("AccentColor"))
                .frame(height: RULE_HEIGHT)
        }
    }
}
