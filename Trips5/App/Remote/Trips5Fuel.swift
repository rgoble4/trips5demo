//
//  Trips5Fuel.swift
//  Trips5
//
//  Created by Rob Goble on 9/15/22.
//

import Foundation

struct Trips5Fuel: Codable, Identifiable {
    var id: String
    var vehicleId: String
    var date: String
    var fOdo: Int
    var tOdo: Int
    var distance: Int
    var fuelAmt: Double
    var modified: Date
    
    func asCanonical(setDirty dirty: Bool = false) -> Fuel? {
        return Fuel(id: id,
                    vehicleId: vehicleId,
                    date: date,
                    fromOdo: fOdo,
                    toOdo: tOdo,
                    distance: distance,
                    fuelAmount: fuelAmt,
                    modified: modified,
                    dirty: dirty)
    }
    
    static func fromCanonical(fuel: Fuel) -> Trips5Fuel {
        return Trips5Fuel(id: fuel.id,
                          vehicleId: fuel.vehicleId,
                          date: fuel.date,
                          fOdo: fuel.fromOdo,
                          tOdo: fuel.toOdo,
                          distance: fuel.distance,
                          fuelAmt: fuel.fuelAmount,
                          modified: fuel.modified)
    }
}

extension Trips5Fuel: URLPathProviding {
    static func url(for requestType: RequestType) -> URL? {
        switch requestType {
        case .getAll: return Env.shared.host.base?.appendingPathComponent("/trips5demo/fuels")
        case .post: return Env.shared.host.base?.appendingPathComponent("/trips5demo/fuel")
        default: return nil
        }
    }
}
