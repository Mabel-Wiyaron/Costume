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

    private let MODAL_PADDING: CGFloat = 32
    private let MODAL_WIDTH: CGFloat = 700
    private let COLUMN_SPACING: CGFloat = 32

    private var isSaveEnabled: Bool {
        !school.isEmpty && !degree.isEmpty && !fieldOfStudy.isEmpty
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            LabeledTextField(label: "School", isRequired: true, text: $school)
            LabeledTextField(label: "Degree", isRequired: true, text: $degree)
            LabeledTextField(label: "Field of Study", isRequired: true, text: $fieldOfStudy)

            HStack(alignment: .top, spacing: COLUMN_SPACING) {
                LabeledTextField(label: "Grade", text: $grade)
                LabeledDateRangeField(
                    label: "Years",
                    isRequired: true,
                    startDate: $startDate,
                    endDate: $endDate
                )
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
}
