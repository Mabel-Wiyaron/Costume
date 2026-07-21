import SwiftUI
import SwiftData

struct JobDescInputFormView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var profiles: [Profile]
    @Environment(\.dismiss) private var dismiss

    @State private var jobDescExtVM = JobDescriptionExtractionViewModel()
    @State private var jobDescription: String = ""
    @FocusState private var isFocused: Bool

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
    private let MAX_CARD_WIDTH: CGFloat = 800
    private let MIN_HORIZONTAL_MARGIN: CGFloat = 24

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Color.background
                    .ignoresSafeArea()
                
                // Form Utama (Selalu terpasang di hirarki View)
                VStack(spacing: 0) {
                    HStack {
                        Spacer()
                    }
                    .padding(.horizontal, HEADER_HORIZONTAL_PADDING)
                    .padding(.top, HEADER_TOP_PADDING)
                    
                    Spacer()
                    
                    VStack(alignment: .leading, spacing: 20) {
                        HStack(spacing: 4) {
                            Text("Paste Job Description Below")
                                .font(.title)
                                .fontWeight(.bold)
                                .foregroundStyle(.text)
                        }
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.top, 8)
                        
                        VStack(alignment: .trailing, spacing: 6) {
                            ZStack(alignment: .topLeading) {
                                TextEditor(text: $jobDescription)
                                    .focused($isFocused)
                                    .font(.body)
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
                                
                                if jobDescription.isEmpty {
                                    Text("Paste the Job Description here...")
                                        .font(.body)
                                        .foregroundStyle(.gray.opacity(0.7))
                                        .padding(.horizontal, 16)
                                        .padding(.top, 12)
                                        .allowsHitTesting(false)
                                }
                            }
                            
                            Text("\(jobDescription.count) / \(MAX_CHARACTER_LIMIT)")
                                .font(.caption)
                                .fontWeight(.medium)
                                .foregroundStyle(jobDescription.count >= MAX_CHARACTER_LIMIT ? .red : .secondary)
                        }
                        
                        Button(action: {
                            isFocused = false // Dismiss keyboard
                            jobDescExtVM.onSubmit(jobDescription: jobDescription)
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
                        .disabled(jobDescExtVM.isSubmitDisabled(for: jobDescription))
                        .buttonStyle(.plain)
                    }
                    .padding(CARD_INNER_PADDING)
                    .cardBackground()
                    .padding(.horizontal, MIN_HORIZONTAL_MARGIN)
                    .frame(maxWidth: MAX_CARD_WIDTH + (MIN_HORIZONTAL_MARGIN * 2))
                    .frame(maxWidth: .infinity, alignment: .center)
                    
                    Spacer()
                }
                
                // 🛑 OVERLAY LOADING: Mengambang di atas form tanpa merusak Hirarki Navigation
                if jobDescExtVM.isLoading {
                    LoadingGenerateView()
                        .ignoresSafeArea()
                        .transition(.opacity)
                }
            }
            .animation(.easeInOut(duration: 0.3), value: jobDescExtVM.isLoading)
            .onAppear {
                jobDescExtVM.modelContext = modelContext
            }
            // 🚀 NAVIGATION DESTINATION
            .navigationDestination(isPresented: $jobDescExtVM.isFinished) {
                if let profile = jobDescExtVM.createdProfile {
                    CVPreviewView(
                        profile: profile,
                        documentName: "\(profile.name)_CV_\(profile.jobDescription?.company ?? "Tailored")"
                    )
                }
            }
        }
    }

    private func calculateAdaptiveHeight(screenHeight: CGFloat) -> CGFloat {
        let idealHeight: CGFloat = 400
        let responsiveConstraintHeight = screenHeight * 0.35
        return min(idealHeight, responsiveConstraintHeight)
    }
}
