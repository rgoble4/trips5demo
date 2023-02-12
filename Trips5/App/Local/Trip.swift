//
//  Trip.swift
//  Trips5
//
//  Created by Rob Goble on 9/17/22.
//

import Foundation
import GRDB

struct Trip: Codable, Identifiable {
    var id: String
    var vehicleId: String
    var date: String {
        didSet {
            if date != oldValue {
                dirty = true
            }
        }
    }
    var fromOdo: Int {
        didSet {
            if fromOdo != oldValue {
                dirty = true
                distance = toOdo - fromOdo
            }
        }
    }
    var toOdo: Int {
        didSet {
            if toOdo != oldValue {
                dirty = true
                distance = toOdo - fromOdo
            }
        }
    }
    var distance: Int
    var modified: Date
    var dirty: Bool
    
    
    static func new(for vehicle: Vehicle, withPrevTOdo prevToOdo: Int = 0) -> Trip {
        let now = Date()
        
        let nowStr = Formatter.shared.noTimeFormatter.string(from: now)
        
        return Trip(id: UUID().uuidString,
                    vehicleId: vehicle.id,
                    date: nowStr,
                    fromOdo: prevToOdo,
                    toOdo: 0,
                    distance: 0,
                    modified: now,
                    dirty: true)
    }
}

extension Trip: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

// MARK: GRDB Conformance

extension Trip: TableRecord {
    enum Columns {
        static let id = Column(CodingKeys.id)
        static let vehicleId = Column(CodingKeys.vehicleId)
        static let date = Column(CodingKeys.date)
        static let fromOdo = Column(CodingKeys.fromOdo)
        static let toOdo = Column(CodingKeys.toOdo)
        static let distance = Column(CodingKeys.distance)
        static let modified = Column(CodingKeys.modified)
        static let dirty = Column(CodingKeys.dirty)
    }
}

extension Trip: FetchableRecord { }
extension Trip: PersistableRecord { }

extension Trip {
    static let vehicle = belongsTo(Vehicle.self)
    var vehicle: QueryInterfaceRequest<Vehicle> {
        request(for: Trip.vehicle)
    }
}
