//
//  LabeledTextField.swift
//  Costume
//
//  Created by Matthew Regan Hadiwidjaja on 14/07/26.
//

import SwiftUI

struct LabeledTextField: View {
    let label: String
    var isRequired: Bool = false
    var placeholder: String = ""
    @Binding var text: String
    
    var isError: Bool = false
    @FocusState var isFocused: Bool
    
    var errorMessage: String? = nil
    
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
            TextField(placeholder, text: $text)
                .focused($isFocused)
                .textFieldStyle(.plain)
                .padding(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(currentBorderColor, lineWidth: isFocused || isError ? 2 : 1)
                )
                .animation(.easeInOut(duration: 0.2), value: isFocused)
                .animation(.easeInOut(duration: 0.2), value: isError)
            
            // Menampilkan inline error text tepat di bawah kotak input
            if isError, let errorMessage = errorMessage {
                HStack(alignment: .firstTextBaseline, spacing: 4) {
                    // Ikon tanda seru dalam lingkaran dari SF Symbols
                    Image(systemName: "exclamationmark.circle.fill")
                        .font(.caption)
                        .foregroundColor(.red)
                    
                    Text(errorMessage)
                        .font(.caption)
                        .foregroundColor(.red)
                }.transition(.opacity)
            }
            
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    private var currentBorderColor: Color {
        if isFocused {
            return .orange
        } else if isError {
            return .red
        } else {
            return .black
        }
    }
}
