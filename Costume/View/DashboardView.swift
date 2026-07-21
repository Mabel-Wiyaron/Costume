//
//  DashboardView.swift
//  Costume
//
//  Created by Nayla Abel Sabathyani on 16/07/26.
//

import SwiftUI
import SwiftData

struct DashboardView: View {
    @Environment(\.modelContext) private var modelContext
    
    @Query private var profiles: [Profile]
    
    
    @State private var searchText = ""
    @State private var isSearchExpanded = false
    @FocusState private var isSearchFocused: Bool
    
    @State private var navigationId = UUID()
    
    let columns = Array(repeating: GridItem(.flexible(), spacing: 20), count: 4)
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yy"
        return formatter.string(from: date)
    }
    
    // Mengurutkan data profil secara in-memory berdasarkan tanggal pembuatan job description (terbaru dahulu).
    // Hal ini diperlukan karena @Query SwiftData tidak mendukung pengurutan langsung (sort keypath) menggunakan properti relasi objek.
    var sortedProfiles: [Profile] {
        profiles
            .filter { $0.jobDescription != nil }
            .sorted { p1, p2 in
                let d1 = p1.jobDescription?.createdAt ?? Date.distantPast
                let d2 = p2.jobDescription?.createdAt ?? Date.distantPast
                return d1 > d2
            }
    }
    
    // Menyaring daftar profil berdasarkan teks pencarian yang dimasukkan pengguna (mencari kecocokan pada role, company, atau format tanggal).
    var filteredProfiles: [Profile] {
        if searchText.isEmpty {
            return sortedProfiles
        } else {
            return sortedProfiles.filter { profile in
                let role = profile.jobDescription?.role ?? "Resumé Mockup"
                let company = profile.jobDescription?.company ?? "costumé"
                let dateString = formatDate(profile.jobDescription?.createdAt ?? Date())
                return role.localizedCaseInsensitiveContains(searchText) ||
                       company.localizedCaseInsensitiveContains(searchText) ||
                       dateString.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
    
    
    var body: some View {
            NavigationStack {
                ZStack(alignment: .top) {
                    Color.background
                        .ignoresSafeArea()
                    
                    CustomHeaderShape()
                        .fill(Color(.primary))
                        .frame(height: 260)
                        .ignoresSafeArea(edges: .top)
                    
                    VStack(alignment: .leading, spacing: 35) {
                        
                        HStack {
                            Text("costumé") //LOGO NANTI DISINI
                                .font(.system(size: 28, weight: .bold))
                                .foregroundColor(.white)
                            
                            Spacer()
                            
                            HStack {
                            Image(systemName: "magnifyingglass")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.black)
                            TextField("Search resumé...", text: $searchText)
                            .textFieldStyle(.plain)
                            .foregroundColor(.primary)
                            if !searchText.isEmpty {
                            Button(action: {
                            searchText = ""
                            }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.gray)
                            }
                        .buttonStyle(.plain)
                        .transition(.opacity)
                            }
                        }
                    .padding(8)
                    .background(Color.white.opacity(0.8))
                        .cornerRadius(20)
                    .frame(width: 250)
                        .animation(.easeInOut(duration: 0.2), value: searchText.isEmpty)
                            NavigationLink(destination: EditProfileView()) {
                                Image(systemName: "person")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(.black)
                                    .frame(width: 40, height: 40)
                                    .background(Color.white.opacity(0.8))
                                    .clipShape(Circle())
                            }
                            .buttonStyle(.plain)
                        }
                        .padding(.horizontal, 120)
                        .padding(.top, 80)
                        
                        HStack(spacing: 12) {
                            Text("􀈕 All your Resumé")
                        }
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding(.horizontal, 120)
                        
                        ScrollView {
                            if !searchText.isEmpty && filteredProfiles.isEmpty {
                                EmptyStateView(searchText: searchText)
                            } else {
                                LazyVGrid(columns: columns, spacing: 24) {
                                    if searchText.isEmpty {
                                        NavigationLink(destination: JobDescInputFormView()) {
                                            NewProjectCard()
                                        }
                                        .buttonStyle(.plain)
                                        .transition(.scale(scale: 0.9).combined(with: .opacity))
                                    }
                                    
                                    ForEach(filteredProfiles) { profile in
                                        // Membuat representasi data Resume untuk dirender ke dalam kartu (ResumeCard).
                                        // Properti role, company, dan createdAt diambil secara aman dari relasi jobDescription.
                                        let resume = Resume(
                                            role: profile.jobDescription?.role ?? "Resumé Mockup",
                                            company: profile.jobDescription?.company ?? "costumé",
                                            date: formatDate(profile.jobDescription?.createdAt ?? Date())
                                        )
                                        NavigationLink(destination: CVPreviewView(profile: profile)) {
                                            ResumeCard(resume: resume)
                                        }
                                        .buttonStyle(.plain)
                                    }
                                }
                                .padding(.horizontal, 120)
                                .padding(.bottom, 80)
                                .animation(.spring(response: 0.4, dampingFraction: 0.8), value: searchText)
                            }
                        }
                    }
                }
            }
            .id(navigationId)
            .onReceive(NotificationCenter.default.publisher(for: .popToDashboard)) { _ in
                navigationId = UUID()
            }
        }
    }

struct EmptyStateView: View {
    let searchText: String
    
    var body: some View {
        VStack(spacing: 5) {
            Image("SearchEmptyState")
                .resizable()
                .scaledToFit()
                .frame(height: 100)
            Text("No results found for \"\(searchText)\"")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.primary)
            
            Text("Try searching for a different role, company, or date.")
                .font(.body)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 150)
    }
}

struct CustomHeaderShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        path.move(to: CGPoint(x: 0, y: 0))
        path.addLine(to: CGPoint(x: rect.width, y: 0))
        path.addLine(to: CGPoint(x: rect.width, y: rect.height + 60))

        path.addQuadCurve(
            to: CGPoint(x: 0, y: rect.height + 60),
            control: CGPoint(x: rect.width / 2, y: rect.height - 10)
        )
        
        path.addLine(to: CGPoint(x: 0, y: 0))
        return path
    }
}

#Preview {
    DashboardView()
        .modelContainer(for: Profile.self, inMemory: true)
}
