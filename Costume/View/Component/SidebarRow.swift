//
//  SidebarRow.swift
//  Costume
//
//  Created by Matthew Regan Hadiwidjaja on 14/07/26.
//

import SwiftUI

struct SidebarRow: View {
    let section: ProfileSection
    let isSelected: Bool
    let action: () -> Void

    private let CORNER_RADIUS: CGFloat = 8
    private let VERTICAL_PADDING: CGFloat = 10
    private let HORIZONTAL_PADDING: CGFloat = 12

    var body: some View {
        Button(action: action) {
            Label(section.title, systemImage: section.iconName)
                .font(.title3)
                .foregroundStyle(isSelected ? Color("PrimaryColor") : Color.white)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.vertical, VERTICAL_PADDING)
                .padding(.horizontal, HORIZONTAL_PADDING)
                .background(isSelected ? Color("BackgroundColor") : Color.clear)
                .clipShape(RoundedRectangle(cornerRadius: CORNER_RADIUS))
        }
        .buttonStyle(.plain)
    }
}
