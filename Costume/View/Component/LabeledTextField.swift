// MARK: - LabeledTextField.swift

import SwiftUI

struct LabeledTextField: View {
    let label: String
    var isRequired: Bool = false
    var placeholder: String = ""
    @Binding var text: String

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
            TextField(placeholder, text: $text)
                .textFieldStyle(.roundedBorder)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}