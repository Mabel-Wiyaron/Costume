// MARK: - SidebarRow.swift

import SwiftUI

struct SidebarRow: View {
    let section: ProfileSection

    var body: some View {
        Label(section.title, systemImage: section.iconName)
            .font(.body)
            .padding(.vertical, 4)
    }
}