//
//  FuelCellView.swift
//  Trips5
//
//  Created by Rob Goble on 2/12/23.
//

import SwiftUI

struct FuelCellView: View {
    typealias Dependencies = DatabaseProvider & EnvProvider & FormatterProvider & VehicleStoreProvider
    
    @Binding
    var fuelToEdit: VehicleFuel?
    
    var vehicleFuel: VehicleFuel
    
    private let env: Env
    private let formatter: Formatter
    
    init(_ dependencies: Dependencies, fuelToEdit: Binding<VehicleFuel?>, vehicleFuel: VehicleFuel) {
        self.env = dependencies.env
        self.formatter = dependencies.formatter
        self._fuelToEdit = fuelToEdit
        self.vehicleFuel = vehicleFuel
    }
    
    var body: some View {
        Button(action: {
            fuelToEdit = vehicleFuel
        }, label: {
            ListDataCell(
                leftText: formatter.dayMonthOnly.string(from: vehicleFuel.date),
                rightTopText: formatter.round2Str(vehicleFuel.fuel.mpg),
                rightBottomText: "\(vehicleFuel.fuel.toOdo)",
                showSyncIcon: vehicleFuel.fuel.dirty && env.host != .none)
        })
        .listRowInsets(Constants.listInsets)
    }
}
