//
//  FuelStore.swift
//  Trips5
//
//  Created by Rob Goble on 9/7/22.
//

import Foundation
import GRDB

class FuelStore {
    typealias Dependencies = DatabaseProvider & SyncProvider & VehicleStoreProvider
    
    private let trips5Store = RemoteStore<Trips5Fuel>()
    private let db: Database
    private let syncManager: SyncManager
    private let vehicleStore: VehicleStore
    
    @MainActor
    var latestOdometer: Int {
        guard let activeVeh = vehicleStore.active else { return 0 }
        
        var value = 0
        
        do {
            let fuel = try db.pool.read { db in
                return try activeVeh.fuels
                    .including(required: Fuel.vehicle)
                    .order(Column("toOdo").desc)
                    .fetchOne(db)
            }
            
            value = fuel?.toOdo ?? 0
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
    
    func upsert(_ vehicleFuel: VehicleFuel) async {
        do {
            try await db.pool.write { db in
                var fuel = vehicleFuel.fuel

                if fuel.dirty {
                    fuel.modified = Date()
                }

                try fuel.save(db)
            }
            
            await syncManager.sync()
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func delete(_ vehicleFuel: VehicleFuel) async {
        do {
            try await db.pool.write { db in
                let deleted = Deleted(id: vehicleFuel.fuel.id, record: .fuel, deleted: Date())
                try deleted.save(db)
                try vehicleFuel.fuel.delete(db)
            }
            
            await syncManager.sync()
        } catch {
            print(error.localizedDescription)
        }
    }
}
