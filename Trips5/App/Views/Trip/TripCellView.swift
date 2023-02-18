//
//  TripCellView.swift
//  Trips5
//
//  Created by Rob Goble on 2/17/23.
//

import SwiftUI

struct TripCellView: View {
    typealias Dependencies = DatabaseProvider & EnvProvider & FormatterProvider & VehicleStoreProvider
    
    @Binding
    var tripToEdit: VehicleTrip?
    
    var vehicleTrip: VehicleTrip
    
    private let env: Env
    private let formatter: Formatter
    
    init(_ dependencies: Dependencies, tripToEdit: Binding<VehicleTrip?>, vehicleTrip: VehicleTrip) {
        self.env = dependencies.env
        self.formatter = dependencies.formatter
        self._tripToEdit = tripToEdit
        self.vehicleTrip = vehicleTrip
    }
    
    var body: some View {
        Button(action: {
            tripToEdit = vehicleTrip
        }, label: {
            ListDataCell(
                leftText: formatter.dayMonthOnly.string(from: vehicleTrip.date),
                rightTopText: "\(vehicleTrip.trip.distance)",
                rightBottomText: "\(vehicleTrip.trip.toOdo)",
                showSyncIcon: vehicleTrip.trip.dirty && env.host != .none)
        })
        .listRowInsets(Constants.listInsets)
    }
}
