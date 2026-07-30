//
//  CostumeApp.swift
//  Costume
//
//  Created by Saujana Shafi on 09/07/26.
//

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
        // -------------------------------------------------------------
        // UNCOMMENT THE LINE BELOW TO WIPE THE ENTIRE SWIFTDATA STORE:
//         CostumeApp.resetSwiftDataStore()
        // -------------------------------------------------------------

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
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            DashboardView()
        }
        .modelContainer(sharedModelContainer)
    }

    /// Deletes default SwiftData SQLite backing store files from Application Support
    static func resetSwiftDataStore() {
        let fileManager = FileManager.default
        let appSupport = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        
        // SwiftData creates three files for the SQLite database (.store, -shm, -wal)
        let storeURL = appSupport.appendingPathComponent("default.store")
        let shmURL = appSupport.appendingPathComponent("default.store-shm")
        let walURL = appSupport.appendingPathComponent("default.store-wal")

        try? fileManager.removeItem(at: storeURL)
        try? fileManager.removeItem(at: shmURL)
        try? fileManager.removeItem(at: walURL)
        
        print("🗑️ SwiftData database completely wiped.")
    }
}
