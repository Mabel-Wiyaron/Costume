//
//  LLMSettingsView.swift
//  Costume
//
//  Created by Saujana Shafi on 27/07/26.
//

import Foundation
import SwiftUI

struct LLMSettingsView: View {
    @AppStorage("useExternalAPI") private var persistedUseExternalAPI = false
    @AppStorage("externalAPIBaseURL") private var persistedBaseURL = ""
    @AppStorage("externalAPIKey") private var persistedApiKey = ""
    @AppStorage("externalAPIModel") private var persistedModel = ""

    @State private var draftUseExternalAPI = false
    @State private var draftBaseURL = ""
    @State private var draftApiKey = ""
    @State private var draftModel = ""

    private var isSaveEnabled: Bool {
        guard !draftModel.trimmingCharacters(in: .whitespaces).isEmpty else { return false }
        let trimmed = draftBaseURL.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty, let url = URL(string: trimmed) else { return false }
        return url.scheme != nil && url.host != nil
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                SectionHeaderView(title: "AI Model Settings")

                HStack {
                    Text("Custom API")
                        .font(.body)
                    Spacer()
                    Toggle(isOn: $draftUseExternalAPI) {}
                        .toggleStyle(.switch)
                }

                if draftUseExternalAPI {
                    VStack(spacing: 12) {
                        LabeledTextField(
                            label: "Base URL",
                            placeholder: "https://api.openai.com",
                            text: $draftBaseURL
                        )
                        labeledSecureField(
                            label: "API Key",
                            text: $draftApiKey,
                            placeholder: "sk-..."
                        )
                        LabeledTextField(
                            label: "Model",
                            placeholder: "gpt-4o",
                            text: $draftModel
                        )
                    }
                    .transition(
                        .opacity.combined(
                            with: .move(edge: .top)
                        )
                    )
                }

                HStack {
                    Spacer()
                    Button("Save") {
                        persistedUseExternalAPI = draftUseExternalAPI
                        persistedBaseURL = draftBaseURL
                        persistedApiKey = draftApiKey
                        persistedModel = draftModel
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(Color("PrimaryColor"))
                    .controlSize(.large)
                    .disabled(!isSaveEnabled)
                }
            }
            .padding(32)
            .cardBackground()
            .animation(
                .easeInOut(duration: 0.25),
                value: draftUseExternalAPI
            )
        }
        .onAppear {
            draftUseExternalAPI = persistedUseExternalAPI
            draftBaseURL = persistedBaseURL
            draftApiKey = persistedApiKey
            draftModel = persistedModel
        }
    }

    private func labeledSecureField(
        label: String,
        text: Binding<String>,
        placeholder: String
    ) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(label)
                .font(.title3)
                .fontWeight(.semibold)
            SecureField(placeholder, text: text)
                .textFieldStyle(.plain)
                .padding(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.black, lineWidth: 1)
                )
        }
    }
}

#Preview {
    LLMSettingsView()
}
