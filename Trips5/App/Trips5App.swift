//
//  Trips5App.swift
//  Trips5
//
//  Created by Rob Goble on 8/11/22.
//

import SwiftUI

@main
struct Trips5App: App {
    @Environment(\.dependencies) var dependencies
    @Environment(\.scenePhase) var scenePhase
    
    var body: some Scene {
        WindowGroup {
            NavView()
                .environmentObject(dependencies.vehicleStore)
                .task {
                    await dependencies.syncManager.sync()
                }
        }.onChange(of: scenePhase) { phase in
            if phase == .background {
                dependencies.database.releaseMemory()
            }
        }
    }
}
