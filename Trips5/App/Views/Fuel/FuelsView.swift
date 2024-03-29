//
//  FuelsView.swift
//  Trips5
//
//  Created by Rob Goble on 8/13/22.
//

import SwiftUI

struct FuelsView: View {
    typealias Dependencies = DatabaseProvider & EnvProvider & FormatterProvider & VehicleStoreProvider
    
    @ObservedObject
    private var fuelsViewModel: FuelsViewModel
    
    @State
    private var presentedNumbers = NavigationPath()
    
    @State
    private var fuelToEdit: VehicleFuel?
    
    private let dependencies: Dependencies
    private let env: Env
    private let formatter: Formatter
    private let vehicleStore: VehicleStore
    
    init(_ dependencies: Dependencies) {
        fuelsViewModel = FuelsViewModel(dependencies)
        self.dependencies = dependencies
        self.env = dependencies.env
        self.formatter = dependencies.formatter
        self.vehicleStore = dependencies.vehicleStore
    }
    
    var body: some View {
        NavigationStack(path: $presentedNumbers) {
            List {
                ForEach(fuelsViewModel.sections, id: \.self) { fuelSection in
                    Section(fuelSection.description) {
                        ForEach(fuelSection.items, id: \.self) { vehicleFuel in
                            FuelCellView(dependencies, fuelToEdit: $fuelToEdit, vehicleFuel: vehicleFuel)
                            .onAppear {
                                fuelsViewModel.itemAppeared(vehicleFuel)
                            }
                            .sheet(item: $fuelToEdit) { fuelToEdit in
                                let vm = FuelFormViewModel(dependencies, vehicleFuel: fuelToEdit)
                                FuelFormView(viewModel: vm)
                            }
                        }
                    }
                }
            }
            .onAppear {
                Task {
                    await fuelsViewModel.start()
                }
            }
            .navigationTitle("Fuel Entries").navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        if let actVeh = vehicleStore.active {
                            let fuel = Fuel.new(for: actVeh, withPrevTOdo: fuelsViewModel.all.first?.fuel.toOdo ?? 0)
                            fuelToEdit = VehicleFuel(vehicle: actVeh, fuel: fuel)
                        }
                    }, label: {
                        Image(systemName: "plus")
                    })
                    .accessibilityIdentifier("fuelAddButton")
                    .accessibilityLabel("Add Fuel")
                    .sheet(item: $fuelToEdit) { fuelToEdit in
                        let vm = FuelFormViewModel(dependencies, vehicleFuel: fuelToEdit)
                        FuelFormView(viewModel: vm)
                    }
                    .disabled(vehicleStore.active == nil)
                }
            }
        }
    }
}
