//
//  PDFExporter.swift
//  Costume
//
//  Created by Sharon Tan on 21/07/26.
//

import SwiftUI
import AppKit
import UniformTypeIdentifiers

// Utility helper to export CV data (Profile) into a multi-page vector PDF file.
struct PDFExporter {
    
    /// Main function to present the macOS Save Panel dialog and render the CV into a PDF file.
    /// - Parameters:
    ///   - profile: User's Profile model containing all CV content.
    ///   - defaultFilename: Suggested default file name when the save dialog appears (e.g. "Role - Company.pdf").
    static func export(profile: Profile, defaultFilename: String) {
        // 1. Guarantee that the entire export workflow runs on the Main Thread (Thread 0)
        // This prevents thread isolation crashes (EXC_BREAKPOINT) when accessing UI or SwiftData components from background threads.
        DispatchQueue.main.async {
            
            // 2. Create and configure macOS native file save panel (NSSavePanel)
            let savePanel = NSSavePanel()
            savePanel.allowedContentTypes = [UTType.pdf] // Restrict export file type to PDF
            
            // Clean filename of invalid filesystem characters (such as '/' or ':')
            let cleanFilename = defaultFilename
                .replacingOccurrences(of: "/", with: "-")
                .replacingOccurrences(of: ":", with: "-")
            savePanel.nameFieldStringValue = cleanFilename.hasSuffix(".pdf") ? cleanFilename : "\(cleanFilename).pdf"
            
            // 3. Present the Save Panel interactively to the user
            savePanel.begin { response in
                // Return to Main Thread to process saving after the user chooses a location and clicks "Save"
                DispatchQueue.main.async {
                    guard response == .OK, let url = savePanel.url else { return }
                    
                    // 4. Calculate and distribute all CV content across A4 pages (standard size: 595x842 pt)
                    let pages = ATSCVTemplateView.distribute(profile: profile)
                    let width: CGFloat = 595
                    let height: CGFloat = 842
                    
                    var mediaBox = CGRect(x: 0, y: 0, width: width, height: height)
                    
                    // 5. Initialize CGDataConsumer & CGContext specifically for writing PDF data directly to the chosen URL
                    guard let consumer = CGDataConsumer(url: url as CFURL),
                          let pdfContext = CGContext(consumer: consumer, mediaBox: &mediaBox, nil) else {
                        return
                    }
                    
                    // 6. Iterate through each distributed page and render it into the PDF Context
                    for page in pages {
                        // Render SwiftUI view (ATSCVTemplateView) for this page
                        let pageView = ATSCVTemplateView(profile: profile, pageContent: page)
                            .background(Color.white)
                            .frame(width: width, height: height)
                        
                        // ImageRenderer renders SwiftUI view hierarchy (text, lines, layout) directly to PDF vector graphics
                        let renderer = ImageRenderer(content: pageView)
                        renderer.render { size, context in
                            var pageBox = CGRect(origin: .zero, size: CGSize(width: width, height: height))
                            pdfContext.beginPage(mediaBox: &pageBox) // Open new PDF page
                            context(pdfContext)                    // Draw SwiftUI vector into PDF Context
                            pdfContext.endPage()                      // End PDF page
                        }
                    }
                    
                    // 7. Complete and finalize writing the PDF file to disk
                    pdfContext.closePDF()
                    
                    // 8. Present native confirmation dialog (NSAlert) confirming successful export
                    let alert = NSAlert()
                    alert.messageText = "CV Exported Successfully"
                    alert.informativeText = "Your CV PDF document has been saved to:\n\(url.lastPathComponent)"
                    alert.alertStyle = .informational
                    alert.addButton(withTitle: "Show in Finder")
                    alert.addButton(withTitle: "OK")
                    
                    let choice = alert.runModal()
                    if choice == .alertFirstButtonReturn {
                        // Open Finder and highlight the newly created PDF file
                        NSWorkspace.shared.activateFileViewerSelecting([url])
                    }
                }
            }
        }
    }
}
