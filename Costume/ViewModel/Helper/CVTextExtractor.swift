//
//  CVTextExtractor.swift
//  Costume
//
//  Created by William Constantine Jioe on 24/07/26.
//

import Foundation
import PDFKit
import Vision
#if canImport(AppKit)
import AppKit
#endif

final class CVTextExtractor {
    
    /// Extracts raw text from a PDF file URL.
    /// Uses PDFKit first; falls back to Vision OCR if the PDF contains scanned images instead of vector text.
    static func extractText(from url: URL) async throws -> String {
        guard let pdfDocument = PDFDocument(url: url) else {
            throw NSError(domain: "CVTextExtractor", code: 1, userInfo: [NSLocalizedDescriptionKey: "Failed to open PDF document."])
        }
        
        // 1. Primary: Fast PDFKit Text Extraction
        var fullText = ""
        let pageCount = pdfDocument.pageCount
        
        for i in 0..<pageCount {
            if let page = pdfDocument.page(at: i), let pageText = page.string {
                fullText += pageText + "\n"
            }
        }
        
        let trimmedText = fullText.trimmingCharacters(in: .whitespacesAndNewlines)
        if !trimmedText.isEmpty {
            return sanitizeCVText(trimmedText)
        }
        
        // 2. Fallback: Vision OCR (for scanned PDFs)
        return try await performVisionOCR(on: pdfDocument)
    }
    
    private static func performVisionOCR(on document: PDFDocument) async throws -> String {
        var recognizedText = ""
        
        for i in 0..<document.pageCount {
            guard let page = document.page(at: i) else { continue }
            
            let pageBounds = page.bounds(for: .mediaBox)
            let image = NSImage(size: pageBounds.size)
            
            image.lockFocus()
            if let context = NSGraphicsContext.current?.cgContext {
                page.draw(with: .mediaBox, to: context)
            }
            image.unlockFocus()
            
            guard let cgImage = image.cgImage(forProposedRect: nil, context: nil, hints: nil) else {
                continue
            }
            
            let pageOCRText = try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<String, Error>) in
                let request = VNRecognizeTextRequest { request, error in
                    if let error = error {
                        continuation.resume(throwing: error)
                        return
                    }
                    
                    guard let observations = request.results as? [VNRecognizedTextObservation] else {
                        continuation.resume(returning: "")
                        return
                    }
                    
                    let pageText = observations
                        .compactMap { $0.topCandidates(1).first?.string }
                        .joined(separator: "\n")
                    
                    continuation.resume(returning: pageText)
                }
                
                request.recognitionLevel = .accurate
                request.usesLanguageCorrection = true
                
                let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
                do {
                    try handler.perform([request])
                } catch {
                    continuation.resume(throwing: error)
                }
            }
            
            recognizedText += pageOCRText + "\n"
        }
        
        return recognizedText
    }
}

func sanitizeCVText(_ text: String) -> String {
    var cleaned = text
    
    // 1. Collapse multiple line breaks into single newlines
    cleaned = cleaned.replacingOccurrences(of: #"\n\s*\n+"#, with: "\n", options: .regularExpression)
    
    // 2. Collapse horizontal multi-spaces into single spaces
    cleaned = cleaned.replacingOccurrences(of: #"[ \t]+"#, with: " ", options: .regularExpression)
    
    // 3. Remove common low-signal characters (bullet dots, special decorative symbols)
    cleaned = cleaned.replacingOccurrences(of: #"[•|▪|‣|◦|●|★|–|—]"#, with: "-", options: .regularExpression)
    
    return cleaned.trimmingCharacters(in: .whitespacesAndNewlines)
}
