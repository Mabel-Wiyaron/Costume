//
//  EditCVView.swift
//  Costume
//
//  Created by Matthew Regan Hadiwidjaja on 17/07/26.
//

import SwiftUI
import SwiftData

struct EditCVView: View {
    @State private var viewModel: EditCVViewModel
    var onBack: (() -> Void)? = nil

    init(document: CVDocument, jobDescription: JobDescription? = nil, modelContext: ModelContext? = nil, onBack: (() -> Void)? = nil) {
        _viewModel = State(initialValue: EditCVViewModel(document: document, jobDescription: jobDescription, modelContext: modelContext))
        self.onBack = onBack
    }

    var body: some View {
        HSplitView {
            EditorPanelView(viewModel: viewModel, onBack: onBack)
                .frame(minWidth: 460, idealWidth: 520)
            AnalysisPanelView(viewModel: viewModel)
                .frame(minWidth: 460, idealWidth: 640)
        }
        .frame(minHeight: 640)
    }
}

#Preview {
    let container = try! ModelContainer(
        for: Profile.self, JobDescription.self,
        configurations: ModelConfiguration(isStoredInMemoryOnly: true)
    )
    let sampleProfile = Profile(name: "", email: "", location: "", phone: "")
    let sampleJobDescription = JobDescription(content: "Paste job description here...", jobTitle: "iOS Engineer", company: "Acme Corp")
    EditCVView(
        document: CVDocument(profile: sampleProfile),
        jobDescription: sampleJobDescription,
        modelContext: container.mainContext
    )
}
