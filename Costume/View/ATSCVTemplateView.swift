//
//  ATSCVTemplateView.swift
//  Costume
//
//  Created by Sharon Tan on 17/07/26.
//

import SwiftUI

// Struktur data representatif untuk menyimpan bagian yang akan dimuat ke satu lembar halaman A4 tertentu
struct PageContent: Identifiable {
    let id = UUID()
    var hasHeader = false
    var hasSummary = false
    var experiences: [Experience] = []
    var educations: [Education] = []
    var projects: [Project] = []
    var showSkills = false
    var volunteerExperiences: [Experience] = []
}

// Komponen View SwiftUI untuk merender lembar CV dengan format ATS yang bersih dan rapi
struct ATSCVTemplateView: View {
    // Menyimpan referensi ke model Profile yang berisi seluruh data CV pengguna
    let profile: Profile
    // Konten spesifik yang harus dirender pada lembar halaman A4 ini
    let pageContent: PageContent
    
    // Mengubah objek Date menjadi format string bulan dan tahun, misalnya: "Mar 2026"
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM yyyy"
        return formatter.string(from: date)
    }

    // Memformat rentang tanggal pekerjaan/pendidikan menjadi format periodik, misalnya: "Mar 2026 - Present"
    private func formatPeriod(start: Date, end: Date?) -> String {
        let startStr = formatDate(start)
        if let end = end {
            return "\(startStr) - \(formatDate(end))"
        } else {
            return "\(startStr) - Present"
        }
    }

    // Membuat visualisasi informasi kontak di header yang terpisah spasi-koma-spasi ( , )
    // Menggunakan AttributedString SwiftUI agar garis bawah (underline) hanya aktif pada link saja
    private func contactInfoView() -> some View {
        var contactInfo = AttributedString()
        var hasPreviousItem = false

        // Helper lokal untuk menambahkan item kontak secara kondisional
        func appendItem(_ value: String, isUnderlined: Bool = false) {
            guard !value.isEmpty else { return }

            // Tambahkan pemisah spasi-koma-spasi jika ini bukan item pertama
            if hasPreviousItem {
                contactInfo += AttributedString(" , ")
            }

            var item = AttributedString(value)
            if isUnderlined {
                item.underlineStyle = .single // Memberikan garis bawah pada tautan
            }

            contactInfo += item
            hasPreviousItem = true
        }

        // Helper lokal untuk membersihkan skema URL agar terlihat ringkas (menghapus https:// dan www.)
        func cleanURL(_ url: URL) -> String {
            url.absoluteString
                .replacingOccurrences(of: "https://", with: "")
                .replacingOccurrences(of: "www.", with: "")
        }

        // Menyusun baris kontak sesuai urutan
        appendItem(profile.email, isUnderlined: true)
        appendItem(profile.phone, isUnderlined: true)
        appendItem(profile.location) // Lokasi tidak diberi garis bawah

        if let website = profile.website {
            appendItem(cleanURL(website), isUnderlined: true)
        }
        if let linkedin = profile.linkedin {
            appendItem(cleanURL(linkedin), isUnderlined: true)
        }
        for link in profile.links {
            appendItem(cleanURL(link.url), isUnderlined: true)
        }

        return Text(contactInfo)
            .font(.system(size: 9))
            .foregroundColor(.black)
            .multilineTextAlignment(.center)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            
            // --- HEADER ---
            // Hanya dirender jika halaman ini ditandai memiliki header
            if pageContent.hasHeader {
                VStack(alignment: .center, spacing: 4) {
                    Text(profile.name.isEmpty ? "YOUR NAME" : profile.name.uppercased())
                        .font(.system(size: 20, weight: .black))
                    
                    contactInfoView()
                    
                    // Garis pembatas tebal di bawah header
                    Divider()
                        .background(Color.black)
                }
                .frame(maxWidth: .infinity)
            }
            
            // --- SUMMARY ---
            // Hanya dirender jika halaman ini memuat bagian summary
            if pageContent.hasSummary, let summary = profile.summary, !summary.isEmpty {
                SectionHeader(title: "SUMMARY")
                Text(summary)
                    .font(.system(size: 10))
            }
            
            // --- EXPERIENCE ---
            // Hanya dirender jika halaman ini memuat daftar pekerjaan professional
            if !pageContent.experiences.isEmpty {
                SectionHeader(title: "EXPERIENCE")
                
                ForEach(pageContent.experiences) { experience in
                    VStack(alignment: .leading, spacing: 2) {
                        // Baris 1: Posisi/Pekerjaan (Kiri) dan Rentang Waktu (Kanan)
                        HStack {
                            Text(experience.role)
                                .font(.system(size: 11, weight: .bold))
                            Spacer()
                            Text(formatPeriod(start: experience.startDate, end: experience.endDate))
                                .font(.system(size: 10))
                        }
                        
                        // Baris 2: Nama Perusahaan (Kiri, Bold) dan Lokasi (Kanan, Bold)
                        HStack {
                            Text(experience.company)
                                .font(.system(size: 10, weight: .bold))
                            Spacer()
                            Text(experience.location)
                                .font(.system(size: 10, weight: .bold))
                        }
                        
                        // Baris-baris deskripsi pekerjaan dalam bentuk poin bulat (Bullet points)
                        if !experience.descriptionText.isEmpty {
                            VStack(alignment: .leading, spacing: 1) {
                                ForEach(experience.descriptionText, id: \.self) { bullet in
                                    if !bullet.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                                        Text("• \(bullet)")
                                    }
                                }
                            }
                            .font(.system(size: 10))
                            .padding(.leading, 8)
                        }
                    }
                    .padding(.bottom, 4)
                }
            }
            
            // --- EDUCATION ---
            // Hanya dirender jika halaman ini memuat daftar pendidikan
            if !pageContent.educations.isEmpty {
                SectionHeader(title: "EDUCATION")
                
                ForEach(pageContent.educations) { education in
                    VStack(alignment: .leading, spacing: 2) {
                        // Baris 1: Nama Sekolah/Universitas (Kiri) dan Rentang Waktu (Kanan)
                        HStack {
                            Text(education.school)
                                .font(.system(size: 11, weight: .bold))
                            Spacer()
                            Text(formatPeriod(start: education.startDate, end: education.endDate))
                                .font(.system(size: 10))
                        }
                        
                        // Baris 2: Informasi Gelar & Bidang Studi
                        let degreeInfo = education.fieldOfStudy.isEmpty ? education.degree : "\(education.degree) in \(education.fieldOfStudy)"
                        Text(degreeInfo)
                            .font(.system(size: 10, weight: .bold))
                        
                        // Baris 3: Nilai IPK/GPA jika diisi
                        if let grade = education.grade, !grade.isEmpty {
                            Text("GPA: \(grade)")
                                .font(.system(size: 10))
                        }
                    }
                    .padding(.bottom, 4)
                }
            }
            
            // --- PROJECTS ---
            // Hanya dirender jika halaman ini memuat daftar proyek
            if !pageContent.projects.isEmpty {
                SectionHeader(title: "PROJECTS")
                
                ForEach(pageContent.projects) { project in
                    VStack(alignment: .leading, spacing: 2) {
                        // Baris 1: Nama Proyek, Badge Link Tautan inline (jika ada), dan Rentang Waktu
                        HStack(alignment: .center, spacing: 6) {
                            Text(project.name)
                                .font(.system(size: 11, weight: .bold))
                            
                            // Menambahkan badge link dengan border abu-abu jika ada website proyek
                            if let website = project.website {
                                let isGitHub = website.absoluteString.contains("github.com")
                                HStack(spacing: 3) {
                                    // Menggunakan ikon link untuk GitHub dan safari/globe untuk lainnya
                                    Image(systemName: isGitHub ? "link" : "globe")
                                        .font(.system(size: 8))
                                    Text(website.absoluteString.replacingOccurrences(of: "https://", with: "").replacingOccurrences(of: "www.", with: ""))
                                        .font(.system(size: 8))
                                }
                                .padding(.horizontal, 4)
                                .padding(.vertical, 1)
                                .background(
                                    RoundedRectangle(cornerRadius: 3)
                                        .stroke(Color.gray.opacity(0.4), lineWidth: 0.5)
                                )
                            }
                            
                            Spacer()
                            
                            Text(formatPeriod(start: project.startDate, end: project.endDate))
                                .font(.system(size: 10))
                        }
                        
                        // Baris 2: Posisi/Role dalam Proyek tersebut
                        Text(project.role)
                            .font(.system(size: 10))
                        
                        // Baris-baris deskripsi proyek dalam bentuk poin bulat (Bullet points)
                        if !project.descriptionText.isEmpty {
                            VStack(alignment: .leading, spacing: 1) {
                                ForEach(project.descriptionText, id: \.self) { bullet in
                                    if !bullet.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                                        Text("• \(bullet)")
                                    }
                                }
                            }
                            .font(.system(size: 10))
                            .padding(.leading, 8)
                        }
                    }
                    .padding(.bottom, 4)
                }
            }
            
            // --- SKILLS & AWARDS ---
            // Hanya dirender jika halaman ini ditandai memuat keahlian & penghargaan
            if pageContent.showSkills {
                let hasSkills = !profile.skills.isEmpty
                let hasLanguages = !profile.languages.isEmpty
                let hasCertifications = !profile.certifications.isEmpty
                let hasAwards = !profile.awards.isEmpty
                
                if hasSkills || hasLanguages || hasCertifications || hasAwards {
                    SectionHeader(title: "SKILLS & AWARDS")
                    
                    VStack(alignment: .leading, spacing: 3) {
                        // Keahlian Teknis (Technical Skills)
                        if hasSkills {
                            HStack(alignment: .top, spacing: 4) {
                                Text("Technical Skills:")
                                    .font(.system(size: 10, weight: .bold))
                                    .frame(width: 110, alignment: .leading) // Agar seluruh kolom nilai di kanan sejajar rapi
                                Text(profile.skills.map { $0.name }.joined(separator: ", "))
                                    .font(.system(size: 10))
                            }
                        }
                        // Kemampuan Bahasa (Languages)
                        if hasLanguages {
                            HStack(alignment: .top, spacing: 4) {
                                Text("Languages:")
                                    .font(.system(size: 10, weight: .bold))
                                    .frame(width: 110, alignment: .leading)
                                Text(profile.languages.map { "\($0.name) (\($0.proficiency))" }.joined(separator: ", "))
                                    .font(.system(size: 10))
                            }
                        }
                        // Sertifikasi Profesional (Certifications)
                        if hasCertifications {
                            HStack(alignment: .top, spacing: 4) {
                                Text("Certifications:")
                                    .font(.system(size: 10, weight: .bold))
                                    .frame(width: 110, alignment: .leading)
                                Text(profile.certifications.map { $0.name }.joined(separator: ", "))
                                    .font(.system(size: 10))
                            }
                        }
                        // Penghargaan (Awards)
                        if hasAwards {
                            HStack(alignment: .top, spacing: 4) {
                                Text("Awards:")
                                    .font(.system(size: 10, weight: .bold))
                                    .frame(width: 110, alignment: .leading)
                                Text(profile.awards.map { $0.title }.joined(separator: ", "))
                                    .font(.system(size: 10))
                            }
                        }
                    }
                }
            }
            
            // --- VOLUNTEER ---
            // Hanya dirender jika halaman ini memuat daftar riwayat volunteer
            if !pageContent.volunteerExperiences.isEmpty {
                SectionHeader(title: "VOLUNTEER")
                
                ForEach(pageContent.volunteerExperiences) { experience in
                    VStack(alignment: .leading, spacing: 2) {
                        // Baris 1: Posisi/Pekerjaan (Kiri) dan Rentang Waktu (Kanan)
                        HStack {
                            Text(experience.role)
                                .font(.system(size: 11, weight: .bold))
                            Spacer()
                            Text(formatPeriod(start: experience.startDate, end: experience.endDate))
                                .font(.system(size: 10))
                        }
                        
                        // Baris 2: Nama Organisasi (Kiri, Bold) dan Lokasi (Kanan, Bold)
                        HStack {
                            Text(experience.company)
                                .font(.system(size: 10, weight: .bold))
                            Spacer()
                            Text(experience.location)
                                .font(.system(size: 10, weight: .bold))
                        }
                        
                        // Baris-baris deskripsi sukarelawan dalam bentuk poin bulat (Bullet points)
                        if !experience.descriptionText.isEmpty {
                            VStack(alignment: .leading, spacing: 1) {
                                ForEach(experience.descriptionText, id: \.self) { bullet in
                                    if !bullet.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                                        Text("• \(bullet)")
                                    }
                                }
                            }
                            .font(.system(size: 10))
                            .padding(.leading, 8)
                        }
                    }
                    .padding(.bottom, 4)
                }
            }
            
            Spacer()
        }
        .padding(40) // Memberikan margin 40pt di sekeliling lembar kertas A4
        .frame(width: 595, height: 842) // Dimensi standar kertas A4 (dalam point)
        .foregroundColor(.black)
    }
    
    // --- LAYOUT ENGINE PAGINATION ---
    // Mendistribusikan seluruh konten ke dalam lembar halaman A4 secara dinamis berdasarkan kalkulasi tinggi baris
    static func distribute(profile: Profile) -> [PageContent] {
        var pages: [PageContent] = [PageContent()]
        var currentPageIndex = 0
        var currentHeight: CGFloat = 0
        
        // Batas tinggi konten per halaman (A4 height 842 - padding 80 = 762pt)
        let page1MaxHeight: CGFloat = 660 // Mengurangi tinggi untuk header (~100pt)
        let nextPageMaxHeight: CGFloat = 720
        
        // Fungsi pembantu untuk mendeteksi sisa ruang dan mengalokasikan halaman baru jika meluap
        func checkHeightAndAllocate(_ height: CGFloat) {
            let maxHeight = (currentPageIndex == 0) ? page1MaxHeight : nextPageMaxHeight
            if currentHeight + height > maxHeight {
                pages.append(PageContent())
                currentPageIndex += 1
                currentHeight = 0
            }
            currentHeight += height
        }
        
        // 1. Header (sekitar 90pt)
        pages[currentPageIndex].hasHeader = true
        currentHeight += 90
        
        // 2. Summary
        if let summary = profile.summary, !summary.isEmpty {
            let lines = CGFloat(max(1, summary.count / 85))
            let summaryHeight = 25 + (lines * 14) // Judul + baris teks
            pages[currentPageIndex].hasSummary = true
            currentHeight += summaryHeight
        }
        
        // 3. Experience
        let profExp = profile.experiences.filter { $0.employmentType != .volunteer }
        if !profExp.isEmpty {
            checkHeightAndAllocate(25) // Section Title
            for exp in profExp.sorted(by: { $0.startDate > $1.startDate }) {
                // Estimasi tinggi per item (meta row + company row + deskripsi bullet)
                let itemHeight = 35 + CGFloat(exp.descriptionText.count * 13)
                checkHeightAndAllocate(itemHeight)
                pages[currentPageIndex].experiences.append(exp)
            }
        }
        
        // 4. Education
        if !profile.educations.isEmpty {
            checkHeightAndAllocate(25) // Section Title
            for edu in profile.educations.sorted(by: { $0.startDate > $1.startDate }) {
                let itemHeight: CGFloat = 45
                checkHeightAndAllocate(itemHeight)
                pages[currentPageIndex].educations.append(edu)
            }
        }
        
        // 5. Projects
        if !profile.projects.isEmpty {
            checkHeightAndAllocate(25) // Section Title
            for proj in profile.projects.sorted(by: { $0.startDate > $1.startDate }) {
                let itemHeight = 35 + CGFloat(proj.descriptionText.count * 13)
                checkHeightAndAllocate(itemHeight)
                pages[currentPageIndex].projects.append(proj)
            }
        }
        
        // 6. Skills & Awards
        let hasSkills = !profile.skills.isEmpty
        let hasLanguages = !profile.languages.isEmpty
        let hasCertifications = !profile.certifications.isEmpty
        let hasAwards = !profile.awards.isEmpty
        if hasSkills || hasLanguages || hasCertifications || hasAwards {
            var linesCount = 0
            if hasSkills { linesCount += 1 }
            if hasLanguages { linesCount += 1 }
            if hasCertifications { linesCount += 1 }
            if hasAwards { linesCount += 1 }
            let skillsHeight = 25 + CGFloat(linesCount * 15)
            checkHeightAndAllocate(skillsHeight)
            pages[currentPageIndex].showSkills = true
        }
        
        // 7. Volunteer
        let volExp = profile.experiences.filter { $0.employmentType == .volunteer }
        if !volExp.isEmpty {
            checkHeightAndAllocate(25) // Section Title
            for exp in volExp.sorted(by: { $0.startDate > $1.startDate }) {
                let itemHeight = 35 + CGFloat(exp.descriptionText.count * 13)
                checkHeightAndAllocate(itemHeight)
                pages[currentPageIndex].volunteerExperiences.append(exp)
            }
        }
        
        return pages
    }
}

// Sub-komponen pembantu untuk membuat header judul bagian dengan garis hitam di bawahnya
struct SectionHeader: View {
    let title: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(title)
                .font(.system(size: 11, weight: .bold))
            Divider()
                .background(Color.black)
        }
    }
}

