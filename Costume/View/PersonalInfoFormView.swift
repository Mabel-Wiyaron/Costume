import SwiftUI

struct PersonalInfoFormView: View {
    @Bindable var viewModel: EditProfileViewModel

    private enum Field: Hashable {
        case name, email, phone
    }
    
    @FocusState private var focusedField: Field?

    @State private var nameTouched = false
    @State private var emailTouched = false
    @State private var phoneTouched = false

    private let CARD_PADDING: CGFloat = 32
    private let COLUMN_SPACING: CGFloat = 32
    private let SECTION_SPACING: CGFloat = 32

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: SECTION_SPACING) {
                VStack(alignment: .leading, spacing: 16) {
                    SectionHeaderView(title: "Personal Information")

                    Text("Tip: The more detailed your profile is, the better our AI can personalize your CV.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)

                    // --- FIELD: NAME ---
                    LabeledTextField(
                        label: "Name",
                        isRequired: true,
                        text: $viewModel.profile.name,
                        isError: shouldShowNameError,
                        errorMessage: "Name is required"
                    )
                    .focused($focusedField, equals: .name)

                    HStack(alignment: .top, spacing: COLUMN_SPACING) {
                        // --- FIELD: CONTACT / PHONE ---
                        LabeledTextField(
                            label: "Contact",
                            isRequired: true,
                            placeholder: "+62 1234567890",
                            text: $viewModel.profile.phone,
                            isError: shouldShowPhoneError,
                            errorMessage: viewModel.profile.phone.isEmpty ? "Contact number is required" : "Invalid phone format (e.g., +6281234567)"
                        )
                        .focused($focusedField, equals: .phone)
                        .frame(maxWidth: .infinity)

                        LabeledTextField(
                            label: "LinkedIn",
                            text: $viewModel.profile.linkedin.stringValue
                        )
                        .frame(maxWidth: .infinity)
                    }

                    HStack(alignment: .top, spacing: COLUMN_SPACING) {
                        // --- FIELD: EMAIL ---
                        LabeledTextField(
                            label: "Email",
                            isRequired: true,
                            text: $viewModel.profile.email,
                            isError: shouldShowEmailError,
                            errorMessage: viewModel.profile.email.isEmpty ? "Email is required" : "Invalid email format (e.g., name@example.com)"
                        )
                        .focused($focusedField, equals: .email)
                        .frame(maxWidth: .infinity)

                        LabeledTextField(
                            label: "Personal Website",
                            text: $viewModel.profile.website.stringValue
                        )
                        .frame(maxWidth: .infinity)
                    }

                    HStack(alignment: .top, spacing: COLUMN_SPACING) {
                        LabeledTextField(
                            label: "Location",
                            text: $viewModel.profile.location
                        )
                        .frame(maxWidth: .infinity)
                        
                        LabeledTextField(
                            label: "Github",
                            text: $viewModel.profile.links.urlString(forPlatform: .github)
                        )
                        .frame(maxWidth: .infinity)
                    }
                }

                VStack(alignment: .leading, spacing: 16) {
                    SectionHeaderView(title: "Summary")
                    LabeledTextEditor(
                        label: "About Me",
                        text: $viewModel.profile.summary.stringValue
                    )
                }

                HStack {
                    Spacer()
                    Button("Save") {
                        viewModel.save()
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(Color("PrimaryColor"))
                    .controlSize(.large)
                    .keyboardShortcut(.defaultAction)
                    .disabled(!viewModel.isPersonalInfoSaveEnabled)
                }
            }
            .padding(CARD_PADDING)
            .cardBackground()
        }
        .onChange(of: focusedField) { oldFocus, newFocus in
            if oldFocus == .name && newFocus != .name { nameTouched = true }
            if oldFocus == .email && newFocus != .email { emailTouched = true }
            if oldFocus == .phone && newFocus != .phone { phoneTouched = true }
        }
        .animation(.default, value: nameTouched)
        .animation(.default, value: emailTouched)
        .animation(.default, value: phoneTouched)
    }

    // MARK: - Computed Properties untuk Logika Error Tampilan
    
    private var shouldShowNameError: Bool {
        nameTouched && !viewModel.isNameValid
    }
    
    private var shouldShowEmailError: Bool {
        emailTouched && !viewModel.isEmailValid
    }
    
    private var shouldShowPhoneError: Bool {
        phoneTouched && !viewModel.isPhoneValid
    }
}
