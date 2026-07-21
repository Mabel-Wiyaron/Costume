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
    var onDelete: (() -> Void)? = nil

    @State private var title: String = ""
    @State private var issuer: String = ""
    @State private var issueDate: Date = Date()

    // --- TRACK INTERAKSI UI ---
    private enum Field: Hashable {
        case title, issuer
    }
    @FocusState private var focusedField: Field?
    @State private var titleTouched = false
    @State private var issuerTouched = false
    @State private var isDeleteConfirmationPresented = false

    private let MODAL_PADDING: CGFloat = 32
    private let MODAL_WIDTH: CGFloat = 700

    // Validasi dasar (untuk tombol Save)
    private var isTitleValid: Bool {
        !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    private var isIssuerValid: Bool {
        !issuer.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    private var isSaveEnabled: Bool {
        isTitleValid && isIssuerValid
    }

    // Properti Tampilan Error (hanya jika sudah disentuh & tidak valid)
    private var shouldShowTitleError: Bool {
        titleTouched && !isTitleValid
    }

    private var shouldShowIssuerError: Bool {
        issuerTouched && !isIssuerValid
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            LabeledTextField(
                label: "Award Title",
                isRequired: true,
                text: $title,
                isError: shouldShowTitleError,
                errorMessage: "Award title is required"
            )
            .focused($focusedField, equals: .title)

            LabeledTextField(
                label: "Provider",
                isRequired: true,
                text: $issuer,
                isError: shouldShowIssuerError,
                errorMessage: "Provider is required"
            )
            .focused($focusedField, equals: .issuer)

            LabeledDateField(label: "Year", isRequired: true, date: $issueDate)

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
        .alert("Delete this Award?", isPresented: $isDeleteConfirmationPresented) {
            Button("Cancel", role: .cancel) {}
            Button("Delete", role: .destructive) {
                onDelete?()
            }
        } message: {
            Text("This action can't be undone.")
        }
        .frame(width: MODAL_WIDTH)
        .onAppear(perform: populateFieldsIfEditing)
        // --- DETEKSI KAPAN USER PINDAH FOKUS ---
        .onChange(of: focusedField) {
 oldFocus,
 newFocus in
            if oldFocus == .title && newFocus != .title { titleTouched = true }
            if oldFocus == .issuer && newFocus != .issuer {
                issuerTouched = true
            }
        }
        .animation(.default, value: titleTouched)
        .animation(.default, value: issuerTouched)
    }

    private func populateFieldsIfEditing() {
        guard let award else { return }
        title = award.title
        issuer = award.issuer
        issueDate = award.issueDate
    }
}
