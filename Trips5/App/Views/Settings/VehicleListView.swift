//
//  VehicleListView.swift
//  Trips5
//
//  Created by Rob Goble on 8/14/22.
//

import SwiftUI

struct VehicleListView: View {
    
    @State
    private var vehicleToEdit: Vehicle?
    
    @EnvironmentObject
    var vehicleStore: VehicleStore
    
    @Environment(\.dependencies)
    var dependencies
    
    var body: some View {
        List {
            ForEach(vehicleStore.all, id: \.self) { vehicle in
                Button(action: {
                    vehicleToEdit = vehicle
                }, label: {
                    HStack {
                        Text(vehicle.name).foregroundColor(Color(uiColor: UIColor.label))
                        Spacer()
                        if vehicle.dirty && dependencies.env.host != .none {
                            Image(systemName: "arrow.triangle.2.circlepath").foregroundColor(Color.blue)
                        }
                    }
                })
                .listRowInsets(Constants.listInsets)
                .sheet(item: $vehicleToEdit, content: { detail in
                    if let veh = detail {
                        VehicleFormView(vehicle: veh)
                    }
                })
            }
        }
        .navigationTitle("Vehicles").navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    vehicleToEdit = Vehicle.new()
                }, label: {
                    Image(systemName: "plus")
                })
                .accessibilityIdentifier("vehicleAddButton")
                .accessibilityLabel("Add Vehicle")
                .sheet(item: $vehicleToEdit, content: { detail in
                    if let veh = detail {
                        VehicleFormView(vehicle: veh)
                    }
                })
            }
        }
    }
}
