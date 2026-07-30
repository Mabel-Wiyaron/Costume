//
//  AnalysisPanelView.swift
//  Costume
//
//  Created by Matthew Regan Hadiwidjaja on 17/07/26.
//

import SwiftUI

struct AnalysisPanelView: View {
    @Bindable var viewModel: EditCVViewModel
    var onBack: (() -> Void)? = nil
    
    @State private var zoomScale: CGFloat = 0.8
    @GestureState private var gestureZoomScale: CGFloat = 1.0
    @State private var isDeleteConfirmationPresented: Bool = false

    private let TAB_PADDING: CGFloat = 24
    private let CONTENT_PADDING: CGFloat = 32

    private var formattedDocumentName: String {
        let profile = viewModel.document.profile
        if let jobDesc = profile.jobDescription,
           let role = jobDesc.role, !role.isEmpty,
           let company = jobDesc.company, !company.isEmpty {
            return "\(role) - \(company)"
        }
        return "Mabel_CV_Apple"
    }

    var body: some View {
        ZStack(alignment: .top) {
            Color("BackgroundColor")
                .ignoresSafeArea()

            VStack(alignment: .leading, spacing: 0) {
                HStack(spacing: 16) {
                    CustomSegmentedControl(selection: $viewModel.selectedRightTab)
                    
                    Spacer()
                }
                .padding(.horizontal, TAB_PADDING)
                .padding(.top, TAB_PADDING)
                .padding(.bottom, 24)

                Group {
                    switch viewModel.selectedRightTab {
                    case .jobDescriptionAnalysis:
                        ScrollView {
                            JobDescriptionAnalysisView(
                                jobDescription: viewModel.jobDescription,
                                onRefresh: { viewModel.updateKeywordStatus() }
                            )
                            .padding(.horizontal, CONTENT_PADDING)
                            .padding(.bottom, CONTENT_PADDING)
                        }
                    case .resumePreview:
                        ScrollView([.vertical, .horizontal], showsIndicators: true) {
                            resumePreview
                                .padding(CONTENT_PADDING)
                        }
                    }
                }
            }
        }
        .toolbar {
            ToolbarItemGroup(placement: .primaryAction) {
                if viewModel.selectedRightTab == .resumePreview {
                    // Control Zoom Group
                    HStack(spacing: 6) {
                        Button(action: {
                            zoomScale = max(0.4, zoomScale - 0.1)
                        }) {
                            Image(systemName: "minus.magnifyingglass")
                        }
                        .disabled(zoomScale <= 0.4)
                        .help("Zoom Out")

                        Text("\(Int(zoomScale * 100))%")
                            .font(.system(size: 11, weight: .medium, design: .monospaced))
                            .frame(width: 36)

                        Button(action: {
                            zoomScale = min(1.5, zoomScale + 0.1)
                        }) {
                            Image(systemName: "plus.magnifyingglass")
                        }
                        .disabled(zoomScale >= 1.5)
                        .help("Zoom In")

                        Button("Actual Size") {
                            zoomScale = 1.0
                        }
                        .disabled(zoomScale == 1.0)
                    }

                    Divider()

                    // Tombol Download / Export PDF
                    Button(action: {
                        DispatchQueue.main.async {
                            viewModel.save()
                            PDFExporter.export(profile: viewModel.document.profile, defaultFilename: formattedDocumentName)
                        }
                    }) {
                        Label("Export PDF", systemImage: "square.and.arrow.down")
                    }
                    .help("Save & Export PDF")
                }
            }

            ToolbarItem(placement: .primaryAction) {
                Button(role: .destructive, action: {
                    isDeleteConfirmationPresented = true
                }) {
                    Image(systemName: "trash")
                }
                .help("Delete CV")
            }
        }
        .alert("Delete this CV?", isPresented: $isDeleteConfirmationPresented) {
            Button("Cancel", role: .cancel) {}
            Button("Delete", role: .destructive) {
                viewModel.deleteDocument()
                onBack?()
            }
        } message: {
            Text("Are you sure you want to delete this CV? This action cannot be undone.")
        }
    }

    private var resumePreview: some View {
        let pages = ATSCVTemplateView.distribute(profile: viewModel.document.profile)
        let currentScale = zoomScale * gestureZoomScale
        
        return VStack(spacing: 20 * currentScale) {
            ForEach(pages) { page in
                ATSCVTemplateView(profile: viewModel.document.profile, pageContent: page)
                    .background(Color.white)
                    .shadow(color: Color.black.opacity(0.15), radius: 6, x: 0, y: 3)
                    // 1. Establish the base dimensions of an A4 page
                    .frame(width: 595, height: 842)
                    // 2. Scale smoothly from top-center
                    .scaleEffect(currentScale, anchor: .top)
                    // 3. Update the layout frame to match scaled visual dimensions aligned at top
                    .frame(width: 595 * currentScale, height: 842 * currentScale, alignment: .top)
            }
        }
        .frame(maxWidth: .infinity)
        .gesture(
            MagnificationGesture()
                .updating($gestureZoomScale) { value, state, _ in
                    state = value
                }
                .onEnded { value in
                    let nextScale = zoomScale * value
                    zoomScale = max(0.4, min(1.5, nextScale))
                }
        )
    }
}
