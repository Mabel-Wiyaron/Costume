//
//  LabeledTextEditor.swift
//  Costume
//
//  Created by Matthew Regan Hadiwidjaja on 14/07/26.
//

import SwiftUI

struct LabeledTextEditor: View {
    let label: String
    var isRequired: Bool = false
    @Binding var text: String
    
    @FocusState var isFocused: Bool

    private let EDITOR_HEIGHT: CGFloat = 160
    private let CORNER_RADIUS: CGFloat = 6

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 2) {
                Text(label)
                    .font(.title3)
                    .fontWeight(.semibold)
                if isRequired {
                    Text("*")
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundStyle(.red)
                }
            }
            TextEditor(text: $text)
                .focused($isFocused)
                .font(.body)
                .frame(height: EDITOR_HEIGHT)
                .textEditorStyle(.plain)
                .padding(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(currentBorderColor, lineWidth: isFocused ? 2 : 1)
                )
                .animation(.easeInOut(duration: 0.2), value: isFocused)
        }
    }
    
    private var currentBorderColor: Color {
        if isFocused {
            return .orange
        } else {
            return .black
        }
    }
}
