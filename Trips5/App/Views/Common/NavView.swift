//
//  NavView.swift
//  Trips5
//
//  Created by Rob Goble on 8/13/22.
//

import SwiftUI

struct NavView: View {
    @Environment(\.dependencies)
    var dependencies
    
    @EnvironmentObject
    var vehicleStore: VehicleStore
    
    var body: some View {
        TabView {
            if vehicleStore.active == nil {
                NoDataView()
                    .tabItem {
                        Label("Home", systemImage: "chart.pie")
                    }
                SettingsView()
                    .environmentObject(dependencies.vehicleStore)
                    .environmentObject(dependencies.env)
                    .tabItem {
                        Label("Settings", systemImage: "gear")
                    }
            }
            else {
                DashboardView(dependencies)
                    .environmentObject(dependencies.vehicleStore)
                    .tabItem {
                        Label("Home", systemImage: "chart.pie")
                    }
                TripsView(dependencies)
                    .tabItem {
                        Label("Trips", systemImage: "map")
                    }
                FuelsView(dependencies)
                    .tabItem {
                        Label("Fuels", systemImage: "fuelpump")
                    }
                SettingsView()
                    .environmentObject(dependencies.env)
                    .tabItem {
                        Label("Settings", systemImage: "gear")
                    }
            }
        }
    }
}
