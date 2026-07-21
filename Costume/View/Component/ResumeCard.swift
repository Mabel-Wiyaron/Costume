import SwiftUI

//STRUKTUR DATA
struct Resume: Identifiable {
    let id = UUID()
    let role: String
    let company: String
    let date: String
}

enum ResumeCardField: Hashable {
    case role, company
}

// Presentational only: renders the card, no menu, no alert, no navigation logic.
struct ResumeCard: View {
    let resume: Resume
    @Binding var isEditing: Bool
    @Binding var draftRole: String
    @Binding var draftCompany: String
    var onCommitRename: () -> Void
    var focusedField: FocusState<ResumeCardField?>.Binding

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            HStack {
                Spacer()
                Text(resume.date)
                    .font(.body)
                    .foregroundColor(.secondary)
                Color.clear.frame(width: 20, height: 16)
            }
            Spacer()

            if isEditing {
                TextField("", text: $draftRole)
                    .textFieldStyle(.plain)
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.text)
                    .focused(focusedField, equals: .role)
                    .onSubmit(onCommitRename)

                TextField("", text: $draftCompany)
                    .textFieldStyle(.plain)
                    .font(.body)
                    .foregroundColor(.accent)
                    .focused(focusedField, equals: .company)
                    .onSubmit(onCommitRename)
            } else {
                Text(resume.role)
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.text)

                Text(resume.company)
                    .font(.body)
                    .foregroundColor(.accent)
            }
        }
        .padding(25)
        .frame(
            maxWidth: .infinity,
            minHeight: 154,
            maxHeight: 154,
            alignment: .leading
        )
        .background(Color(NSColor.controlBackgroundColor))
        .cornerRadius(12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.accent)
                .offset(y: 8)
        )
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
        .onHover { isHovered in
            if isHovered { NSCursor.pointingHand.push() }
            else { NSCursor.pop() }
        }
    }
}

// Owns state and composes NavigationLink + ellipsis menu as siblings,
// so the menu never lives inside the NavigationLink's press-state hierarchy.
struct ResumeCardContainer: View {
    let profile: Profile
    let resume: Resume
    var onRename: (String, String) -> Void
    var onDelete: () -> Void

    @State private var isEditing = false
    @State private var draftRole: String = ""
    @State private var draftCompany: String = ""
    @State private var isDeleteAlertPresented = false
    @State private var isEllipsisHovered = false
    @FocusState private var focusedField: ResumeCardField?

    var body: some View {
        ZStack(alignment: .topTrailing) {
            NavigationLink(destination: CVPreviewView(profile: profile)) {
                ResumeCard(
                    resume: resume,
                    isEditing: $isEditing,
                    draftRole: $draftRole,
                    draftCompany: $draftCompany,
                    onCommitRename: commitRename,
                    focusedField: $focusedField
                )
            }
            .buttonStyle(.plain)

            ZStack {
                Circle()
                    .fill(Color.gray.opacity(isEllipsisHovered ? 0.25 : 0))
                    .frame(width: 20, height: 20)

                Menu {
                    Button("Rename Resumé", action: startEditing)
                    Button("Delete Resumé", role: .destructive) {
                        isDeleteAlertPresented = true
                    }
                } label: {
                    Image(systemName: "ellipsis")
                        .foregroundColor(.secondary)
                        .frame(width: 20, height: 20)
                }
                .menuStyle(.borderlessButton)
                .menuIndicator(.hidden)
                .frame(width: 20, height: 20)
            }
            .rotationEffect(.degrees(90))
            .contentShape(Circle())
            .onHover { isHovered in
                isEllipsisHovered = isHovered
                if isHovered { NSCursor.pointingHand.push() }
                else { NSCursor.pop() }
            }
            .padding(.top, 23)
            .padding(.trailing, 25)
        }
        .alert("Delete this Resumé?", isPresented: $isDeleteAlertPresented) {
            Button("Cancel", role: .cancel) {}
            Button("Delete", role: .destructive, action: onDelete)
        } message: {
            Text("This action can't be undone.")
        }
    }

    private func startEditing() {
        draftRole = resume.role
        draftCompany = resume.company
        isEditing = true
        focusedField = .role
    }

    private func commitRename() {
        onRename(draftRole, draftCompany)
        isEditing = false
        focusedField = nil
    }
}

//DUMMY DATA
#Preview {
    ResumeCardContainer(
        profile: Profile(name: "", email: "", location: "", phone: ""),
        resume: Resume(
            role: "Apple Developer Academy",
            company: "Apple CIP",
            date: "01/02/26"
        ),
        onRename: { _, _ in
        },
        onDelete: {}
    )
    .padding()
}
