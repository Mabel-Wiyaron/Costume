//
//  CertificationFormModal.swift
//  Costume
//
//  Created by Matthew Regan Hadiwidjaja on 15/07/26.
//

import SwiftUI

struct CertificationFormModal: View {
    let certification: Certification?
    let onSave: (String, String, Date, Date?, String, String) -> Void
    let onCancel: () -> Void

    @State private var name: String = ""
    @State private var issuer: String = ""
    @State private var issueDate: Date = Date()
    @State private var hasExpirationDate: Bool = false
    @State private var expirationDate: Date = Date()
    @State private var credentialID: String = ""
    @State private var credentialURL: String = ""

    private let MODAL_PADDING: CGFloat = 32
    private let MODAL_WIDTH: CGFloat = 700
    private let COLUMN_SPACING: CGFloat = 32

    private var isSaveEnabled: Bool {
        !name.isEmpty && !issuer.isEmpty && !credentialID.isEmpty
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            LabeledTextField(label: "Certification Name", isRequired: true, text: $name)
            LabeledTextField(label: "Provider", isRequired: true, text: $issuer)

            HStack(alignment: .top, spacing: COLUMN_SPACING) {
                LabeledDateField(label: "Issue Date", isRequired: true, date: $issueDate)
                LabeledTextField(label: "Credential ID", isRequired: true, text: $credentialID)
            }

            Toggle("Has expiration date", isOn: $hasExpirationDate)
            if hasExpirationDate {
                LabeledDateField(label: "Expiration Date", date: $expirationDate)
            }

            LabeledTextField(label: "Credential URL", text: $credentialURL)

            HStack {
                Spacer()
                Button("Cancel") { onCancel() }
                    .buttonStyle(.bordered)
                    .controlSize(.large)

                Button("Save") {
                    onSave(
                        name,
                        issuer,
                        issueDate,
                        hasExpirationDate ? expirationDate : nil,
                        credentialID,
                        credentialURL
                    )
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
        guard let certification else { return }
        name = certification.name
        issuer = certification.issuer
        issueDate = certification.issueDate
        if let expiration = certification.expirationDate {
            hasExpirationDate = true
            expirationDate = expiration
        }
        credentialID = certification.credentialID
        credentialURL = certification.credentialURL?.absoluteString ?? ""
    }
}
