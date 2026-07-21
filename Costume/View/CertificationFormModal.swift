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
    var onDelete: (() -> Void)? = nil

    @State private var name: String = ""
    @State private var issuer: String = ""
    @State private var issueDate: Date = Date()
    @State private var hasExpirationDate: Bool = false
    @State private var expirationDate: Date = Date()
    @State private var credentialID: String = ""
    @State private var credentialURL: String = ""

    // --- TRACK INTERAKSI UI ---
    private enum Field: Hashable {
        case name, issuer, credentialID, credentialURL
    }
    @FocusState private var focusedField: Field?
    @State private var nameTouched = false
    @State private var issuerTouched = false
    @State private var credentialIDTouched = false
    @State private var credentialURLTouched = false
    @State private var isDeleteConfirmationPresented = false

    private let MODAL_PADDING: CGFloat = 32
    private let MODAL_WIDTH: CGFloat = 700
    private let COLUMN_SPACING: CGFloat = 32

    // --- LOGIKA VALIDASI DASAR ---
    private var isNameValid: Bool {
        !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    private var isIssuerValid: Bool {
        !issuer.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    private var isCredentialIDValid: Bool {
        !credentialID.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    private var isCredentialURLValid: Bool {
        let trimmedURL = credentialURL.trimmingCharacters(
            in: .whitespacesAndNewlines
        )
        if trimmedURL.isEmpty { return true } // Opsional, kosong berarti sah
        
        let urlRegex = #"^(https?:\/\/)?([\da-z\.-]+)\.([a-z\.]{2,6})(\/[\w \.-]*)*\/?$"#
        let urlPredicate = NSPredicate(format: "SELF MATCHES %@", urlRegex)
        return urlPredicate.evaluate(with: trimmedURL)
    }

    private var isSaveEnabled: Bool {
        isNameValid && isIssuerValid && isCredentialIDValid && isCredentialURLValid
    }

    // --- KONDISI KAPAN ERROR DITAMPILKAN ---
    private var shouldShowNameError: Bool { nameTouched && !isNameValid }
    private var shouldShowIssuerError: Bool { issuerTouched && !isIssuerValid }
    private var shouldShowCredentialIDError: Bool {
        credentialIDTouched && !isCredentialIDValid
    }
    private var shouldShowCredentialURLError: Bool {
        credentialURLTouched && !isCredentialURLValid
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            LabeledTextField(
                label: "Certification Name",
                isRequired: true,
                text: $name,
                isError: shouldShowNameError,
                errorMessage: "Certification name is required"
            )
            .focused($focusedField, equals: .name)

            LabeledTextField(
                label: "Provider",
                isRequired: true,
                text: $issuer,
                isError: shouldShowIssuerError,
                errorMessage: "Provider is required"
            )
            .focused($focusedField, equals: .issuer)

            HStack(alignment: .top, spacing: COLUMN_SPACING) {
                LabeledDateField(
                    label: "Issue Date",
                    isRequired: true,
                    date: $issueDate
                )
                
                LabeledTextField(
                    label: "Credential ID",
                    isRequired: true,
                    text: $credentialID,
                    isError: shouldShowCredentialIDError,
                    errorMessage: "Credential ID is required"
                )
                .focused($focusedField, equals: .credentialID)
                .frame(maxWidth: .infinity)
            }

            Toggle("Has expiration date", isOn: $hasExpirationDate)
            if hasExpirationDate {
                LabeledDateField(
                    label: "Expiration Date",
                    date: $expirationDate
                )
            }

            LabeledTextField(
                label: "Credential URL",
                text: $credentialURL,
                isError: shouldShowCredentialURLError,
                errorMessage: "Enter a valid website link (e.g., https://example.com)"
            )
            .focused($focusedField, equals: .credentialURL)

            HStack {
                if let onDelete {
                    Button("Delete", role: .destructive) {
                        isDeleteConfirmationPresented = true
                    }
                    .buttonStyle(.bordered)
                    .controlSize(.large)
                    .tint(.red)
                }

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
        .alert("Delete this Certification?", isPresented: $isDeleteConfirmationPresented) {
            Button("Cancel", role: .cancel) {}
            Button("Delete", role: .destructive) {
                onDelete?()
            }
        } message: {
            Text("This action can't be undone.")
        }
        .frame(width: MODAL_WIDTH)
        .onAppear(perform: populateFieldsIfEditing)
        // --- DETEKSI PERPINDAHAN FOKUS ---
        .onChange(of: focusedField) {
 oldFocus,
 newFocus in
            if oldFocus == .name && newFocus != .name { nameTouched = true }
            if oldFocus == .issuer && newFocus != .issuer {
                issuerTouched = true
            }
            if oldFocus == .credentialID && newFocus != .credentialID {
                credentialIDTouched = true
            }
            if oldFocus == .credentialURL && newFocus != .credentialURL {
                credentialURLTouched = true
            }
        }
        .animation(.default, value: nameTouched)
        .animation(.default, value: issuerTouched)
        .animation(.default, value: credentialIDTouched)
        .animation(.default, value: credentialURLTouched)
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
