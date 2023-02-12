//
//  TripStore.swift
//  Trips5
//
//  Created by Rob Goble on 9/17/22.
//

import Foundation
import GRDB

class TripStore {
    typealias Dependencies = DatabaseProvider & SyncProvider & VehicleStoreProvider
    
    private let trips5Store = RemoteStore<Trips5Trip>()
    private let db: Database
    private let syncManager: SyncManager
    private let vehicleStore: VehicleStore
    
    @MainActor
    var latestOdometer: Int {
        guard let activeVeh = vehicleStore.active else { return 0 }
        
        var value = 0
        
        do {
            let trip = try db.pool.read { db in
                return try activeVeh.trips
                    .including(required: Trip.vehicle)
                    .order(Column("toOdo").desc)
                    .fetchOne(db)
            }
            
            value = trip?.toOdo ?? 0
        } catch {
            print(error.localizedDescription)
        }
        
        return value
    }
    
    init(_ dependencies: Dependencies) {
        self.db = dependencies.database
        self.syncManager = dependencies.syncManager
        self.vehicleStore = dependencies.vehicleStore
    }
    
    func upsert(_ vehicleTrip: VehicleTrip) async {
        do {
            try await db.pool.write { db in
                var trip = vehicleTrip.trip

                if trip.dirty {
                    trip.modified = Date()
                }

                try trip.save(db)
            }
            
            await syncManager.sync()
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func delete(_ vehicleTrip: VehicleTrip) async {
        do {
            try await db.pool.write { db in
                let deleted = Deleted(id: vehicleTrip.trip.id, record: .trip, deleted: Date())
                try deleted.save(db)
                try vehicleTrip.trip.delete(db)
            }
            
            await syncManager.sync()
        } catch {
            print(error.localizedDescription)
        }
    }
}
