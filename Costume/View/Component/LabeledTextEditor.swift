// MARK: - LabeledTextEditor.swift

import SwiftUI

struct LabeledTextEditor: View {
    let label: String
    var isRequired: Bool = false
    @Binding var text: String

    private let EDITOR_HEIGHT: CGFloat = 160
    private let CORNER_RADIUS: CGFloat = 6

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 2) {
                Text(label)
                    .font(.headline)
                if isRequired {
                    Text("*")
                        .font(.headline)
                        .foregroundStyle(.red)
                }
            }
            TextEditor(text: $text)
                .font(.body)
                .frame(height: EDITOR_HEIGHT)
                .padding(4)
                .overlay(
                    RoundedRectangle(cornerRadius: CORNER_RADIUS)
                        .stroke(Color.secondary.opacity(0.3), lineWidth: 1)
                )
        }
    }
}