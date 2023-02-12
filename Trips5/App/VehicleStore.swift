//
//  VehicleStore.swift
//  Trips5
//
//  Created by Rob Goble on 8/14/22.
//

import Combine
import Foundation
import GRDB

let ActiveVehicleKey = "ActiveVehicle"

actor VehicleStore: ObservableObject {
    typealias Dependencies = DatabaseProvider & SyncProvider
    
    @Published
    @MainActor
    var active: Vehicle?
    
    @Published
    @MainActor
    var all: [Vehicle] = []
    
    private let trips5Store = RemoteStore<Trips5Vehicle>()
    private let db: Database
    private let syncManager: SyncManager
    
    private var vehicleSub: AnyCancellable?
    
    init(_ dependencies: Dependencies) {
        self.db = dependencies.database
        self.syncManager = dependencies.syncManager
        
        Task {
            await subscribeToChanges()
        }
    }
    
    @MainActor
    func setVehicles(_ vehicles: [Vehicle]) {
        all = vehicles
    }
    
    @MainActor
    func setActiveVehicle(to vehicle: Vehicle) {
        UserDefaults.standard.set(vehicle.id, forKey: ActiveVehicleKey)
        active = vehicle
    }
    
    @MainActor
    func setActiveVehicle() {
        guard let activeId = UserDefaults.standard.string(forKey: ActiveVehicleKey) else {
            if let firstVeh = all.first {
                UserDefaults.standard.set(firstVeh.id, forKey: ActiveVehicleKey)
                active = firstVeh
            }
            return
        }
        
        if let match = all.first(where: { $0.id == activeId }) {
            active = match
        } else {
            // UUID No longer exists in db
            UserDefaults.standard.removeObject(forKey: ActiveVehicleKey)
            active = nil
        }
    }
    
    func upsert(_ vehicle: Vehicle) {
        Task {
            do {
                try await db.pool.write { db in
                    var veh = vehicle
                    
                    if veh.dirty {
                        veh.modified = Date()
                    }
                    
                    try veh.save(db)
                }
                
                await syncManager.sync()
            } catch {
                print(error.localizedDescription)
            }
        }
    }
    
    func delete(_ vehicle: Vehicle) {
        Task {
            do {
                try await db.pool.write { db in
                    let deleted = Deleted(id: vehicle.id, record: .vehicle, deleted: Date())
                    try deleted.save(db)
                    try vehicle.delete(db)
                }
                
                await syncManager.sync()
            } catch {
                print(error.localizedDescription)
            }
        }
    }
    
    private func subscribeToChanges() {
        vehicleSub = ValueObservation
            .tracking { db in try Vehicle.order(Column("name").desc).fetchAll(db) }
            .removeDuplicates()
            .publisher(in: db.pool)
            .sink(receiveCompletion: { print ("completion: \($0)") },
                  receiveValue: { [weak self] vehicles in
                guard let self else { return }
                
                Task {
                    await self.setVehicles(vehicles)
                    await self.setActiveVehicle()
                }
            })
    }
}
