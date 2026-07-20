//
//  CVPreviewView.swift
//  Costume
//
//  Created by Sharon Tan on 16/07/26.
//

import SwiftUI
import SwiftData

struct CVPreviewView: View {
    // Digunakan untuk menyimpan dan mengelola konteks database SwiftData
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    // Kueri reaktif untuk mengambil data Profile dari SwiftData secara otomatis saat ada perubahan
    @Query private var profiles: [Profile]
    
    // Profil spesifik yang ingin di-preview (opsional)
    var profile: Profile? = nil
    
    @State private var zoomScale: CGFloat = 1.0
    @GestureState private var gestureZoomScale: CGFloat = 1.0
    
    // Nama dokumen yang ditampilkan di bilah navigasi aplikasi
    private var documentName: String {
        if let jobDesc = currentProfile.jobDescription,
           let role = jobDesc.role, !role.isEmpty,
           let company = jobDesc.company, !company.isEmpty {
            return "\(role) - \(company)"
        }
        return "Mabel_CV_Apple"
    }
    
    // Menghitung profil aktif saat ini dari database.
    // Jika database kosong, mengembalikan profil default sementara untuk visualisasi awal
    private var currentProfile: Profile {
        profile ?? profiles.first ?? CVPreviewView.defaultProfile
    }
    
    static var defaultProfile: Profile {
        Profile(
            name: "MABEL WIYARON",
            email: "hello@mabelwiyaron.com",
            location: "Surabaya, Indonesia",
            phone: "+6281234567890",
            linkedin: URL(string: "https://linkedin.com/in/mabelwiyaron/"),
            website: URL(string: "https://mabelwiyaron.com"),
            summary: "Dedicated student with a strong focus on Software Engineering and Backend Development, seeking to leverage technical skills in a dynamic team."
        )
    }
    
    private var pages: [PageContent] {
        ATSCVTemplateView.distribute(profile: currentProfile)
    }
    
    private func renderPage(_ page: PageContent) -> some View {
        let currentScale = zoomScale * gestureZoomScale
        return ATSCVTemplateView(profile: currentProfile, pageContent: page)
            .background(Color.white)
            .shadow(color: Color.black.opacity(0.15), radius: 6, x: 0, y: 3)
            .frame(width: 595, height: 842)
            .scaleEffect(currentScale)
            .frame(width: 595 * currentScale, height: 842 * currentScale)
    }
    
    var body: some View {
        // Wadah Navigasi Stack untuk mendukung transisi layar secara native (push & pop)
        NavigationStack {
            // 1. Area Lembar Kerja (Canvas) yang dapat digulir secara vertikal
            ScrollView {
                VStack(spacing: 20) { // Memberikan jarak antar kertas A4 sebesar 20pt
                    ForEach(pages) { page in
                        // Merender satu halaman A4 spesifik sesuai dengan data porsinya
                        renderPage(page)
                    }
                }
                .padding(40)
                .frame(maxWidth: .infinity)
                .gesture(
                    MagnificationGesture()
                        .updating($gestureZoomScale) { value, state, _ in
                            state = value
                        }
                        .onEnded { value in
                            let nextScale = zoomScale * value
                            zoomScale = max(0.5, min(2.0, nextScale))
                        }
                )
            }
            // 2. Latar belakang abu-abu terang standar dokumen viewer macOS
            .background(Color.background)
            .navigationTitle(documentName)
            .navigationBarBackButtonHidden(true)
            // 3. Bilah Alat (Toolbar) standard macOS HIG
            .toolbar {
                //back button
                ToolbarItem(placement: .navigation) {
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "chevron.left")
                    }
                }
                
              //zoom
               ToolbarItemGroup(placement: .automatic) {
                    HStack(spacing: 8) {
                        
                        Text(" ")
                        Button(action: {
                            zoomScale = max(0.5, zoomScale - 0.1)
                        }) {
                            Image(systemName: "minus.magnifyingglass")
                        }
                        .disabled(zoomScale <= 0.5)
                        .buttonStyle(.plain)
                        
                        Text("\(Int(zoomScale * 100))%")
                            .font(.system(.body, design: .monospaced))
                            .frame(width: 45)
                        
                        Button(action: {
                            zoomScale = min(2.0, zoomScale + 0.1)
                        }) {
                            Image(systemName: "plus.magnifyingglass")
                        }
                        .disabled(zoomScale >= 2.0)
                        .buttonStyle(.plain)
                        
                        Button("Actual Size") {
                            zoomScale = 1.0
                        }
                        .disabled(zoomScale == 1.0)
                      
                // Sisi Kanan: Tombol aksi utama (Edit & Ekspor)
                ToolbarItemGroup(placement: .primaryAction) {
                    NavigationLink(destination: EditCVView(document: CVDocument(profile: currentProfile), jobDescription: currentProfile.jobDescription, modelContext: modelContext, onBack: {
                        NotificationCenter.default.post(name: .popToDashboard, object: nil)
                    })) {
                        Label("Edit", systemImage: "pencil")
                    }
                    .help("Edit Resumé")
                    
                    Button(action: { print("Export") }) {
                        Label("Export to PDF", systemImage: "square.and.arrow.up")
                    }
                    .help("Export to PDF")
                }
            }
            // Memicu inisialisasi pengisian data default ketika view ini pertama kali muncul di layar
            .onAppear {
                createDefaultProfileIfNeeded()
            }
        }
    }
    
