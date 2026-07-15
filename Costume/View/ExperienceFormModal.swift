//
//  ExperienceFormModal.swift
//  Costume
//
//  Created by Matthew Regan Hadiwidjaja on 15/07/26.
//

import SwiftUI

struct ExperienceFormModal: View {
    let experience: Experience?
    let onSave: (String, EmploymentType, String, String, Date, Date?, [String]) -> Void
    let onCancel: () -> Void

    @State private var role: String = ""
    @State private var employmentType: EmploymentType = .fullTime
    @State private var company: String = ""
    @State private var location: String = ""
    @State private var startDate: Date = Date()
    @State private var endDate: Date? = nil
    @State private var descriptionText: String = ""

    private let MODAL_PADDING: CGFloat = 32
    private let MODAL_WIDTH: CGFloat = 700
    private let COLUMN_SPACING: CGFloat = 32

    private var isSaveEnabled: Bool {
        !role.isEmpty && !company.isEmpty && !location.isEmpty
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            LabeledTextField(label: "Job Title", isRequired: true, text: $role)
            LabeledPicker(
                label: "Employment Type",
                isRequired: true,
                selection: $employmentType,
                optionTitle: { $0.title }
            )
            LabeledTextField(label: "Company", isRequired: true, text: $company)

            HStack(alignment: .top, spacing: COLUMN_SPACING) {
                LabeledTextField(label: "Location", isRequired: true, placeholder: "City, Country", text: $location)
                LabeledDateRangeField(label: "Years", isRequired: true, startDate: $startDate, endDate: $endDate)
            }

            LabeledTextEditor(label: "Description", text: $descriptionText)

            HStack {
                Spacer()
                Button("Cancel") { onCancel() }
                    .buttonStyle(.bordered)
                    .controlSize(.large)

                Button("Save") {
                    let lines = descriptionText
                        .split(separator: "\n")
                        .map { $0.trimmingCharacters(in: .whitespaces) }
                        .filter { !$0.isEmpty }
                    onSave(role, employmentType, company, location, startDate, endDate, lines)
                }
                .buttonStyle(.borderedProminent)
                .tint(Color("PrimaryColor"))
                .controlSize(.large)
                .keyboardShortcut(.defaultAction)
                .disabled(!isSaveEnabled)
            }
        }
        .padding(MODAL_PADDING)
        .frame(width: MODAL_WIDTH)
        .onAppear(perform: populateFieldsIfEditing)
    }

    private func populateFieldsIfEditing() {
        guard let experience else { return }
        role = experience.role
        employmentType = experience.employmentType
        company = experience.company
        location = experience.location
        startDate = experience.startDate
        endDate = experience.endDate
        descriptionText = experience.descriptionText.joined(separator: "\n")
    }
}
