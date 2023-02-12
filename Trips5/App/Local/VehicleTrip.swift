//
//  VehicleTrip.swift
//  Trips5
//
//  Created by Rob Goble on 9/17/22.
//

import Foundation
import GRDB

struct VehicleTrip: Identifiable, Decodable, FetchableRecord {
    var id: String {
        return trip.id
    }
    var date: Date {
        guard let d = Formatter.shared.noTimeFormatter.date(from: trip.date) else { fatalError() }
        return d
    }
    var vehicle: Vehicle
    var trip: Trip
    
    static func new(_ vehicle: Vehicle) -> VehicleTrip {
        return VehicleTrip(vehicle: vehicle, trip: Trip.new(for: vehicle))
    }
}

extension VehicleTrip: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
