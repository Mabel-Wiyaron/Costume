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

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            LabeledTextField(label: "School", isRequired: true, text: schoolBinding)
            LabeledTextField(label: "Degree", isRequired: true, text: degreeBinding)
            LabeledTextField(label: "Field of Study", isRequired: true, text: fieldOfStudyBinding)

            HStack(alignment: .top, spacing: COLUMN_SPACING) {
                LabeledTextField(label: "Grade", text: gradeBinding)
                LabeledDateRangeField(label: "Years", isRequired: true, startDate: startDateBinding, endDate: endDateBinding)
            }
        }
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
