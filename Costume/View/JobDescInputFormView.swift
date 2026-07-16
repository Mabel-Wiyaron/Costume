//
//   JobDescInputFormView.swift
//   Costume
//
//   Created by William Constantine Jioe on 15/07/26.
//

import SwiftUI

struct JobDescInputFormView: View {
    // MARK: - View Model
    let jobDescExtVM: JobDescriptionExtractionViewModel

    @State private var jobDescription: String = ""
    @State private var isLoading: Bool = false
    @FocusState private var isFocused: Bool
    
    // MARK: - Constants
    private let MAX_CHARACTER_LIMIT: Int = 4000
    private let TEXT_EDITOR_PADDING: CGFloat = 12
    private let TEXT_EDITOR_CORNER_RADIUS: CGFloat = 8
    private let BORDER_WIDTH_UNFOCUSED: CGFloat = 1
    private let BORDER_WIDTH_FOCUSED: CGFloat = 2
    private let CARD_INNER_PADDING: CGFloat = 24
    private let BUTTON_HEIGHT: CGFloat = 48
    private let BUTTON_CORNER_RADIUS: CGFloat = 8
    private let HEADER_TOP_PADDING: CGFloat = 20
    private let HEADER_HORIZONTAL_PADDING: CGFloat = 20
    private let BACK_BUTTON_SIZE: CGFloat = 40
    
    // Responsive Bounds
    private let MAX_CARD_WIDTH: CGFloat = 800
    private let MIN_HORIZONTAL_MARGIN: CGFloat = 24

    init() {
        self.jobDescExtVM = .init()
        self.isFocused = true
    }

    func onSubmit() {
        Task {
            do {
                isLoading = true
                let result = try await jobDescExtVM.extract(
                    from: jobDescription
                )

                print(result)
            } catch {
                print("error")
            }

            isLoading = false
        }
    }

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Color.background
                
                VStack(spacing: 0) {
                    // Top header navigation row (Fixed at top)
                    HStack {
//                        Button(action: {
//                            // Action for handling back navigation
//                        })
//                        {
//                            Image(systemName: "chevron.left")
//                                .font(.system(size: 16, weight: .semibold))
//                                .foregroundStyle(.text)
//                                .frame(width: BACK_BUTTON_SIZE, height: BACK_BUTTON_SIZE)
//                                .background(.card)
//                                .clipShape(Circle())
//                                .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
//                        }
//                        .buttonStyle(.plain)
                        
                        Spacer()
                    }
                    .padding(.horizontal, HEADER_HORIZONTAL_PADDING)
                    .padding(.top, HEADER_TOP_PADDING)
                    
                    // Pushes the card to the mathematical center
                    Spacer()
                    
                    // Central Card View wrapping the UI components
                    VStack(alignment: .leading, spacing: 20) {
                        // Title Header Block
                        HStack(spacing: 4) {
                            Text("Paste Job Description Below")
                                .font(.title)
                                .fontWeight(.bold)
                                .foregroundStyle(.text)
                        }
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.top, 8)
                        
                        // Controlled Editor Area with strict limits and custom state border colors
                        VStack(alignment: .trailing, spacing: 6) {
                            ZStack(alignment: .topLeading) {
                                // Raw field processing editor input bound with focus monitors
                                TextEditor(text: $jobDescription)
                                    .focused($isFocused)
                                    .font(.body)
                                    
                                    // --- THE HEIGHT MAGIC HAPPENS HERE ---
                                    // Rather than a fixed 400, it safely uses a fraction of the screen's real estate.
                                    .frame(height: calculateAdaptiveHeight(screenHeight: geometry.size.height))
                                    
                                    .textEditorStyle(.plain)
                                    .padding(TEXT_EDITOR_PADDING)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: TEXT_EDITOR_CORNER_RADIUS)
                                            .stroke(
                                                isFocused ? Color.accentColor : Color.black.opacity(0.2),
                                                lineWidth: isFocused ? BORDER_WIDTH_FOCUSED : BORDER_WIDTH_UNFOCUSED
                                            )
                                    )
                                    .onChange(of: jobDescription) { oldValue, newValue in
                                        if newValue.count > MAX_CHARACTER_LIMIT {
                                            jobDescription = String(newValue.prefix(MAX_CHARACTER_LIMIT))
                                        }
                                    }
                                
                                // Native text overlay acting as secondary hint layer
                                if jobDescription.isEmpty {
                                    Text("Paste the Job Description here...")
                                        .font(.body)
                                        .foregroundStyle(.gray.opacity(0.7))
                                        .padding(.horizontal, 16)
                                        .padding(.top, 12)
                                        .allowsHitTesting(false)
                                }
                            }
                            
                            // Real-Time Character Counter Tracking Component
                            Text("\(jobDescription.count) / \(MAX_CHARACTER_LIMIT)")
                                .font(.caption)
                                .fontWeight(.medium)
                                .foregroundStyle(jobDescription.count >= MAX_CHARACTER_LIMIT ? .red : .secondary)
                                .animation(.default, value: jobDescription.count)
                        }
                        
                        // Main action button wrapper layout setup
                        Button(action: {
                            // Action to trigger backend layout analysis
                            onSubmit()
                        }) {
                            Text("Start Analyzing")
                                .font(.body)
                                .fontWeight(.semibold)
                                .foregroundStyle(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: BUTTON_HEIGHT)
                                .background(jobDescription.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? Color("PrimaryColor").opacity(0.5) : Color("PrimaryColor"))
                                .clipShape(RoundedRectangle(cornerRadius: BUTTON_CORNER_RADIUS))
                        }
                        .disabled(
                            isLoading
                                || jobDescription.trimmingCharacters(
                                    in: .whitespacesAndNewlines
                                ).isEmpty
                        )
                        .buttonStyle(.plain)
                    }
                    .padding(CARD_INNER_PADDING)
                    .cardBackground() // Utilizes your precise Custom Card Background ViewModifier
                    
                    // Explicit framing to guarantee beautiful centering
                    .padding(.horizontal, MIN_HORIZONTAL_MARGIN)
                    .frame(maxWidth: MAX_CARD_WIDTH + (MIN_HORIZONTAL_MARGIN * 2))
                    .frame(maxWidth: .infinity, alignment: .center)
                    
                    // Balances the top spacer, holding it dead center
                    Spacer()
                }
            }
        }
    }
    
    // MARK: - Helper Layout Logic
    /// Dynamically scales the TextEditor height so it shrinks on iPhones but expands safely on iPads.
    private func calculateAdaptiveHeight(screenHeight: CGFloat) -> CGFloat {
        // We set 400 as our ideal ceiling target height
        let idealHeight: CGFloat = 400
        
        // On a typical small device layout, we want the field to take up roughly 35% of total screen height
        let responsiveConstraintHeight = screenHeight * 0.35
        
        // It picks whichever is smaller: 400 or 35% of the total screen.
        // This ensures the card NEVER overflows the margins on tiny devices.
        return min(idealHeight, responsiveConstraintHeight)
    }
}

#Preview {
    JobDescInputFormView()
}
