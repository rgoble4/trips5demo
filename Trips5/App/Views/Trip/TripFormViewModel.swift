//
//  TripFormViewModel.swift
//  Trips5
//
//  Created by Rob Goble on 9/17/22.
//

import Foundation

class TripFormViewModel: ObservableObject {
    typealias Dependencies = FormatterProvider
    
    var vehicleTrip: VehicleTrip
    
    @Published
    var date: Date = Date()
    
    @Published
    var fromOdo: String = ""
    
    @Published
    var toOdo: String = ""
    
    var canSave: Bool {
        guard let fOdo = Int(fromOdo),
              let tOdo = Int(toOdo),
              tOdo > fOdo else { return false }
        return true
    }
    
    var distance: Int {
        guard let fO = Int(fromOdo),
              let tO = Int(toOdo) else { return 0 }
        return tO - fO
    }
    
    var asVehicleTrip: VehicleTrip {
        guard let tripDate = date.withoutTime(),
              let fOdo = Int(fromOdo),
              let tOdo = Int(toOdo) else { fatalError() }
        
        let tDateStr = formatter.noTimeFormatter.string(from: tripDate)
        
        vehicleTrip.trip.date = tDateStr
        vehicleTrip.trip.fromOdo = fOdo
        vehicleTrip.trip.toOdo = tOdo
        vehicleTrip.trip.distance = distance

        return vehicleTrip
    }
    
    private let formatter: Formatter
    
    init(_ dependencies: Dependencies, vehicleTrip: VehicleTrip) {
        self.vehicleTrip = vehicleTrip
        formatter = dependencies.formatter
        
        date = vehicleTrip.date
        fromOdo = String(vehicleTrip.trip.fromOdo)
        
        if vehicleTrip.trip.toOdo > 0 {
            toOdo = String(vehicleTrip.trip.toOdo)
        }
    }
}
