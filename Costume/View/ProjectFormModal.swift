//
//  ProjectFormModal.swift
//  Costume
//
//  Created by Matthew Regan Hadiwidjaja on 15/07/26.
//

import SwiftUI

struct ProjectFormModal: View {
    let project: Project?
    let onSave: (String, String, Date, Date?, String, [String]) -> Void
    let onCancel: () -> Void

    @State private var name: String = ""
    @State private var role: String = ""
    @State private var startDate: Date = Date()
    @State private var endDate: Date? = nil
    @State private var website: String = ""
    @State private var descriptionText: String = ""

    private let MODAL_PADDING: CGFloat = 32
    private let MODAL_WIDTH: CGFloat = 700
    private let COLUMN_SPACING: CGFloat = 32

    private var isSaveEnabled: Bool {
        !name.isEmpty && !role.isEmpty
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            LabeledTextField(label: "Project Name", isRequired: true, text: $name)

            HStack(alignment: .top, spacing: COLUMN_SPACING) {
                LabeledTextField(label: "Fields", isRequired: true, text: $role)
                LabeledDateRangeField(label: "Years", isRequired: true, startDate: $startDate, endDate: $endDate)
            }

            LabeledTextField(label: "Website", text: $website)

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
                    onSave(name, role, startDate, endDate, website, lines)
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
        guard let project else { return }
        name = project.name
        role = project.role
        startDate = project.startDate
        endDate = project.endDate
        website = project.website?.absoluteString ?? ""
        descriptionText = project.descriptionText.joined(separator: "\n")
    }
}
