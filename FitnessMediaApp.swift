//
//  FitnessMediaApp.swift
//  FitnessMedia
//
//  Created by Sharik Mahmood on 2/13/24.
//

import SwiftUI
import SwiftData

@main
struct FitnessMediaApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            //Item.self,
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
            ContentView()
        }
        .modelContainer(sharedModelContainer)
    }
}
