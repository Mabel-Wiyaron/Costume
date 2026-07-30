//
//  EditorPanelView.swift
//  Costume
//
//  Created by Matthew Regan Hadiwidjaja on 17/07/26.
//

import SwiftUI

struct EditorPanelView: View {
    @Bindable var viewModel: EditCVViewModel
    var onBack: (() -> Void)? = nil

    private let HEADER_HORIZONTAL_PADDING: CGFloat = 24
    private let HEADER_TOP_PADDING: CGFloat = 24
    private let CONTENT_PADDING: CGFloat = 24
    private let SECTION_SPACING: CGFloat = 24
    private let BACK_BUTTON_SIZE: CGFloat = 32
    private let COLUMN_SPACING: CGFloat = 32
    private let CARD_PADDING: CGFloat = 32
    private let SAVE_BAR_VERTICAL_PADDING: CGFloat = 16

    var body: some View {
        ZStack(alignment: .top) {
            Color("AppPrimaryColor")
                .ignoresSafeArea()

            VStack(alignment: .leading, spacing: 0) {
                
                Text("Editor Panel")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundStyle(Color.white)
                    .padding(.horizontal, HEADER_HORIZONTAL_PADDING)
                    .padding(.top, 12)
                    .padding(.bottom, 20)
                
                ScrollView {
                    VStack(alignment: .leading, spacing: SECTION_SPACING) {
                        personalInfoCard
                        summaryCard
                        
                        InlineEntryListCard(
                            title: "Experience",
                            addButtonLabel: "+ Add Experience",
                            entryTitle: { "Experience #\($0 + 1)" },
                            items: viewModel.document.experiences,
                            onAdd: viewModel.addExperience,
                            onDelete: viewModel.deleteExperience
                        ) { experience in
                            ExperienceEntryFields(experience: experience)
                        }
                        
                        InlineEntryListCard(
                            title: "Education",
                            addButtonLabel: "+ Add Education",
                            entryTitle: { "Education #\($0 + 1)" },
                            items: viewModel.document.educations,
                            onAdd: viewModel.addEducation,
                            onDelete: viewModel.deleteEducation
                        ) { education in
                            EducationEntryFields(education: education)
                        }
                        
                        InlineEntryListCard(
                            title: "Project",
                            addButtonLabel: "+ Add Project",
                            entryTitle: { "Project #\($0 + 1)" },
                            items: viewModel.document.projects,
                            onAdd: viewModel.addProject,
                            onDelete: viewModel.deleteProject
                        ) { project in
                            ProjectEntryFields(project: project)
                        }
                        
                        skillsCard
                        
                        InlineEntryListCard(
                            title: "Certifications",
                            addButtonLabel: "+ Add Certification",
                            entryTitle: { "Certification #\($0 + 1)" },
                            items: viewModel.document.certifications,
                            onAdd: viewModel.addCertification,
                            onDelete: viewModel.deleteCertification
                        ) { certification in
                            CertificationEntryFields(
                                certification: certification
                            )
                        }
                        
                        InlineEntryListCard(
                            title: "Awards",
                            addButtonLabel: "+ Add Award",
                            entryTitle: { "Award #\($0 + 1)" },
                            items: viewModel.document.awards,
                            onAdd: viewModel.addAward,
                            onDelete: viewModel.deleteAward
                        ) { award in
                            AwardEntryFields(award: award)
                        }
                    }
                    .padding(CONTENT_PADDING)
                }
                saveBar
            }
            if viewModel.showSaveConfirmation {
                SaveConfirmationToast()
                    .padding(.horizontal, HEADER_HORIZONTAL_PADDING)
                    .padding(.top, HEADER_TOP_PADDING)
                    .transition(.move(edge: .top).combined(with: .opacity))
                    .zIndex(1)
                    .allowsHitTesting(false)
            }
        }
        .animation(
            .easeInOut(duration: 0.25),
            value: viewModel.showSaveConfirmation
        )
    }

    private enum PersonalInfoField: Hashable {
        case name, phone, email
    }
    @FocusState private var focusedPersonalInfoField: PersonalInfoField?

