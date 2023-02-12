//
//  Vehicle.swift
//  Trips5
//
//  Created by Rob Goble on 8/14/22.
//

import Foundation
import GRDB

struct Vehicle: Codable, Identifiable {
    var id: String
    var name: String {
        didSet {
            if name != oldValue {
                dirty = true
            }
        }
    }
    var modified: Date
    var dirty: Bool
    
    static func new() -> Vehicle {
        let now = Date()
        return Vehicle(id: UUID().uuidString,
                       name: "New Vehicle",
                       modified: now,
                       dirty: true)
    }
}

extension Vehicle: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

// MARK: GRDB Conformance

extension Vehicle: TableRecord {
    enum Columns {
        static let id = Column(CodingKeys.id)
        static let name = Column(CodingKeys.name)
        static let modified = Column(CodingKeys.modified)
        static let dirty = Column(CodingKeys.dirty)
    }
}

extension Vehicle: FetchableRecord { }
extension Vehicle: PersistableRecord { }

extension Vehicle {
    static let fuels = hasMany(Fuel.self)
    static let trips = hasMany(Trip.self)
    
    var fuels: QueryInterfaceRequest<Fuel> {
        request(for: Vehicle.fuels)
    }
    
    var trips: QueryInterfaceRequest<Trip> {
        request(for: Vehicle.trips)
    }
}
