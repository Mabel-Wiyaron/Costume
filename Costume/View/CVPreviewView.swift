//
//  CVPreviewView.swift
//  Costume
//
//  Created by Sharon Tan on 16/07/26.
//

import SwiftUI
import SwiftData

struct CVPreviewView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Query private var profiles: [Profile]
    
    var profile: Profile? = nil
    var documentName: String = "Mabel_CV_Apple"
    
    @State private var zoomScale: CGFloat = 1.0
    @GestureState private var gestureZoomScale: CGFloat = 1.0
    
    // 💡 Performance Fix 1: Cache computed pagination and document name in State
    @State private var cachedPages: [PageContent] = []
    @State private var cachedDocumentName: String = ""
    
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
            summary: "Dedicated student with a strong focus on Software Engineering and Backend Development."
        )
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                ForEach(cachedPages) { page in
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
        .background(Color.background)
        .navigationTitle(cachedDocumentName)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigation) {
                Button(action: {
                    NotificationCenter.default.post(name: .popToDashboard, object: nil)
                }) {
                    Image(systemName: "chevron.left")
                }
            }
            
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
                }
            }
            
            ToolbarItemGroup(placement: .primaryAction) {
                NavigationLink(destination: EditCVView(
                    document: CVDocument(profile: currentProfile),
                    jobDescription: currentProfile.jobDescription,
                    modelContext: modelContext,
                    onBack: {
                        NotificationCenter.default.post(name: .popToDashboard, object: nil)
                    }
                )) {
                    Label("Edit", systemImage: "pencil")
                }
                .help("Edit Resumé")
                
                Button(action: {
                    DispatchQueue.main.async {
                        PDFExporter.export(profile: currentProfile, defaultFilename: cachedDocumentName)
                    }
                }) {
                    Label("Export to PDF", systemImage: "square.and.arrow.up")
                }
                .help("Export to PDF")
            }
        }
        // 💡 Performance Fix 2: Calculate pagination asynchronously off the main thread once
        .task(id: currentProfile.id) {
            createDefaultProfileIfNeeded()
            recalculatePages()
        }
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
    
    // 💡 Offload page calculation out of the body evaluation cycle
    private func recalculatePages() {
        let prof = currentProfile
        
        // Formatted Document Name
        if let jobDesc = prof.jobDescription,
           let role = jobDesc.role, !role.isEmpty,
           let company = jobDesc.company, !company.isEmpty {
            self.cachedDocumentName = "\(role) - \(company)"
        } else {
            self.cachedDocumentName = documentName
        }
        
        // Calculate pages once
        self.cachedPages = ATSCVTemplateView.distribute(profile: prof)
    }
    
    private func createDefaultProfileIfNeeded() {
        guard profile == nil && profiles.isEmpty else { return }
        
        let sampleProfile = Profile(
            name: "MABEL WIYARON",
            email: "hello@mabelwiyaron.com",
            location: "Surabaya, Indonesia",
            phone: "+6281234567890",
            linkedin: URL(string: "https://linkedin.com/in/mabelwiyaron/"),
            website: URL(string: "https://mabelwiyaron.com"),
            summary: "Dedicated student with a strong focus on Software Engineering and Backend Development."
        )
        
        modelContext.insert(sampleProfile)
        try? modelContext.save()
    }
}
