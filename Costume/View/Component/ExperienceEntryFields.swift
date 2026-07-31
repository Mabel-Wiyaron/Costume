//
//  ExperienceEntryFields.swift
//  Costume
//
//  Created by Matthew Regan Hadiwidjaja on 17/07/26.
//

import SwiftUI

struct ExperienceEntryFields: View {
    let experience: Experience

    private let COLUMN_SPACING: CGFloat = 32

    private enum Field: Hashable {
        case role, company, location
    }
    @FocusState private var focusedField: Field?

    @State private var roleTouched = false
    @State private var companyTouched = false
    @State private var locationTouched = false

    private var shouldShowRoleError: Bool {
        roleTouched && experience.role.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    private var shouldShowCompanyError: Bool {
        companyTouched && experience.company.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    private var shouldShowLocationError: Bool {
        locationTouched && experience.location.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            LabeledTextField(
                label: "Job Title",
                isRequired: true,
                text: roleBinding,
                isError: shouldShowRoleError,
                errorMessage: "Job title is required"
            )
            .focused($focusedField, equals: .role)

            LabeledPicker(
                label: "Employment Type",
                isRequired: true,
                selection: employmentTypeBinding,
                optionTitle: { $0.title }
            )

            LabeledTextField(
                label: "Company",
                isRequired: true,
                text: companyBinding,
                isError: shouldShowCompanyError,
                errorMessage: "Company name is required"
            )
            .focused($focusedField, equals: .company)

            HStack(alignment: .top, spacing: COLUMN_SPACING) {
                LabeledTextField(
                    label: "Location",
                    isRequired: true,
                    placeholder: "City, Country",
                    text: locationBinding,
                    isError: shouldShowLocationError,
                    errorMessage: "Location is required"
                )
                .focused($focusedField, equals: .location)

                LabeledDateRangeField(label: "Years", isRequired: true, startDate: startDateBinding, endDate: endDateBinding)
            }

            LabeledTextEditor(label: "Description", text: descriptionBinding)
        }
        .onChange(of: focusedField) { oldFocus, newFocus in
            if oldFocus == .role && newFocus != .role { roleTouched = true }
            if oldFocus == .company && newFocus != .company { companyTouched = true }
            if oldFocus == .location && newFocus != .location { locationTouched = true }
        }
        .animation(.default, value: roleTouched)
        .animation(.default, value: companyTouched)
        .animation(.default, value: locationTouched)
    }

    private var roleBinding: Binding<String> {
        Binding(get: { experience.role }, set: { experience.role = $0 })
    }
    private var employmentTypeBinding: Binding<EmploymentType> {
        Binding(get: { experience.employmentType }, set: { experience.employmentType = $0 })
    }
    private var companyBinding: Binding<String> {
        Binding(get: { experience.company }, set: { experience.company = $0 })
    }
    private var locationBinding: Binding<String> {
        Binding(get: { experience.location }, set: { experience.location = $0 })
    }
    private var startDateBinding: Binding<Date> {
        Binding(get: { experience.startDate }, set: { experience.startDate = $0 })
    }
    private var endDateBinding: Binding<Date?> {
        Binding(get: { experience.endDate }, set: { experience.endDate = $0 })
    }
    private var descriptionBinding: Binding<String> {
        Binding(
            get: { experience.descriptionText.joined(separator: "\n") },
            set: { experience.descriptionText = $0.components(separatedBy: "\n") }
        )
    }
}
