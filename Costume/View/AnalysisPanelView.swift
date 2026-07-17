//
//  AnalysisPanelView.swift
//  Costume
//
//  Created by Matthew Regan Hadiwidjaja on 17/07/26.
//

import SwiftUI

struct AnalysisPanelView: View {
    @Bindable var viewModel: EditCVViewModel

    private let TAB_PADDING: CGFloat = 24
    private let CONTENT_PADDING: CGFloat = 32

    var body: some View {
        ZStack(alignment: .top) {
            Color("BackgroundColor")
                .ignoresSafeArea()

            VStack(alignment: .leading, spacing: 0) {
                HStack(spacing: 16) {
                    CustomSegmentedControl(selection: $viewModel.selectedRightTab)
                    
                    // Fixed-width container ensures the layout does not jump when switching tabs
                    ZStack(alignment: .trailing) {
                        if viewModel.selectedRightTab == .resumePreview {
                            Button(action: {
                                viewModel.save()
                            }) {
                                Image(systemName: "square.and.arrow.down")
                                    .font(.system(size: 14, weight: .bold))
                                    .foregroundStyle(Color.text)
                                    .frame(width: 36, height: 36)
                                    .background(.thinMaterial)
                                    .clipShape(Circle())
                                    .overlay(
                                        Circle()
                                            .stroke(Color.white.opacity(0.5), lineWidth: 0.5)
                                    )
                                    .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
                            }
                            .buttonStyle(.plain)
                            .help("Save CV")
                        }
                    }
                    .frame(width: 36)
                }
                .padding(.horizontal, TAB_PADDING)
                .padding(.top, TAB_PADDING)
                .padding(.bottom, 24)

                ScrollView {
                    Group {
                        switch viewModel.selectedRightTab {
                        case .jobDescriptionAnalysis:
                            JobDescriptionAnalysisView(jobDescription: viewModel.jobDescription)
                        case .resumePreview:
                            resumePreviewPlaceholder
                        }
                    }
                    .padding(.horizontal, CONTENT_PADDING)
                    .padding(.bottom, CONTENT_PADDING)
                }
            }
        }
    }

    private var resumePreviewPlaceholder: some View {
        VStack(spacing: 12) {
            Image(systemName: "doc.richtext")
                .font(.system(size: 40))
                .foregroundStyle(.secondary)
            Text("Resumé Preview coming soon")
                .font(.headline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, minHeight: 300)
    }
}
