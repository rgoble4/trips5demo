//
//  TripsView.swift
//  Trips5
//
//  Created by Rob Goble on 8/11/22.
//

import SwiftUI

struct TripsView: View {
    typealias Dependencies = DatabaseProvider & EnvProvider & FormatterProvider & VehicleStoreProvider
    
    @ObservedObject
    private var tripsViewModel: TripsViewModel
    
    @State
    private var presentedNumbers = NavigationPath()
    
    @State
    private var tripToEdit: VehicleTrip?
        
    private let dependencies: Dependencies
    private let env: Env
    private let formatter: Formatter
    private let vehicleStore: VehicleStore
    
    init(_ dependencies: Dependencies) {
        tripsViewModel = TripsViewModel(dependencies)
        self.dependencies = dependencies
        self.env = dependencies.env
        self.formatter = dependencies.formatter
        self.vehicleStore = dependencies.vehicleStore
    }
    
    var body: some View {
        NavigationStack(path: $presentedNumbers) {
            List {
                ForEach(tripsViewModel.sections, id: \.self) { tripSection in
                    Section(tripSection.description) {
                        ForEach(tripSection.items, id: \.self) { vehicleTrip in
                            TripCellView(dependencies, tripToEdit: $tripToEdit, vehicleTrip: vehicleTrip)
                            .onAppear {
                                tripsViewModel.itemAppeared(vehicleTrip)
                            }
                            .sheet(item: $tripToEdit) { tripToEdit in
                                let vm = TripFormViewModel(dependencies, vehicleTrip: tripToEdit)
                                TripFormView(viewModel: vm)
                            }
                        }
                    }
                }
            }
            .onAppear {
                Task {
                    await tripsViewModel.start()
                }
            }
            .navigationTitle("Trips").navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        if let actVeh = vehicleStore.active {
                            let trip = Trip.new(for: actVeh, withPrevTOdo: tripsViewModel.all.first?.trip.toOdo ?? 0)
                            tripToEdit = VehicleTrip(vehicle: actVeh, trip: trip)
                        }
                    }, label: {
                        Image(systemName: "plus")
                    })
                    .accessibilityIdentifier("tripAddButton")
                    .accessibilityLabel("Add Trip")
                    .sheet(item: $tripToEdit) { tripToEdit in
                        let vm = TripFormViewModel(dependencies, vehicleTrip: tripToEdit)
                        TripFormView(viewModel: vm)
                    }
                    .disabled(vehicleStore.active == nil)
                }
            }
        }
    }
}
