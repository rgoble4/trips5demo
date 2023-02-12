//
//  ButtonBarView.swift
//  Trips5
//
//  Created by Rob Goble on 2/4/23.
//

import SwiftUI

struct ButtonBarView: View {
    typealias Dependencies =
        DatabaseProvider &
        FormatterProvider &
        FuelStoreProvider &
        TripStoreProvider
    
    @State
    private var fuelToEdit: VehicleFuel?
    
    @State
    private var tripToEdit: VehicleTrip?
    
    @EnvironmentObject
    private var vehicleStore: VehicleStore
    
    private let dependencies: Dependencies
    private let formatter: Formatter
    private let fuelStore: FuelStore
    private let tripStore: TripStore
    
    init(_ dependencies: Dependencies) {
        self.dependencies = dependencies
        self.formatter = dependencies.formatter
        self.fuelStore = dependencies.fuelStore
        self.tripStore = dependencies.tripStore
    }
    
    var body: some View {
        HStack(alignment: .center) {
            Button(action: {
                if let actVeh = vehicleStore.active {
                    let trip = Trip.new(for: actVeh, withPrevTOdo: tripStore.latestOdometer)
                    tripToEdit = VehicleTrip(vehicle: actVeh, trip: trip)
                }
            }, label: {
                Image(systemName: "plus")
                Text("Trip")
            }).sheet(item: $tripToEdit) { detail in
                if let tripToEdit = detail {
                    let vm = TripFormViewModel(dependencies, vehicleTrip: tripToEdit)
                    TripFormView(viewModel: vm)
                }
            }
            .accessibilityIdentifier("dashboardAddTripButton")
            .accessibilityLabel("Add Trip")
            .frame(maxWidth: .infinity)
            .disabled(vehicleStore.active == nil)
            
            Button(action: {
                if let actVeh = vehicleStore.active {
                    let fuel = Fuel.new(for: actVeh, withPrevTOdo: fuelStore.latestOdometer)
                    fuelToEdit = VehicleFuel(vehicle: actVeh, fuel: fuel)
                }
            }, label: {
                Image(systemName: "plus")
                Text("Fuel")
            }).sheet(item: $fuelToEdit) { detail in
                if let fuelToEdit = detail {
                    let vm = FuelFormViewModel(dependencies, vehicleFuel: fuelToEdit)
                    FuelFormView(viewModel: vm)
                }
            }
            .accessibilityIdentifier("dashboardAddFuelButton")
            .accessibilityLabel("Add Fuel")
            .frame(maxWidth: .infinity)
            .disabled(vehicleStore.active == nil)
        }
    }
}
