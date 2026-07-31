//
//  LLMSettingsView.swift
//  Costume
//
//  Created by Saujana Shafi on 27/07/26.
//

import Foundation
import SwiftUI

struct LLMSettingsView: View {
    // MARK: - Persisted AppStorage States
    @AppStorage("useExternalAPI") private var persistedUseExternalAPI = false
    @AppStorage("externalAPIBaseURL") private var persistedBaseURL = ""
    @AppStorage("externalAPIKey") private var persistedApiKey = ""
    @AppStorage("externalAPIModel") private var persistedModel = ""

    // MARK: - Local Draft States (for edit tracking)
    @State private var draftUseExternalAPI = false
    @State private var draftBaseURL = ""
    @State private var draftApiKey = ""
    @State private var draftModel = ""

    // MARK: - Toast Notification State & Task
    @State private var showSaveConfirmation = false
    @State private var saveConfirmationTask: Task<Void, Never>?

    /// Returns true if any local draft property differs from its persisted value.
    private var hasChanges: Bool {
        draftUseExternalAPI != persistedUseExternalAPI ||
        draftBaseURL != persistedBaseURL ||
        draftApiKey != persistedApiKey ||
        draftModel != persistedModel
    }

    /// Validates the form fields when Custom API is enabled.
    private var isFormValid: Bool {
        if draftUseExternalAPI {
            guard !draftModel.trimmingCharacters(in: .whitespaces).isEmpty else { return false }
            let trimmed = draftBaseURL.trimmingCharacters(in: .whitespaces)
            guard !trimmed.isEmpty, let url = URL(string: trimmed) else { return false }
            return url.scheme != nil && url.host != nil
        }
        return true
    }

    /// Controls whether the Save button is enabled: requires unsaved changes AND a valid form.
    private var isSaveEnabled: Bool {
        hasChanges && isFormValid
    }

    var body: some View {
        ZStack(alignment: .top) {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    SectionHeaderView(title: "AI Model Settings")

                    HStack {
                        Text("Custom API")
                            .font(.body)
                        Spacer()
                        Toggle(isOn: Binding(
                            get: { draftUseExternalAPI },
                            set: { newValue in
                                withAnimation(.easeInOut(duration: 0.25)) {
                                    draftUseExternalAPI = newValue
                                }
                            }
                        )) {}
                            .toggleStyle(.switch)
                            .onChange(of: draftUseExternalAPI) { _, newValue in
                                if !newValue {
                                    // Automatically save that custom API is disabled when toggle is turned off
                                    persistedUseExternalAPI = false
                                } else if isFormValid {
                                    // Automatically save if fields are already filled and valid when toggle is turned on
                                    persistedUseExternalAPI = true
                                    persistedBaseURL = draftBaseURL
                                    persistedApiKey = draftApiKey
                                    persistedModel = draftModel
                                }
                            }
                    }

                    if draftUseExternalAPI {
                        VStack(spacing: 16) {
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

                            HStack {
                                Spacer()
                                Button("Save") {
                                    // Persist draft settings into AppStorage
                                    persistedUseExternalAPI = draftUseExternalAPI
                                    persistedBaseURL = draftBaseURL
                                    persistedApiKey = draftApiKey
                                    persistedModel = draftModel
                                    triggerSaveToast()
                                }
                                .buttonStyle(.borderedProminent)
                                .tint(Color("AppPrimaryColor"))
                                .controlSize(.large)
                                .keyboardShortcut(.defaultAction)
                                .disabled(!isSaveEnabled) // Disabled by default until changes exist
                            }
                        }
                        .transition(.opacity.combined(with: .scale(scale: 0.98, anchor: .top)))
                    }
                }
                .padding(32)
                .cardBackground()
                .animation(
                    .easeInOut(duration: 0.25),
                    value: draftUseExternalAPI
                )
            }

            // Top-floating Save Confirmation Toast Notification
            if showSaveConfirmation {
                SaveConfirmationToast()
                    .padding(.top, 16)
                    .padding(.horizontal, 32)
                    .transition(.move(edge: .top).combined(with: .opacity))
                    .zIndex(1)
                    .allowsHitTesting(false)
            }
        }
        .animation(.easeInOut(duration: 0.25), value: showSaveConfirmation)
        .onAppear {
            // Load initial persisted values into local drafts
            draftUseExternalAPI = persistedUseExternalAPI
            draftBaseURL = persistedBaseURL
            draftApiKey = persistedApiKey
            draftModel = persistedModel
        }
    }

    private func triggerSaveToast() {
        saveConfirmationTask?.cancel()
        showSaveConfirmation = true
        saveConfirmationTask = Task { @MainActor in
            try? await Task.sleep(nanoseconds: 2_500_000_000)
            guard !Task.isCancelled else { return }
            showSaveConfirmation = false
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
