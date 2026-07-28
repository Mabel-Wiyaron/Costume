//
//  ProfileSidebarView.swift
//  Costume
//
//  Created by Matthew Regan Hadiwidjaja on 14/07/26.
//

import SwiftUI

struct ProfileSidebarView: View {
    @Binding var selectedSection: ProfileSection?
    var onSelect: ((ProfileSection) -> Void)? = nil
    var onBack: (() -> Void)? = nil

    var body: some View {
        ZStack {
            Color("AppPrimaryColor")
                .ignoresSafeArea()

            VStack(alignment: .leading, spacing: 16) {
                Text("Edit Profile")
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundStyle(Color.white)
                    .padding(.horizontal, 4)

                VStack(alignment: .leading, spacing: 4) {
                    ForEach(ProfileSection.allCases) { section in
                        SidebarRow(
                            section: section,
                            isSelected: section == selectedSection,
                            action: {
                                if let onSelect {
                                    onSelect(section)
                                } else {
                                    selectedSection = section
                                }
                            }
                        )
                    }
                }

                Spacer()
            }
            .padding(.top, 16)
            .padding(.horizontal, 16)
        }
    }
}
