// MARK: - ProfileSidebarView.swift

import SwiftUI

struct ProfileSidebarView: View {
    @Binding var selectedSection: ProfileSection?
    var onBack: (() -> Void)? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Button(action: { onBack?() }) {
                    Image(systemName: "chevron.left")
                }
                .buttonStyle(.plain)
                Spacer()
            }

            Text("Edit Profile")
                .font(.title2.bold())
                .padding(.horizontal, 4)

            List(ProfileSection.allCases, selection: $selectedSection) { section in
                SidebarRow(section: section)
            }
            .listStyle(.sidebar)
            .scrollContentBackground(.hidden)
        }
        .padding(.top, 16)
        .padding(.horizontal, 16)
    }
}