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
                ForEach(tripsViewModel.tripSections, id: \.self) { tripSection in
                    Section(tripSection.description) {
                        ForEach(tripSection.trips, id: \.self) { vehicleTrip in
                            Button(action: {
                                tripToEdit = vehicleTrip
                            }, label: {
                                HStack {
                                    Text(formatter.dayMonthOnly.string(from: vehicleTrip.date))
                                        .foregroundColor(Color(uiColor: UIColor.label))
                                    Spacer()
                                    VStack(alignment: .trailing, spacing: 4) {
                                        Text("\(vehicleTrip.trip.distance)").font(Font.footnote)
                                            .foregroundColor(Color(uiColor: UIColor.label))
                                        Text("\(vehicleTrip.trip.toOdo)").font(Font.footnote)
                                            .foregroundColor(Color(uiColor: UIColor.label))
                                    }
                                    if vehicleTrip.trip.dirty && env.host != .none {
                                        Image(systemName: "arrow.triangle.2.circlepath").foregroundColor(Color.blue)
                                    }
                                }
                            })
                            .listRowInsets(Constants.listInsets)
                            .onAppear {
                                tripsViewModel.itemAppeared(vehicleTrip)
                            }
                            .sheet(item: $tripToEdit) { detail in
                                if let tripToEdit = detail {
                                    let vm = TripFormViewModel(dependencies, vehicleTrip: tripToEdit)
                                    TripFormView(viewModel: vm)
                                }
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
                            let trip = Trip.new(for: actVeh, withPrevTOdo: tripsViewModel.allTrips.first?.trip.toOdo ?? 0)
                            tripToEdit = VehicleTrip(vehicle: actVeh, trip: trip)
                        }
                    }, label: {
                        Image(systemName: "plus")
                    })
                    .accessibilityIdentifier("tripAddButton")
                    .accessibilityLabel("Add Trip")
                    .sheet(item: $tripToEdit) { detail in
                        if let tripToEdit = detail {
                            let vm = TripFormViewModel(dependencies, vehicleTrip: tripToEdit)
                            TripFormView(viewModel: vm)
                        }
                    }
                    .disabled(vehicleStore.active == nil)
                }
            }
        }
    }
}
