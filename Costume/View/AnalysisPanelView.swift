//
//  AnalysisPanelView.swift
//  Costume
//
//  Created by Matthew Regan Hadiwidjaja on 17/07/26.
//

//
//  AnalysisPanelView.swift
//  Costume
//
//  Created by Matthew Regan Hadiwidjaja on 17/07/26.
//

import SwiftUI

struct AnalysisPanelView: View {
    @Bindable var viewModel: EditCVViewModel
    
    @State private var zoomScale: CGFloat = 0.8
    @GestureState private var gestureZoomScale: CGFloat = 1.0


    private let TAB_PADDING: CGFloat = 24
    private let CONTENT_PADDING: CGFloat = 32

    var body: some View {
        ZStack(alignment: .top) {
            Color("BackgroundColor")
                .ignoresSafeArea()

            VStack(alignment: .leading, spacing: 0) {
                HStack(spacing: 16) {
                    CustomSegmentedControl(selection: $viewModel.selectedRightTab)
                    
                    Spacer()
                    
                    if viewModel.selectedRightTab == .resumePreview {
                        HStack(spacing: 8) {
                            Text(" ")
                            Button(action: {
                                zoomScale = max(0.4, zoomScale - 0.1)
                            }) {
                                Image(systemName: "minus.magnifyingglass")
                                    .font(.system(size: 13, weight: .semibold))
                            }
                            .buttonStyle(.plain)
                            .disabled(zoomScale <= 0.4)
                            .help("Zoom Out")
                            
                            Text("\(Int(zoomScale * 100))%")
                                .font(.system(size: 11, weight: .medium, design: .monospaced))
                                .frame(width: 40)
                            
                            Button(action: {
                                zoomScale = min(1.5, zoomScale + 0.1)
                            }) {
                                Image(systemName: "plus.magnifyingglass")
                                    .font(.system(size: 13, weight: .semibold))
                            }
                            .buttonStyle(.plain)
                            .disabled(zoomScale >= 1.5)
                            .help("Zoom In")
                            
                            Button("100%") {
                                zoomScale = 1.0
                            }
                            .buttonStyle(.plain)
                            .font(.system(size: 11, weight: .medium))
                            .padding(.horizontal, 4)
                            .disabled(zoomScale == 1.0)
                        }
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.white.opacity(0.08))
                        .cornerRadius(6)
                    }
                    
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
                            JobDescriptionAnalysisView(jobDescription: viewModel.jobDescription, onRefresh: { viewModel.updateKeywordStatus() })
                        case .resumePreview:
                            resumePreview
                        }
                    }
                    .padding(.horizontal, CONTENT_PADDING)
                    .padding(.bottom, CONTENT_PADDING)
                }
            }
        }
    }

    private var resumePreview: some View {
        let pages = ATSCVTemplateView.distribute(profile: viewModel.document.profile)
        let currentScale = zoomScale * gestureZoomScale
        return VStack(spacing: 20) {
            ForEach(pages) { page in
                ATSCVTemplateView(profile: viewModel.document.profile, pageContent: page)
                    .background(Color.white)
                    .shadow(color: Color.black.opacity(0.15), radius: 6, x: 0, y: 3)
                    .frame(width: 595, height: 842)
                    .scaleEffect(currentScale)
                    .frame(width: 595 * currentScale, height: 842 * currentScale)
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
