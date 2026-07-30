//
//  AwardEntryFields.swift
//  Costume
//
//  Created by Matthew Regan Hadiwidjaja on 17/07/26.
//

import SwiftUI

struct AwardEntryFields: View {
    let award: Award

    private enum Field: Hashable {
        case title, issuer
    }
    @FocusState private var focusedField: Field?

    @State private var titleTouched = false
    @State private var issuerTouched = false

    private var shouldShowTitleError: Bool {
        titleTouched && award.title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    private var shouldShowIssuerError: Bool {
        issuerTouched && award.issuer.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            LabeledTextField(
                label: "Award Title",
                isRequired: true,
                text: titleBinding,
                isError: shouldShowTitleError,
                errorMessage: "Award title is required"
            )
            .focused($focusedField, equals: .title)

            LabeledTextField(
                label: "Provider",
                isRequired: true,
                text: issuerBinding,
                isError: shouldShowIssuerError,
                errorMessage: "Provider is required"
            )
            .focused($focusedField, equals: .issuer)

            LabeledDateField(label: "Year", isRequired: true, date: issueDateBinding)
        }
        .onChange(of: focusedField) { oldFocus, newFocus in
            if oldFocus == .title && newFocus != .title { titleTouched = true }
            if oldFocus == .issuer && newFocus != .issuer { issuerTouched = true }
        }
        .animation(.default, value: titleTouched)
        .animation(.default, value: issuerTouched)
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
