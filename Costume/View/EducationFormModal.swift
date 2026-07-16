//
//  EducationFormModal.swift
//  Costume
//
//  Created by Matthew Regan Hadiwidjaja on 14/07/26.
//

import SwiftUI

struct EducationFormModal: View {
    let education: Education?
    let onSave: (String, String, String, String?, Date, Date?) -> Void
    let onCancel: () -> Void

    @State private var school: String = ""
    @State private var degree: String = ""
    @State private var fieldOfStudy: String = ""
    @State private var grade: String = ""
    @State private var startDate: Date = Date()
    @State private var endDate: Date? = nil

    // State untuk melacak field mana yang sedang aktif
    private enum Field: Hashable {
        case school, degree, fieldOfStudy
    }
    @FocusState private var focusedField: Field?

    // State untuk menandai apakah user sudah berinteraksi dengan field terkait
    @State private var schoolTouched = false
    @State private var degreeTouched = false
    @State private var fieldOfStudyTouched = false

    private let MODAL_PADDING: CGFloat = 32
    private let MODAL_WIDTH: CGFloat = 700
    private let COLUMN_SPACING: CGFloat = 32

    // Tombol Save aktif hanya jika semua field wajib diisi dan tidak kosong/spasi saja
    private var isSaveEnabled: Bool {
        let cleanSchool = school.trimmingCharacters(in: .whitespacesAndNewlines)
        let cleanDegree = degree.trimmingCharacters(in: .whitespacesAndNewlines)
        let cleanField = fieldOfStudy.trimmingCharacters(in: .whitespacesAndNewlines)
        
        return !cleanSchool.isEmpty && !cleanDegree.isEmpty && !cleanField.isEmpty
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            LabeledTextField(
                label: "School",
                isRequired: true,
                text: $school,
                isError: shouldShowSchoolError,
                errorMessage: "School name is required"
            )
            .focused($focusedField, equals: .school)

            LabeledTextField(
                label: "Degree",
                isRequired: true,
                text: $degree,
                isError: shouldShowDegreeError,
                errorMessage: "Degree is required"
            )
            .focused($focusedField, equals: .degree)

            LabeledTextField(
                label: "Field of Study",
                isRequired: true,
                text: $fieldOfStudy,
                isError: shouldShowFieldOfStudyError,
                errorMessage: "Field of study is required"
            )
            .focused($focusedField, equals: .fieldOfStudy)

            HStack(alignment: .top, spacing: COLUMN_SPACING) {
                LabeledTextField(label: "Grade", text: $grade)
                    .frame(maxWidth: .infinity)
                
                LabeledDateRangeField(
                    label: "Years",
                    isRequired: true,
                    startDate: $startDate,
                    endDate: $endDate
                )
                .frame(maxWidth: .infinity)
            }

            HStack {
                Spacer()
                Button("Cancel") {
                    onCancel()
                }
                .buttonStyle(.bordered)
                .controlSize(.large)

                Button("Save") {
                    onSave(school, degree, fieldOfStudy, grade.isEmpty ? nil : grade, startDate, endDate)
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
        // Memicu 'touched' status ketika user meninggalkan/pindah dari field tersebut
        .onChange(of: focusedField) { oldFocus, newFocus in
            if oldFocus == .school && newFocus != .school { schoolTouched = true }
            if oldFocus == .degree && newFocus != .degree { degreeTouched = true }
            if oldFocus == .fieldOfStudy && newFocus != .fieldOfStudy { fieldOfStudyTouched = true }
        }
        .animation(.easeInOut(duration: 0.2), value: schoolTouched)
        .animation(.easeInOut(duration: 0.2), value: degreeTouched)
        .animation(.easeInOut(duration: 0.2), value: fieldOfStudyTouched)
    }

    private func populateFieldsIfEditing() {
        guard let education else { return }
        school = education.school
        degree = education.degree
        fieldOfStudy = education.fieldOfStudy
        grade = education.grade ?? ""
        startDate = education.startDate
        endDate = education.endDate
    }
    
    // MARK: - Computed Properties untuk Logika Error Tampilan
    // Logika computed properties untuk memicu error merah
    private var shouldShowSchoolError: Bool {
        schoolTouched && school.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    private var shouldShowDegreeError: Bool {
        degreeTouched && degree.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    private var shouldShowFieldOfStudyError: Bool {
        fieldOfStudyTouched && fieldOfStudy.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
}
