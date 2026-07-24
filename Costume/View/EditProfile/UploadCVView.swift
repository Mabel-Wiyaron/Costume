//
//  UploadCVView.swift
//  Costume
//
//  Created by William Constantine Jioe on 24/07/26.
//

import SwiftUI
import UniformTypeIdentifiers
import SwiftData

struct UploadCVView: View {
    @Bindable var viewModel: CVParsingViewModel
    
    let sandboxedProfile: Profile
    let masterProfile: Profile
    let mainContext: ModelContext
    
    @Environment(\.modelContext) private var childContext

    @State private var isTargeted = false
    @State private var isImporterPresented = false
    @State private var selectedFileName: String? = nil
    @State private var errorMessage: String? = nil

    private let CARD_PADDING: CGFloat = 32
    private let SECTION_SPACING: CGFloat = 24
    
    init(viewModel: CVParsingViewModel, sandboxedProfile: Profile, masterProfile: Profile, mainContext: ModelContext) {
        self._viewModel = Bindable(wrappedValue: viewModel)
        self.sandboxedProfile = sandboxedProfile
        self.masterProfile = masterProfile
        self.mainContext = mainContext
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: SECTION_SPACING) {
                
                VStack(alignment: .leading, spacing: 12) {
                    SectionHeaderView(title: "Existing Master Resumé")
                    
                    Text("Your profile will be automatically filled with your master resumé details. You can always edit and update your profile later.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }

                dropZoneView
                
                Text("*Drop a PDF file here (5MB or less)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                
                if let displayError = errorMessage ?? viewModel.errorMessage {
                    Text(displayError)
                        .font(.caption)
                        .foregroundStyle(.red)
                }
            }
            .padding(CARD_PADDING)
            .cardBackground()
        }
        .fileImporter(
            isPresented: $isImporterPresented,
            allowedContentTypes: [.pdf],
            allowsMultipleSelection: false
        ) { result in
            handleFileSelection(result: result)
        }
    }

    private var dropZoneView: some View {
        VStack(spacing: 16) {
            if viewModel.isProcessing {
                ProgressView("Processing Resumé...")
                    .controlSize(.large)
            } else {
                Image(systemName: "tray.and.arrow.down")
                    .symbolRenderingMode(.hierarchical)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 48, height: 48)
                    .foregroundStyle(.orange)

                if let selectedFileName {
                    Text("Selected: \(selectedFileName)")
                        .font(.system(size: 15, weight: .medium))
                        .foregroundStyle(.primary)
                } else {
                    Text("Drop your resume here")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundStyle(.primary)
                }

                Button(action: {
                    isImporterPresented = true
                }) {
                    Text("Browse Files")
                        .font(.system(size: 14, weight: .semibold))
                        .padding(.horizontal, 20)
                        .padding(.vertical, 8)
                        .background(Color.blue)
                        .foregroundStyle(.white)
                        .clipShape(Capsule())
                }
                .buttonStyle(.plain)
            }
        }
        .frame(maxWidth: .infinity)
        .frame(height: 220)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .strokeBorder(
                    isTargeted ? Color.gray : Color.gray.opacity(0.7),
                    style: StrokeStyle(lineWidth: isTargeted ? 3 : 2, dash: [8, 6])
                )
        )
        .onDrop(of: [.pdf], isTargeted: $isTargeted) { providers in
            handleDrop(providers: providers)
        }
    }

    private func handleFileSelection(result: Result<[URL], Error>) {
        switch result {
        case .success(let urls):
            guard let url = urls.first else { return }
            processSelectedPDF(at: url)
        case .failure(let error):
            if let parsingError = error as? CVParsingAgentError {
                switch parsingError {
                case .cvTextTooLong:
                    self.errorMessage = "Your CV is too long. Please upload a shorter resume."
                }
            } else {
                self.errorMessage = error.localizedDescription
            }
        }
    }

    private func handleDrop(providers: [NSItemProvider]) -> Bool {
        guard let provider = providers.first else { return false }
        
        provider.loadItem(forTypeIdentifier: UTType.pdf.identifier, options: nil) { item, error in
            guard error == nil else {
                DispatchQueue.main.async { self.errorMessage = error?.localizedDescription }
                return
            }
            
            var targetURL: URL? = nil
            
            if let url = item as? URL {
                targetURL = url
            } else if let data = item as? Data {
                let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString + ".pdf")
                try? data.write(to: tempURL)
                targetURL = tempURL
            }
            
            if let finalURL = targetURL {
                DispatchQueue.main.async {
                    processSelectedPDF(at: finalURL)
                }
            }
        }
        return true
    }

    private func processSelectedPDF(at url: URL) {
        let isScoped = url.startAccessingSecurityScopedResource()
        
        let destinationURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString + "_" + url.lastPathComponent)
        
        do {
            if FileManager.default.fileExists(atPath: destinationURL.path) {
                try FileManager.default.removeItem(at: destinationURL)
            }
            try FileManager.default.copyItem(at: url, to: destinationURL)
        } catch {}
        
        if isScoped {
            url.stopAccessingSecurityScopedResource()
        }
        
        let usableURL = FileManager.default.fileExists(atPath: destinationURL.path) ? destinationURL : url

        if let resources = try? usableURL.resourceValues(forKeys: [.fileSizeKey]),
           let fileSize = resources.fileSize, fileSize > 5 * 1024 * 1024 {
            self.errorMessage = "File size exceeds 5MB limit."
            return
        }
        
        self.errorMessage = nil
        self.selectedFileName = usableURL.lastPathComponent
        
        Task {
            await viewModel.processDroppedCV(
                fileURL: usableURL,
                sandboxedProfile: sandboxedProfile,
                masterProfile: masterProfile,
                childContext: childContext,
                mainContext: mainContext
            )
            
            try? FileManager.default.removeItem(at: usableURL)
        }
    }
}
