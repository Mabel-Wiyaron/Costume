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

    // --- TRACK INTERAKSI UI ---
    private enum Field: Hashable {
        case name, role, website
    }
    @FocusState private var focusedField: Field?
    @State private var nameTouched = false
    @State private var roleTouched = false
    @State private var websiteTouched = false

    private let MODAL_PADDING: CGFloat = 32
    private let MODAL_WIDTH: CGFloat = 700
    private let COLUMN_SPACING: CGFloat = 32

    // --- LOGIKA VALIDASI DASAR ---
    private var isNameValid: Bool {
        !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    private var isRoleValid: Bool {
        !role.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    private var isWebsiteValid: Bool {
        let trimmedURL = website.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmedURL.isEmpty { return true } // Kosong bersifat opsional
        
        let urlRegex = #"^(https?:\/\/)?([\da-z\.-]+)\.([a-z\.]{2,6})(\/[\w \.-]*)*\/?$"#
        let urlPredicate = NSPredicate(format: "SELF MATCHES %@", urlRegex)
        return urlPredicate.evaluate(with: trimmedURL)
    }

    private var isSaveEnabled: Bool {
        isNameValid && isRoleValid && isWebsiteValid
    }

    // --- KONDISI TAMPILAN ERROR ---
    private var shouldShowNameError: Bool { nameTouched && !isNameValid }
    private var shouldShowRoleError: Bool { roleTouched && !isRoleValid }
    private var shouldShowWebsiteError: Bool { websiteTouched && !isWebsiteValid }

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            LabeledTextField(
                label: "Project Name",
                isRequired: true,
                text: $name,
                isError: shouldShowNameError,
                errorMessage: "Project name is required"
            )
            .focused($focusedField, equals: .name)

            HStack(alignment: .top, spacing: COLUMN_SPACING) {
                LabeledTextField(
                    label: "Fields",
                    isRequired: true,
                    text: $role,
                    isError: shouldShowRoleError,
                    errorMessage: "Fields are required"
                )
                .focused($focusedField, equals: .role)
                .frame(maxWidth: .infinity)
                
                LabeledDateRangeField(label: "Years", isRequired: true, startDate: $startDate, endDate: $endDate)
                    .frame(maxWidth: .infinity)
            }

            LabeledTextField(
                label: "Website",
                text: $website,
                isError: shouldShowWebsiteError,
                errorMessage: "Enter a valid website link (e.g., https://example.com)"
            )
            .focused($focusedField, equals: .website)

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
        // --- DETEKSI PERPINDAHAN FOKUS ---
        .onChange(of: focusedField) { oldFocus, newFocus in
            if oldFocus == .name && newFocus != .name { nameTouched = true }
            if oldFocus == .role && newFocus != .role { roleTouched = true }
            if oldFocus == .website && newFocus != .website { websiteTouched = true }
        }
        .animation(.default, value: nameTouched)
        .animation(.default, value: roleTouched)
        .animation(.default, value: websiteTouched)
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
