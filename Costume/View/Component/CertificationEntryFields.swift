//
//  CertificationEntryFields.swift
//  Costume
//
//  Created by Matthew Regan Hadiwidjaja on 17/07/26.
//

import SwiftUI

struct CertificationEntryFields: View {
    let certification: Certification

    private let COLUMN_SPACING: CGFloat = 32

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            LabeledTextField(label: "Certification Name", isRequired: true, text: nameBinding)
            LabeledTextField(label: "Provider", isRequired: true, text: issuerBinding)

            HStack(alignment: .top, spacing: COLUMN_SPACING) {
                LabeledDateField(label: "Issue Date", isRequired: true, date: issueDateBinding)
                LabeledTextField(label: "Credential ID", isRequired: true, text: credentialIDBinding)
            }

            Toggle("Has expiration date", isOn: hasExpirationBinding)
            if certification.expirationDate != nil {
                LabeledDateField(label: "Expiration Date", date: expirationDateBinding)
            }

            LabeledTextField(label: "Credential URL", text: credentialURLBinding)
        }
    }

    private var nameBinding: Binding<String> {
        Binding(get: { certification.name }, set: { certification.name = $0 })
    }
    private var issuerBinding: Binding<String> {
        Binding(get: { certification.issuer }, set: { certification.issuer = $0 })
    }
    private var issueDateBinding: Binding<Date> {
        Binding(get: { certification.issueDate }, set: { certification.issueDate = $0 })
    }
    private var credentialIDBinding: Binding<String> {
        Binding(get: { certification.credentialID }, set: { certification.credentialID = $0 })
    }
    private var hasExpirationBinding: Binding<Bool> {
        Binding(
            get: { certification.expirationDate != nil },
            set: { certification.expirationDate = $0 ? Date() : nil }
        )
    }
    private var expirationDateBinding: Binding<Date> {
        Binding(
            get: { certification.expirationDate ?? Date() },
            set: { certification.expirationDate = $0 }
        )
    }
    private var credentialURLBinding: Binding<String> {
        Binding(get: { certification.credentialURL }, set: { certification.credentialURL = $0 }).stringValue
    }
}
