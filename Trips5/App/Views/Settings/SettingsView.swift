//
//  SettingsView.swift
//  Trips5
//
//  Created by Rob Goble on 8/13/22.
//

import SwiftUI

struct SettingsView: View {
    @Environment(\.dependencies)
    var dependencies
    
    @EnvironmentObject
    var env: Env
    
    @EnvironmentObject
    var vehicleStore: VehicleStore
    
    @State
    private var presentedNumbers = NavigationPath()
    
    var body: some View {
        NavigationStack(path: $presentedNumbers) {
            List {
                Section("About") {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text("\(Constants.versionBuild)")
                    }
                    HStack {
                        Text("Built")
                        Spacer()
                        Text("\(dependencies.formatter.fullDateFormatter.string(from: Constants.buildDate))")
                    }
                }
                Section("Active Vehicle") {
                    if vehicleStore.all.count == 0 {
                        Text("No Vehicles")
                    } else {
                        Menu(vehicleStore.active?.name ?? "Select...") {
                            ForEach(vehicleStore.all, id: \.self) { vehicle in
                                Button(vehicle.name, action: {
                                    vehicleStore.setActiveVehicle(to: vehicle)
                                })
                            }
                        }
                    }
                }
                Section("Manage") {
                    NavigationLink(destination: {
                        VehicleListView()
                    }, label: {
                        Label("Vehicles", systemImage: "car.2")
                    })
                }
                Section("Export") {
                    ShareLink("Export Local Data", item: dependencies.database.location)
                    Button(action: {
                        Task {
                            await dependencies.syncManager.sync()
                        }
                    }, label: {
                        Label("Force Sync", systemImage: "arrow.triangle.2.circlepath")
                    })
                    .disabled(env.host == .none)
                }
                Section("Sync Environment") {
                    Menu(env.host.rawValue) {
                        ForEach(Host.allCases, id: \.self) { host in
                            Button(host.rawValue, action: {
                                dependencies.syncManager.clearSyncTimestamp()
                                env.setEnv(to: host)
                            })
                        }
                    }
                }
                Section("Danger") {
                    Button(action: {
                        Task {
                            await dependencies.syncManager.markAllDirty()
                        }
                    }, label: {
                        Label("Mark All Dirty", systemImage: "pencil.line")
                    })
                    Button(action: {
                        Task {
                            await dependencies.database.deleteAll()
                        }
                    }, label: {
                        Label("Delete All", systemImage: "minus.circle")
                    })
                }
            }.navigationTitle("Settings").navigationBarTitleDisplayMode(.inline)
        }
    }
}