    // Fungsi untuk menyuntikkan data profil contoh ("MABEL WIYARON") ke database jika terdeteksi masih kosong
    private func createDefaultProfileIfNeeded() {
        guard profiles.isEmpty else { return }
        
        let sampleProfile = Profile(
            name: "MABEL WIYARON",
            email: "hello@mabelwiyaron.com",
            location: "Surabaya, Indonesia",
            phone: "+6281234567890",
            linkedin: URL(string: "https://linkedin.com/in/mabelwiyaron/"),
            website: URL(string: "https://mabelwiyaron.com"),
            summary: "Dedicated student with a strong focus on Software Engineering and Backend Development, seeking to leverage technical skills in a dynamic team.",
            profileLinks: [
                ProfileLink(platform: .github, url: URL(string: "https://github.com/mabelwiyaron")!)
            ],
            experiences: [
                Experience(
                    role: "Software Engineer",
                    employmentType: .internship,
                    company: "Apple Developer Academy @ UC",
                    location: "Surabaya, Indonesia",
                    startDate: Calendar.current.date(from: DateComponents(year: 2026, month: 3)) ?? Date(),
                    endDate: nil,
                    descriptionText: [
                        "Increased UI development efficiency by 30% by building reusable components using SwiftUI and MVVM architecture.",
                        "Reduced app data access latency by 45% by implementing offline caching using Core Data for persistent local storage.",
                        "Reduced merge conflicts by 50% by enforcing structured Git branching strategy and collaborative workflows in a 5-member Agile team."
                    ]
                ),
                Experience(
                    role: "UI UX Designer",
                    employmentType: .freelance,
                    company: "Freelance @ Fiverr",
                    location: "Remote",
                    startDate: Calendar.current.date(from: DateComponents(year: 2025, month: 1)) ?? Date(),
                    endDate: nil,
                    descriptionText: [
                        "Designed and developed user-centered UI/UX solutions for Fiverr clients, leveraging expertise in human-computer interaction and visual design principles.",
                        "Utilized design tools such as Sketch, Figma, and Adobe XD to create high-fidelity wireframes, prototypes, and final designs, ensuring seamless user experiences.",
                        "Collaborated with clients to understand project requirements, identify design opportunities, and deliver tailored UI/UX solutions that met their needs and goals."
                    ]
                ),
                Experience(
                    role: "Web Developer Intern",
                    employmentType: .internship,
                    company: "Callour Studio",
                    location: "Purwokerto, Indonesia",
                    startDate: Calendar.current.date(from: DateComponents(year: 2024, month: 7)) ?? Date(),
                    endDate: Calendar.current.date(from: DateComponents(year: 2024, month: 9)),
                    descriptionText: [
                        "Developed and implemented multiple web applications using HTML, CSS, and JavaScript, enhancing the overall user experience.",
                        "Collaborated with the Callour Studio team to design and deploy a scalable web development framework, utilizing Agile methodologies and version control systems like Git.",
                        "Contributed to the improvement of the studio's web development workflow by implementing automated testing and debugging tools, such as Jest and Webpack."
                    ]
                ),
                Experience(
                    role: "Head of Creative Media",
                    employmentType: .volunteer,
                    company: "Soedirman Robotic Team",
                    location: "Purwokerto, Indonesia",
                    startDate: Calendar.current.date(from: DateComponents(year: 2024, month: 3)) ?? Date(),
                    endDate: Calendar.current.date(from: DateComponents(year: 2024, month: 12)),
                    descriptionText: [
                        "Developed and implemented multiple web applications using HTML, CSS, and JavaScript, enhancing the overall user experience.",
                        "Reduced app data access latency by 45% by implementing offline caching using Core Data for persistent local storage."
                    ]
                )
            ],
            educations: [
                Education(
                    school: "Universitas Ciputra",
                    degree: "Bachelor of Computer Science",
                    fieldOfStudy: "",
                    startDate: Calendar.current.date(from: DateComponents(year: 2021, month: 7)) ?? Date(),
                    endDate: Calendar.current.date(from: DateComponents(year: 2025, month: 3)),
                    grade: "3.66 / 4.00"
                )
            ],
            certifications: [
                Certification(name: "The Basics of Google Cloud Compute Skill Badge", issuer: "Google Cloud", issueDate: Date(), credentialID: ""),
                Certification(name: "Build Real World AI Applications with Gemini and Imagen Skill Badge", issuer: "Google Cloud", issueDate: Date(), credentialID: ""),
                Certification(name: "Prompt Design in Vertex AI Skill Badge", issuer: "Google Cloud", issueDate: Date(), credentialID: ""),
                Certification(name: "Belajar Dasar AI", issuer: "Dicoding", issueDate: Date(), credentialID: "")
            ],
            projects: [
                Project(
                    role: "Team Lead",
                    name: "Soedirman Robotic Team Website",
                    startDate: Calendar.current.date(from: DateComponents(year: 2023, month: 7)) ?? Date(),
                    endDate: Calendar.current.date(from: DateComponents(year: 2023, month: 7)),
                    website: URL(string: "https://soedirmanrobotic.com"),
                    descriptionText: []
                ),
                Project(
                    role: "Software Engineer",
                    name: "Quack Fight",
                    startDate: Calendar.current.date(from: DateComponents(year: 2026, month: 3)) ?? Date(),
                    endDate: Calendar.current.date(from: DateComponents(year: 2026, month: 3)),
                    website: URL(string: "https://github.com/jflakjflkjad"),
                    descriptionText: []
                )
            ],
            awards: [
                Award(title: "Juara 1 di hati Kevin", issuer: "Kevin", issueDate: Date()),
                Award(title: "Couple of the year by Apple Dev Academy @ UC 2026", issuer: "Apple Dev Academy @ UC", issueDate: Date())
            ],
            languages: [
                Language(name: "Bahasa Indonesia", proficiency: "Native"),
                Language(name: "English", proficiency: "Advanced"),
                Language(name: "Mandarin", proficiency: "Beginner")
            ],
            skills: [
                Skill(name: "Python"),
                Skill(name: "C++"),
                Skill(name: "TypeScript"),
                Skill(name: "SQL"),
                Skill(name: "Rust"),
                Skill(name: "C/C++"),
                Skill(name: "TensorFlow")
            ]
        )
        
        modelContext.insert(sampleProfile)
        try? modelContext.save()
    }
}

// Preview Xcode Canvas untuk merender komponen preview secara langsung di Xcode
#Preview {
    NavigationStack {
        CVPreviewView()
    }
    .modelContainer(for: Profile.self, inMemory: true)
}
