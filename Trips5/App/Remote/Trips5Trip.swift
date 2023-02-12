//
//  Trips5Trip.swift
//  Trips5
//
//  Created by Rob Goble on 9/17/22.
//

import Foundation

struct Trips5Trip: Codable, Identifiable {
    var id: String
    var vehicleId: String
    var date: String
    var fOdo: Int
    var tOdo: Int
    var distance: Int
    var modified: Date
    
    func asCanonical(setDirty dirty: Bool = false) -> Trip? {
        return Trip(id: id,
                    vehicleId: vehicleId,
                    date: date,
                    fromOdo: fOdo,
                    toOdo: tOdo,
                    distance: distance,
                    modified: modified,
                    dirty: dirty)
    }
    
    static func fromCanonical(trip: Trip) -> Trips5Trip {
        return Trips5Trip(id: trip.id,
                          vehicleId: trip.vehicleId,
                          date: trip.date,
                          fOdo: trip.fromOdo,
                          tOdo: trip.toOdo,
                          distance: trip.distance,
                          modified: trip.modified)
    }
}

extension Trips5Trip: URLPathProviding {
    static func url(for requestType: RequestType) -> URL? {
        switch requestType {
        case .getAll: return Env.shared.host.base?.appendingPathComponent("/trips5demo/trips")
        case .post: return Env.shared.host.base?.appendingPathComponent("/trips5demo/trip")
        default: return nil
        }
    }
}
