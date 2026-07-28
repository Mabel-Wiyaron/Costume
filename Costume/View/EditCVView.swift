import SwiftUI
import SwiftData

struct EditCVView: View {
    @State private var viewModel: EditCVViewModel?
    private let initialDocument: CVDocument
    private let initialJobDescription: JobDescription?
    private let mainContext: ModelContext?
    var onBack: (() -> Void)? = nil

    init(document: CVDocument, jobDescription: JobDescription? = nil, modelContext: ModelContext? = nil, onBack: (() -> Void)? = nil) {
        self.initialDocument = document
        self.initialJobDescription = jobDescription
        self.mainContext = modelContext
        self.onBack = onBack
    }

    var body: some View {
        Group {
            if let viewModel {
                HSplitView {
                    EditorPanelView(viewModel: viewModel, onBack: onBack)
                        .frame(minWidth: 460, idealWidth: 520)
                    AnalysisPanelView(viewModel: viewModel)
                        .frame(minWidth: 460, idealWidth: 640)
                }
            } else {
                ProgressView()
            }
        }
        .frame(minHeight: 640)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigation) {
                Button(action: attemptBack) {
                    Image(systemName: "chevron.left")
                }
            }
        }
        .onAppear(perform: setupViewModelIfNeeded)
    }

    private func attemptBack() {
        guard let viewModel, viewModel.hasUnsavedChanges else {
            onBack?()
            return
        }
        switch UnsavedChangesAlert.present() {
        case .save:
            viewModel.save()
            onBack?()
        case .discardChanges:
            onBack?()
        case .cancel:
            break
        }
    }

    private func setupViewModelIfNeeded() {
        guard viewModel == nil else { return }

        guard let mainContext else {
            viewModel = EditCVViewModel(document: initialDocument, jobDescription: initialJobDescription, modelContext: nil)
            return
        }

        let childContext = ModelContext(mainContext.container)
        childContext.autosaveEnabled = false

        let profileID = initialDocument.profile.persistentModelID
        guard let sandboxedProfile = childContext.model(for: profileID) as? Profile else {
            viewModel = EditCVViewModel(document: initialDocument, jobDescription: initialJobDescription, modelContext: mainContext)
            return
        }

        var sandboxedJobDescription: JobDescription? = nil
        if let jobDescriptionID = initialJobDescription?.persistentModelID {
            sandboxedJobDescription = childContext.model(for: jobDescriptionID) as? JobDescription
        }

        viewModel = EditCVViewModel(
            document: CVDocument(profile: sandboxedProfile),
            jobDescription: sandboxedJobDescription,
            modelContext: childContext
        )
    }
}

#Preview {
    let container = try! ModelContainer(
        for: Profile.self, JobDescription.self,
        configurations: ModelConfiguration(isStoredInMemoryOnly: true)
    )
    let sampleProfile = Profile(name: "", email: "", location: "", phone: "")
    let sampleJobDescription = JobDescription(content: "Paste job description here...", role: "iOS Engineer", company: "Acme Corp")
    EditCVView(
        document: CVDocument(profile: sampleProfile),
        jobDescription: sampleJobDescription,
        modelContext: container.mainContext
    )
}
