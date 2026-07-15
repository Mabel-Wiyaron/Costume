//
//  CVHTMLCompiler.swift
//  Costume
//
//  Created by William Constantine Jioe on 14/07/26.
//

import Foundation

struct CVHTMLCompiler {
    
    /// Main compilation entry point that maps structural data directly into an ATS-safe HTML template.
    static func compile(document: CVDocument) -> String {
        let profile = document.profile
        
        // 1. Compile child sections into valid HTML strings
        let contactInfoHTML = compileContactInfo(profile)
        let skillsTableHTML = compileSkillsBlock(profile)
        let experienceHTML = compileExperiences(profile.experiences)
        let educationHTML = compileEducation(profile.educations)
        let projectsHTML = compileProjects(profile.projects)
        
        // 2. Inject dynamic snippets directly into your exact HTML template
        return """
        <!DOCTYPE html>
        <html lang="en">
        <head>
            <meta charset="UTF-8">
            <meta name="viewport" content="width=device-width, initial-scale=1.0">
            <title>Resume Template</title>
            <style>
                * {
                    box-sizing: border-box;
                    margin: 0;
                    padding: 0;
                }

                body {
                    font-family: Arial, Helvetica, sans-serif;
                    color: #111111;
                    line-height: 1.5;
                    padding: 40px;
                    max-width: 800px;
                    margin: 0 auto;
                    font-size: 13px;
                }

                /* Header Styles */
                header {
                    text-align: center;
                    margin-bottom: 20px;
                }

                header h1 {
                    font-size: 26px;
                    text-transform: uppercase;
                    letter-spacing: 0.5px;
                    margin-bottom: 6px;
                    font-weight: 700;
                }

                .contact-info {
                    font-size: 11px;
                    color: #333333;
                }

                .contact-info a {
                    color: #111111;
                    text-decoration: none;
                }

                /* Section Styles */
                section {
                    margin-top: 20px;
                }

                h2.section-title {
                    font-size: 14px;
                    text-transform: uppercase;
                    border-bottom: 1px solid #111111;
                    padding-bottom: 2px;
                    margin-bottom: 10px;
                    letter-spacing: 0.5px;
                    font-weight: 700;
                }

                .summary-text {
                    text-align: justify;
                    margin-bottom: 10px;
                }

                /* Clean Structural Entry Block Layout (ATS Safe Hierarchy) */
                .entry {
                    margin-bottom: 15px;
                }

                .entry-main-line {
                    font-size: 13px;
                    margin-bottom: 2px;
                }

                .entry-sub-line {
                    font-size: 12px;
                    margin-bottom: 4px;
                }

                .title, .company, .institution, .project-title {
                    font-weight: bold;
                }

                .date, .location {
                    font-weight: normal;
                    color: #333333;
                }

                /* Lists */
                ul {
                    margin-left: 20px;
                    margin-bottom: 8px;
                }

                li {
                    margin-bottom: 4px;
                    text-align: justify;
                }

                /* Projects Specific */
                .project-role {
                    font-style: italic;
                    margin-bottom: 4px;
                }

                /* Skills & Awards List Format (Replaced Table for ATS Safety) */
                .skills-entry {
                    margin-bottom: 6px;
                    line-height: 1.4;
                }

                .skills-label {
                    font-weight: bold;
                }
            </style>
        </head>
        <body>

            <!-- HEADER -->
            <header>
                <h1>\(sanitize(profile.name))</h1>
                <div class="contact-info">
                    \(contactInfoHTML)
                </div>
            </header>

            <!-- SUMMARY -->
            \((profile.summary ?? "").isEmpty ? "" : """
            <section>
                <h2 class="section-title">Summary</h2>
                <p class="summary-text">
                    \(sanitize(profile.summary ?? ""))
                </p>
            </section>
            """)

            <!-- CORE SKILLS & AWARDS (Moved Up for ATS Strategy) -->
            \(skillsTableHTML.isEmpty ? "" : """
            <section>
                <h2 class="section-title">Skills & Awards</h2>
                <div class="skills-container">
                    \(skillsTableHTML)
                </div>
            </section>
            """)

            <!-- EXPERIENCE -->
            \(experienceHTML.isEmpty ? "" : """
            <section>
                <h2 class="section-title">Experience</h2>
                \(experienceHTML)
            </section>
            """)

            <!-- EDUCATION -->
            \(educationHTML.isEmpty ? "" : """
            <section>
                <h2 class="section-title">Education</h2>
                \(educationHTML)
            </section>
            """)

            <!-- PROJECTS -->
            \(projectsHTML.isEmpty ? "" : """
            <section>
                <h2 class="section-title">Projects</h2>
                \(projectsHTML)
            </section>
            """)

        </body>
        </html>
        """
    }
    
    // MARK: - Sub-element Compilers
    
