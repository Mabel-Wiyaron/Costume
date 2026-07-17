import SwiftUI

//STRUKTUR DATA
struct Resume: Identifiable {
    let id = UUID()
    let role: String
    let company: String
    let date: String
}

struct ResumeCard: View {
    let resume: Resume
    
    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            HStack {
                Spacer()
                Text(resume.date)
                    .font(.body)
                    .foregroundColor(.secondary)
            }
            Spacer()
            
            Text(resume.role)
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(.text)
            
            Text(resume.company)
                .font(.body)
                .foregroundColor(.accent)
        }
        .padding(25)
        .frame(maxWidth: .infinity, minHeight: 154, maxHeight: 154, alignment: .leading)
        .background(Color(NSColor.controlBackgroundColor))
        .cornerRadius(12)
        .cornerRadius(12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.accent)
                .offset(y:8)
            )
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
        .onHover { isHovered in
            if isHovered { NSCursor.pointingHand.push() }
            else { NSCursor.pop() }
        }
    }
}
//DUMMY DATA
#Preview {
    ResumeCard(resume: Resume(role: "Apple Developer Academy", company: "Apple CIP", date: "01/02/26"))
        .padding()
}
