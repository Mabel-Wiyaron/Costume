//
//  LabeledDateField.swift
//  Costume
//
//  Created by Matthew Regan Hadiwidjaja on 15/07/26.
//

import SwiftUI

struct LabeledDateField: View {
    let label: String
    var isRequired: Bool = false
    @Binding var date: Date

    @State private var isPickerPresented: Bool = false

    private var displayText: String {
        formatted(date)
    }

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
            Button {
                isPickerPresented = true
            } label: {
                Text(displayText)
                    .foregroundStyle(.primary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.black, lineWidth: 1)
                    )
            }
            .buttonStyle(.plain)
            .popover(isPresented: $isPickerPresented) {
                DatePicker(label, selection: $date, displayedComponents: .date)
                    .padding()
                    .frame(width: 260)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func formatted(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM yyyy"
        return formatter.string(from: date)
    }
}
