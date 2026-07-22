//
//  JobDescriptionAnalysisView.swift
//  Costume
//
//  Created by Matthew Regan Hadiwidjaja on 17/07/26.
//

import SwiftUI

struct JobDescriptionAnalysisView: View {
    let jobDescription: JobDescription?
    let onRefresh: (() -> Void)?

    @State private var showKeywordPopover = false
    @State private var showOriginalPopover = false

    private let SECTION_SPACING: CGFloat = 24
    private let TAG_SPACING: CGFloat = 8
    private let CARD_PADDING: CGFloat = 32

    init(jobDescription: JobDescription?, onRefresh: (() -> Void)? = nil) {
        self.jobDescription = jobDescription
        self.onRefresh = onRefresh
    }

    var body: some View {
        VStack(alignment: .leading, spacing: SECTION_SPACING) {
            if let jobDescription {
                header(for: jobDescription)
                keywordAnalysisSection(for: jobDescription)
                
                Rectangle()
                    .fill(Color.orange)
                    .frame(height: 1)
                
                originalDescriptionSection(for: jobDescription)
            } else {
                emptyState
            }
        }
        .padding(CARD_PADDING)
        .cardBackground()
        .onAppear { onRefresh?() }
    }
    
    private func header(for jobDescription: JobDescription) -> some View {
        let role = jobDescription.role ?? ""
        let company = jobDescription.company ?? ""

        return VStack(alignment: .leading, spacing: 10) {
            Text(role)
                .font(.largeTitle)
                .fontWeight(.bold)
            
            Text(company.isEmpty ? "Company" : company)
                .font(.title3)
                .foregroundStyle(Color.orange)
                
            Rectangle()
                .fill(Color.orange)
                .frame(height: 1)
        }
    }

    private func keywordAnalysisSection(for jobDescription: JobDescription) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 6) {
                Text("AI Keyword Analysis")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Button(action: { showKeywordPopover.toggle() }) {
                    Image(systemName: "questionmark.circle")
                        .foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
                .popover(isPresented: $showKeywordPopover, arrowEdge: .top) {
                    Text("These keywords were extracted from the job description by AI. Include them in your CV when they reflect your experience.")
                        .font(.callout)
                        .padding()
                        .frame(width: 300)
                }
            }

            HStack(spacing: 20) {
                legendItem(status: .included)
                legendItem(status: .match)
                legendItem(status: .missing)
            }

            if jobDescription.keywords.isEmpty {
                Text("No keywords extracted yet.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            } else {
                FlowLayout(spacing: TAG_SPACING) {
                    ForEach(jobDescription.keywords) { keyword in
                        KeywordTag(text: keyword.name, status: keyword.status)
                    }
                }
            }
        }
    }

    private func legendItem(status: KeywordStatus) -> some View {
        HStack(spacing: 6) {
            Circle()
                .fill(status.foregroundColor)
                .frame(width: 10, height: 10)
            Text(status.legendLabel)
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
    }

    private func originalDescriptionSection(for jobDescription: JobDescription) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 6) {
                Text("Original Job Description")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Button(action: { showOriginalPopover.toggle() }) {
                    Image(systemName: "questionmark.circle")
                        .foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
                .popover(isPresented: $showOriginalPopover, arrowEdge: .top) {
                    Text("This is the original job description you pasted earlier. It hasn't been modified by AI and is provided as your reference while tailoring your CV.")
                        .font(.callout)
                        .padding()
                        .frame(width: 300)
                }
            }
            Text(jobDescription.content)
                .font(.body)
                .foregroundStyle(.primary)
        }
    }

    private var emptyState: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("No Job Description Linked")
                .font(.title2)
                .fontWeight(.bold)
            Text("Paste a job description for this CV to see the AI keyword analysis here.")
                .font(.body)
                .foregroundStyle(.secondary)
        }
    }
}
