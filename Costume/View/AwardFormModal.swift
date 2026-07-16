//
//  AwardFormModal.swift
//  Costume
//
//  Created by Matthew Regan Hadiwidjaja on 15/07/26.
//

import SwiftUI

struct AwardFormModal: View {
    let award: Award?
    let onSave: (String, String, Date) -> Void
    let onCancel: () -> Void

    @State private var title: String = ""
    @State private var issuer: String = ""
    @State private var issueDate: Date = Date()

    private let MODAL_PADDING: CGFloat = 32
    private let MODAL_WIDTH: CGFloat = 700

    private var isSaveEnabled: Bool {
        !title.isEmpty && !issuer.isEmpty
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            LabeledTextField(label: "Award Title", isRequired: true, text: $title)
            LabeledTextField(label: "Provider", isRequired: true, text: $issuer)
            LabeledDateField(label: "Year", isRequired: true, date: $issueDate)

            HStack {
                Spacer()
                Button("Cancel") { onCancel() }
                    .buttonStyle(.bordered)
                    .controlSize(.large)

                Button("Save") {
                    onSave(title, issuer, issueDate)
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
        guard let award else { return }
        title = award.title
        issuer = award.issuer
        issueDate = award.issueDate
    }
}
