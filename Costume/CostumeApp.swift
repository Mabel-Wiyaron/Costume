//
//  CostumeApp.swift
//  Costume
//
//  Created by Saujana Shafi on 09/07/26.
//

import SwiftUI
import SwiftData

@main
struct CostumeApp: App {
    var sharedModelContainer: ModelContainer = {
        // We register all your actual schema entities here, removing 'Item.self'
        let schema = Schema([
            Profile.self,
            ProfileLink.self,
            Experience.self,
            Education.self,
            Certification.self,
            Project.self,
            Award.self,
            Language.self,
            Skill.self,
            JobDescription.self,
            Keyword.self
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            // Hint: If you change schemas often during testing, you might need to delete
            // the app from your simulator to clear out old schema caches if this crashes.
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(sharedModelContainer)
    }
}
