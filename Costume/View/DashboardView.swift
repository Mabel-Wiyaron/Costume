//
//  DashboardView.swift
//  Costume
//
//  Created by Nayla Abel Sabathyani on 16/07/26.
//

import SwiftUI

struct resume: Identifiable {
    let id = UUID()
    let role: String
    let company: String
    let date: String
}

let mockResumes = [
        Resume(role: "Resumé Mockup", company: "costumé", date: "16/07/26"),
        Resume(role: "iOS Developer", company: "Apple", date: "10/05/26"),
        Resume(role: "UI/UX Designer", company: "Google", date: "12/06/26"),
        Resume(role: "Resumé Mockup", company: "costumé", date: "16/07/26"),

]
struct DashboardView: View {
    @State private var searchText = ""
    @State private var isSearchExpanded = false
        @FocusState private var isSearchFocused: Bool
    let columns = Array(repeating: GridItem(.flexible(), spacing: 20), count: 4)
    var filteredResumes: [Resume] {
            if searchText.isEmpty {
                return mockResumes
            } else {
                return mockResumes.filter { resume in
                    resume.role.localizedCaseInsensitiveContains(searchText) ||
                    resume.company.localizedCaseInsensitiveContains(searchText) ||
                    resume.date.localizedCaseInsensitiveContains(searchText)
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
                            .foregroundColor(.gray)
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
                            
                            Button(action: {
                                //EDIT PROFIL DISINI
                            }) {
                                Image(systemName: "person")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(.blue)
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
                            if !searchText.isEmpty && filteredResumes.isEmpty {
                                                            EmptyStateView(searchText: searchText)
                                                        } else {
                            LazyVGrid(columns: columns, spacing: 24) {
                                if searchText.isEmpty {
                                                NavigationLink(destination: Text("Halaman Job Description Analyzer")) {
                                                    NewProjectCard()
                                                }                                .buttonStyle(.plain)
                                        .transition(.scale(scale: 0.9).combined(with: .opacity))
                                                    }
                                
                                ForEach(filteredResumes) { resume in
                                                NavigationLink(destination: Text("Halaman Editor CV")) {
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
}

