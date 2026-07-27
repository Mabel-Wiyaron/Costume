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
    var helperText: String = ""
    @Binding var text: String
    var maxCharacters: Int = 1000
    
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
            if !helperText.isEmpty {
                Text(helperText)
                    .font(.footnote)
                    .foregroundStyle(.gray)
            }
            TextEditor(text: $text)
                .focused($isFocused)
                .font(.body)
                .frame(height: EDITOR_HEIGHT)
                .textEditorStyle(.plain)
                .padding(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(
                            currentBorderColor,
                            lineWidth: isFocused ? 2 : 1
                        )
                )
                .animation(.easeInOut(duration: 0.2), value: isFocused)
                .onChange(of: text) { oldValue, newValue in
                    guard newValue.count > maxCharacters else { return }
                    text = String(newValue.prefix(maxCharacters))
                }
            Text("\(text.count) / \(maxCharacters)")
                .font(.caption)
                .foregroundStyle(
                    text.count >= maxCharacters ? .red : .gray
                )
                .frame(maxWidth: .infinity, alignment: .trailing)
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
