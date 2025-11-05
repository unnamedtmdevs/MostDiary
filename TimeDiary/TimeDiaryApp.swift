//
//  TimeDiaryApp.swift
//  TimeDiary
//
//  Created by Дионисий Коневиченко on 05.11.2025.
//

import SwiftUI

@main
struct TimeDiaryApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
