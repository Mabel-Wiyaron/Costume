//
//  AwardEntryFields.swift
//  Costume
//
//  Created by Matthew Regan Hadiwidjaja on 17/07/26.
//

import SwiftUI

struct AwardEntryFields: View {
    let award: Award

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            LabeledTextField(label: "Award Title", isRequired: true, text: titleBinding)
            LabeledTextField(label: "Provider", isRequired: true, text: issuerBinding)
            LabeledDateField(label: "Year", isRequired: true, date: issueDateBinding)
        }
    }

    private var titleBinding: Binding<String> {
        Binding(get: { award.title }, set: { award.title = $0 })
    }
    private var issuerBinding: Binding<String> {
        Binding(get: { award.issuer }, set: { award.issuer = $0 })
    }
    private var issueDateBinding: Binding<Date> {
        Binding(get: { award.issueDate }, set: { award.issueDate = $0 })
    }
}
