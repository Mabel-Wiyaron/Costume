//
//  LabeledDateRangeField.swift
//  Costume
//
//  Created by Matthew Regan Hadiwidjaja on 14/07/26.
//

import SwiftUI

struct LabeledDateRangeField: View {
    let label: String
    var isRequired: Bool = false
    @Binding var startDate: Date
    @Binding var endDate: Date?

    @State private var isPickerPresented: Bool = false

    private var displayText: String {
        let start = formatted(startDate)
        let end = endDate.map(formatted) ?? "Present"
        return "\(start) - \(end)"
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
                datePickerContent
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var datePickerContent: some View {
        VStack(alignment: .leading, spacing: 16) {
            DatePicker("Start", selection: $startDate, displayedComponents: .date)

            Toggle("Currently ongoing", isOn: Binding(
                get: { endDate == nil },
                set: { isOngoing in endDate = isOngoing ? nil : Date() }
            ))

            if endDate != nil {
                DatePicker(
                    "End",
                    selection: Binding(
                        get: { endDate ?? Date() },
                        set: { endDate = $0 }
                    ),
                    displayedComponents: .date
                )
            }
        }
        .padding()
        .frame(width: 260)
    }

    private func formatted(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM yyyy"
        return formatter.string(from: date)
    }
}
