//
//  Trips5Vehicle.swift
//  Trips5
//
//  Created by Rob Goble on 8/31/22.
//

import Foundation

struct Trips5Vehicle: Codable, Identifiable {
    var id: String
    var name: String
    var modified: Date
    
    func asCanonical(setDirty dirty: Bool = false) -> Vehicle {
        return Vehicle(id: id,
                       name: name,
                       modified: modified,
                       dirty: dirty)
    }
    
    static func fromCanonical(vehicle: Vehicle) -> Trips5Vehicle {
        return Trips5Vehicle(id: vehicle.id,
                             name: vehicle.name,
                             modified: vehicle.modified)
    }
}

extension Trips5Vehicle: URLPathProviding {
    static func url(for requestType: RequestType) -> URL? {
        switch requestType {
        case .getAll: return Env.shared.host.base?.appendingPathComponent("/trips5demo/vehicles")
        case .post: return Env.shared.host.base?.appendingPathComponent("/trips5demo/vehicle")
        default: return nil
        }
    }
}
