//
//  ProjectEntryFields.swift
//  Costume
//
//  Created by Matthew Regan Hadiwidjaja on 17/07/26.
//

import SwiftUI

struct ProjectEntryFields: View {
    let project: Project

    private let COLUMN_SPACING: CGFloat = 32

    private enum Field: Hashable {
        case name, role
    }
    @FocusState private var focusedField: Field?

    @State private var nameTouched = false
    @State private var roleTouched = false

    private var shouldShowNameError: Bool {
        nameTouched && project.name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    private var shouldShowRoleError: Bool {
        roleTouched && project.role.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            LabeledTextField(
                label: "Project Name",
                isRequired: true,
                text: nameBinding,
                isError: shouldShowNameError,
                errorMessage: "Project name is required"
            )
            .focused($focusedField, equals: .name)

            HStack(alignment: .top, spacing: COLUMN_SPACING) {
                LabeledTextField(
                    label: "Fields",
                    isRequired: true,
                    text: roleBinding,
                    isError: shouldShowRoleError,
                    errorMessage: "Fields are required"
                )
                .focused($focusedField, equals: .role)

                LabeledDateRangeField(label: "Years", isRequired: true, startDate: startDateBinding, endDate: endDateBinding)
            }

            LabeledTextField(label: "Website", text: websiteBinding)
            LabeledTextEditor(label: "Description", text: descriptionBinding)
        }
        .onChange(of: focusedField) { oldFocus, newFocus in
            if oldFocus == .name && newFocus != .name { nameTouched = true }
            if oldFocus == .role && newFocus != .role { roleTouched = true }
        }
        .animation(.default, value: nameTouched)
        .animation(.default, value: roleTouched)
    }

    private var nameBinding: Binding<String> {
        Binding(get: { project.name }, set: { project.name = $0 })
    }
    private var roleBinding: Binding<String> {
        Binding(get: { project.role }, set: { project.role = $0 })
    }
    private var startDateBinding: Binding<Date> {
        Binding(get: { project.startDate }, set: { project.startDate = $0 })
    }
    private var endDateBinding: Binding<Date?> {
        Binding(get: { project.endDate }, set: { project.endDate = $0 })
    }
    private var websiteBinding: Binding<String> {
        Binding(get: { project.website }, set: { project.website = $0 }).stringValue
    }
    private var descriptionBinding: Binding<String> {
        Binding(
            get: { project.descriptionText.joined(separator: "\n") },
            set: { project.descriptionText = $0.components(separatedBy: "\n") }
        )
    }
}