    private static func compileContactInfo(_ profile: Profile) -> String {
        var elements: [String] = []
        
        if !profile.email.isEmpty {
            elements.append("<a href=\"mailto:\(profile.email)\">\(sanitize(profile.email))</a>")
        }
        if !profile.phone.isEmpty {
            elements.append(sanitize(profile.phone))
        }
        if !profile.location.isEmpty {
            elements.append(sanitize(profile.location))
        }
        
        if let linkedin = profile.linkedin {
            elements.append("<a href=\"\(linkedin.absoluteString)\">LinkedIn</a>")
        }
        if let website = profile.website {
            elements.append("<a href=\"\(website.absoluteString)\">Website</a>")
        }
        
        for link in profile.links {
            elements.append("<a href=\"\(link.url.absoluteString)\">\(sanitize(link.platform))</a>")
        }
        
        // Plain separator text instead of distinct structural styling span tags
        return elements.joined(separator: " | ")
    }
    
    private static func compileExperiences(_ experiences: [Experience]) -> String {
        return experiences.map { exp in
            let bullets = exp.descriptionText.map { "<li>\(sanitize($0))</li>" }.joined()
            let durationString = formatDateRange(start: exp.startDate, end: exp.endDate)
            
            // Replaced flex wrappers with linear top-down block elements to assist system readers
            return """
            <div class="entry">
                <div class="entry-main-line">
                    <span class="title">\(sanitize(exp.role))</span> &mdash; <span class="date">\(durationString)</span>
                </div>
                <div class="entry-sub-line">
                    <span class="company">\(sanitize(exp.company))</span> &middot; <span class="location">\(sanitize(exp.location))</span>
                </div>
                <ul>\(bullets)</ul>
            </div>
            """
        }.joined()
    }
    
    private static func compileEducation(_ educations: [Education]) -> String {
        return educations.map { edu in
            let durationString = formatDateRange(start: edu.startDate, end: edu.endDate)
            let fieldInfo = edu.fieldOfStudy.isEmpty ? "" : " in \(sanitize(edu.fieldOfStudy))"
            
            return """
            <div class="entry">
                <div class="entry-main-line">
                    <span class="institution">\(sanitize(edu.school))</span> &mdash; <span class="date">\(durationString)</span>
                </div>
                <div class="entry-sub-line">
                    <span>\(sanitize(edu.degree))\(fieldInfo)</span>
                </div>
            </div>
            """
        }.joined()
    }
    
    private static func compileProjects(_ projects: [Project]) -> String {
        return projects.map { proj in
            let bullets = proj.descriptionText.map { "<li>\(sanitize($0))</li>" }.joined()
            let dateString = formatDate(proj.startDate)
            
            return """
            <div class="entry">
                <div class="entry-main-line">
                    <span class="project-title">\(sanitize(proj.name))</span> &mdash; <span class="date">\(dateString)</span>
                </div>
                <div class="project-role">\(sanitize(proj.role))</div>
                <ul>\(bullets)</ul>
            </div>
            """
        }.joined()
    }
    
    private static func compileSkillsBlock(_ profile: Profile) -> String {
        var blocks: [String] = []
        
        // 1. Technical Skills
        if !profile.skills.isEmpty {
            let skillNames = profile.skills.map { sanitize($0.name) }.joined(separator: ", ")
            blocks.append("<div class=\"skills-entry\"><span class=\"skills-label\">Technical Skills:</span> \(skillNames)</div>")
        }
        
        // 2. Languages
        if !profile.languages.isEmpty {
            let langDetails = profile.languages.map { sanitize("\($0.name) (\($0.proficiency))") }.joined(separator: ", ")
            blocks.append("<div class=\"skills-entry\"><span class=\"skills-label\">Languages:</span> \(langDetails)</div>")
        }
        
        // 3. Certifications
        if !profile.certifications.isEmpty {
            let certNames = profile.certifications.map { cert in
                sanitize("\(cert.name) (\(cert.issuer))")
            }.joined(separator: ", ")
            blocks.append("<div class=\"skills-entry\"><span class=\"skills-label\">Certifications:</span> \(certNames)</div>")
        }
        
        // 4. Awards
        if !profile.awards.isEmpty {
            let awardNames = profile.awards.map { sanitize("\($0.title) via \($0.issuer)") }.joined(separator: ", ")
            blocks.append("<div class=\"skills-entry\"><span class=\"skills-label\">Awards:</span> \(awardNames)</div>")
        }
        
        return blocks.joined()
    }
    
    // MARK: - Date Formatting Helpers
    
    private static func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM yyyy"
        return formatter.string(from: date)
    }
    
    private static func formatDateRange(start: Date, end: Date?) -> String {
        let startStr = formatDate(start)
        if let end = end {
            return "\(startStr) — \(formatDate(end))"
        } else {
            return "\(startStr) — Present"
        }
    }
    
    // MARK: - Safety Sanitizer
    
    private static func sanitize(_ string: String) -> String {
        var text = string
        text = text.replacingOccurrences(of: "&", with: "&amp;")
        text = text.replacingOccurrences(of: "<", with: "&lt;")
        text = text.replacingOccurrences(of: ">", with: "&gt;")
        text = text.replacingOccurrences(of: "\"", with: "&quot;")
        text = text.replacingOccurrences(of: "'", with: "&#x27;")
        return text
    }
}
