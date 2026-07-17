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

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            LabeledTextField(label: "Job Title", isRequired: true, text: roleBinding)
            LabeledPicker(
                label: "Employment Type",
                isRequired: true,
                selection: employmentTypeBinding,
                optionTitle: { $0.title }
            )
            LabeledTextField(label: "Company", isRequired: true, text: companyBinding)

            HStack(alignment: .top, spacing: COLUMN_SPACING) {
                LabeledTextField(label: "Location", isRequired: true, placeholder: "City, Country", text: locationBinding)
                LabeledDateRangeField(label: "Years", isRequired: true, startDate: startDateBinding, endDate: endDateBinding)
            }

            LabeledTextEditor(label: "Description", text: descriptionBinding)
        }
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