    @State private var nameTouched = false
    @State private var phoneTouched = false
    @State private var emailTouched = false

    private var shouldShowNameError: Bool {
        nameTouched && !viewModel.isNameValid
    }

    private var shouldShowPhoneError: Bool {
        phoneTouched && !viewModel.isPhoneValid
    }

    private var shouldShowEmailError: Bool {
        emailTouched && !viewModel.isEmailValid
    }

    private var personalInfoCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            SectionHeaderView(title: "Personal Information")

            LabeledTextField(
                label: "Name",
                isRequired: true,
                text: $viewModel.document.name,
                isError: shouldShowNameError,
                errorMessage: "Name is required"
            )
            .focused($focusedPersonalInfoField, equals: .name)

            HStack(alignment: .top, spacing: COLUMN_SPACING) {
                LabeledTextField(
                    label: "Contact",
                    isRequired: true,
                    placeholder: "+62 1234567890",
                    text: $viewModel.document.phone,
                    isError: shouldShowPhoneError,
                    errorMessage: viewModel.document.phone.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? "Contact number is required" : "Invalid phone format (e.g., +6281234567)"
                )
                .focused($focusedPersonalInfoField, equals: .phone)
                LabeledTextField(
                    label: "LinkedIn",
                    text: $viewModel.document.linkedin.stringValue
                )
            }

            HStack(alignment: .top, spacing: COLUMN_SPACING) {
                LabeledTextField(
                    label: "Email",
                    isRequired: true,
                    text: $viewModel.document.email,
                    isError: shouldShowEmailError,
                    errorMessage: viewModel.document.email.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? "Email is required" : "Invalid email format (e.g., name@example.com)"
                )
                .focused($focusedPersonalInfoField, equals: .email)
                LabeledTextField(
                    label: "Personal Website",
                    text: $viewModel.document.website.stringValue
                )
            }

            HStack(alignment: .top, spacing: COLUMN_SPACING) {
                LabeledTextField(
                    label: "Location",
                    text: $viewModel.document.location
                )
                LabeledTextField(
                    label: "Github",
                    text: $viewModel.document.links
                        .urlString(forPlatform: .github)
                )
            }
        }
        .padding(CARD_PADDING)
        .cardBackground()
        .onChange(of: focusedPersonalInfoField) { oldFocus, newFocus in
            if oldFocus == .name && newFocus != .name { nameTouched = true }
            if oldFocus == .phone && newFocus != .phone { phoneTouched = true }
            if oldFocus == .email && newFocus != .email { emailTouched = true }
        }
        .animation(.default, value: nameTouched)
        .animation(.default, value: phoneTouched)
        .animation(.default, value: emailTouched)
    }

    private var summaryCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            SectionHeaderView(title: "Summary")
            LabeledTextEditor(
                label: "About Me",
                text: $viewModel.document.summary.stringValue
            )
        }
        .padding(CARD_PADDING)
        .cardBackground()
    }

    private var skillsCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            SectionHeaderView(title: "Skills")

            SkillTagField(
                label: "Add skills",
                helperText: "Press enter for each new skill",
                skills: $viewModel.document.skills
            )
        }
        .padding(CARD_PADDING)
        .cardBackground()
    }
    
    private var saveBar: some View {
        HStack {
            if viewModel.hasInvalidData {
                Text("*There are unfilled required sections. Please complete them to continue saving.")
                    .foregroundColor(.red)
                    .font(.footnote)
            }
            Spacer()
            Button("Save") {
                viewModel.saveWithConfirmation()
            }
            .buttonStyle(.borderedProminent)
            .tint(Color("AppPrimaryColor"))
            .controlSize(.large)
            .keyboardShortcut(.defaultAction)
            .disabled(!viewModel.isSaveEnabled)
        }
        .padding(.horizontal, HEADER_HORIZONTAL_PADDING)
        .padding(.vertical, SAVE_BAR_VERTICAL_PADDING)
        .frame(maxWidth: .infinity)
        .background(Color("CardColor").shadow(radius: 16, y: -8))
    }
}
