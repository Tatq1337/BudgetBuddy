//
//  coredataApp.swift
//  coredata
//
//  Created by Kamil Glac on 24/04/2023.
//

import SwiftUI

@main
struct coredataApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
