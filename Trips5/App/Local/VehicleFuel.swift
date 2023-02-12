//
//  VehicleFuel.swift
//  Trips5
//
//  Created by Rob Goble on 9/7/22.
//

import Foundation
import GRDB

struct VehicleFuel: Identifiable, Decodable, FetchableRecord {
    var id: String {
        return fuel.id
    }
    var date: Date {
        guard let d = Formatter.shared.noTimeFormatter.date(from: fuel.date) else { fatalError() }
        return d
    }
    var vehicle: Vehicle
    var fuel: Fuel
    
    static func new(_ vehicle: Vehicle) -> VehicleFuel {
        return VehicleFuel(vehicle: vehicle, fuel: Fuel.new(for: vehicle))
    }
}

extension VehicleFuel: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
