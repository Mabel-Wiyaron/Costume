//
//  SaveConfirmationToast.swift
//  Costume
//
//  Created by Matthew Regan Hadiwidjaja on 28/07/26.
//

import SwiftUI

struct SaveConfirmationToast: View {
    private let HORIZONTAL_PADDING: CGFloat = 24
    private let VERTICAL_PADDING: CGFloat = 20
    private let CORNER_RADIUS: CGFloat = 20

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 16, weight: .semibold))
            Text("Changes Saved Successfully!")
                .font(.system(size: 15, weight: .semibold))
            Spacer(minLength: 0)
        }
        .foregroundStyle(Color("AppPrimaryColor"))
        .padding(.horizontal, HORIZONTAL_PADDING)
        .padding(.vertical, VERTICAL_PADDING)
        .frame(maxWidth: .infinity)
        .background(Color("CardColor"))
        .clipShape(RoundedRectangle(cornerRadius: CORNER_RADIUS))
        .shadow(color: .black.opacity(0.4), radius: 16, y: 6)
    }
}
