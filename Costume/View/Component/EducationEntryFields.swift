//
//  EducationEntryFields.swift
//  Costume
//
//  Created by Matthew Regan Hadiwidjaja on 17/07/26.
//

import SwiftUI

struct EducationEntryFields: View {
    let education: Education

    private let COLUMN_SPACING: CGFloat = 32

    private enum Field: Hashable {
        case school, degree, fieldOfStudy
    }
    @FocusState private var focusedField: Field?

    @State private var schoolTouched = false
    @State private var degreeTouched = false
    @State private var fieldOfStudyTouched = false

    private var shouldShowSchoolError: Bool {
        schoolTouched && education.school.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    private var shouldShowDegreeError: Bool {
        degreeTouched && education.degree.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    private var shouldShowFieldOfStudyError: Bool {
        fieldOfStudyTouched && education.fieldOfStudy.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            LabeledTextField(
                label: "School",
                isRequired: true,
                text: schoolBinding,
                isError: shouldShowSchoolError,
                errorMessage: "School name is required"
            )
            .focused($focusedField, equals: .school)

            LabeledTextField(
                label: "Degree",
                isRequired: true,
                text: degreeBinding,
                isError: shouldShowDegreeError,
                errorMessage: "Degree is required"
            )
            .focused($focusedField, equals: .degree)

            LabeledTextField(
                label: "Field of Study",
                isRequired: true,
                text: fieldOfStudyBinding,
                isError: shouldShowFieldOfStudyError,
                errorMessage: "Field of study is required"
            )
            .focused($focusedField, equals: .fieldOfStudy)

            HStack(alignment: .top, spacing: COLUMN_SPACING) {
                LabeledTextField(label: "Grade", text: gradeBinding)
                LabeledDateRangeField(label: "Years", isRequired: true, startDate: startDateBinding, endDate: endDateBinding)
            }
        }
        .onChange(of: focusedField) { oldFocus, newFocus in
            if oldFocus == .school && newFocus != .school { schoolTouched = true }
            if oldFocus == .degree && newFocus != .degree { degreeTouched = true }
            if oldFocus == .fieldOfStudy && newFocus != .fieldOfStudy { fieldOfStudyTouched = true }
        }
        .animation(.default, value: schoolTouched)
        .animation(.default, value: degreeTouched)
        .animation(.default, value: fieldOfStudyTouched)
    }

    private var schoolBinding: Binding<String> {
        Binding(get: { education.school }, set: { education.school = $0 })
    }
    private var degreeBinding: Binding<String> {
        Binding(get: { education.degree }, set: { education.degree = $0 })
    }
    private var fieldOfStudyBinding: Binding<String> {
        Binding(get: { education.fieldOfStudy }, set: { education.fieldOfStudy = $0 })
    }
    private var gradeBinding: Binding<String> {
        Binding(get: { education.grade }, set: { education.grade = $0 }).stringValue
    }
    private var startDateBinding: Binding<Date> {
        Binding(get: { education.startDate }, set: { education.startDate = $0 })
    }
    private var endDateBinding: Binding<Date?> {
        Binding(get: { education.endDate }, set: { education.endDate = $0 })
    }
}
