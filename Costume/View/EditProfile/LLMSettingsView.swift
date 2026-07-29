//
//  LLMSettingsView.swift
//  Costume
//
//  Created by Saujana Shafi on 27/07/26.
//

import Foundation
import SwiftUI

enum ModelPreference: Int {
    case mlx = 1
    case openai = 2
    case `default` = 0
}

struct LLMSettingsView: View {
    @AppStorage("modelPreference") private var persistedModelPreference:
        ModelPreference = .default
    @AppStorage("externalAPIBaseURL") private var persistedBaseURL = ""
    @AppStorage("externalAPIKey") private var persistedApiKey = ""
    @AppStorage("externalAPIModel") private var persistedModel = ""

    @State private var draftBaseURL = ""
    @State private var draftApiKey = ""
    @State private var draftModel = ""

    private var isOpenAI: Bool {
        persistedModelPreference == .openai
    }

    private var isSaveEnabled: Bool {
        guard !draftModel.trimmingCharacters(in: .whitespaces).isEmpty else {
            return false
        }
        let trimmed = draftBaseURL.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty, let url = URL(string: trimmed) else {
            return false
        }
        return url.scheme != nil && url.host != nil
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                SectionHeaderView(title: "AI Model Settings")

                HStack {
                    Text("Model Preference")
                        .font(.body)
                    Spacer()
                    Picker(
                        selection: $persistedModelPreference,
                        label: Text("Model")
                    ) {
                        Text("Default").tag(ModelPreference.default)
                        Text("Local").tag(ModelPreference.mlx)
                        Text("API").tag(ModelPreference.openai)
                    }
                    .labelsHidden()
                    .pickerStyle(.segmented)
                }

                if isOpenAI {
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
                        HStack {
                            Spacer()
                            Button("Save") {
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
                    .transition(
                        .opacity.combined(
                            with: .move(edge: .top)
                        )
                    )
                }
            }
            .padding(32)
            .cardBackground()
            .animation(
                .easeInOut(duration: 0.25),
                value: isOpenAI
            )
        }
        .onAppear {
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
