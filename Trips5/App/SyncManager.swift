//
//  SyncManager.swift
//  Trips5
//
//  Created by Rob Goble on 8/31/22.
//

import Combine
import Foundation
import GRDB
import UIKit

let dirtyColumn = Column("dirty")
let lastSyncDateKey = "LastSyncDate"

class SyncManager {
    typealias Dependencies = DatabaseProvider & EnvProvider
    
    private let dateFormatter: DateFormatter
    private let db: Database
    private let jsonDecoder: JSONDecoder
    private let trips5store = RemoteStore<SyncRequest>()
    
    private var environmentHostSubscription: AnyCancellable?
    private var shouldSync: Bool = false
    
    init(_ dependencies: Dependencies) {
        self.db = dependencies.database
        
        dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        
        jsonDecoder = JSONDecoder()
        jsonDecoder.keyDecodingStrategy = .convertFromSnakeCase
        jsonDecoder.dateDecodingStrategy = .formatted(dateFormatter)
        
        environmentHostSubscription = dependencies.env.$host.sink { [weak self] newHost in
            guard let self else { return }
            self.shouldSync = newHost != .none
        }
    }
    
    func sync() async {
        guard shouldSync else { return }
        
        do {
            guard let syncRequest = await buildSyncRequest(),
                  let (body, response) = try await trips5store.post(syncRequest) else { return }
            
            await processSyncResponse(body, response: response)
        } catch {
            print(error.localizedDescription)
            await ViewUtils.presentError(error)
        }
    }
    
    func markAllDirty() async {
        do {
            try await db.pool.write { db in
                try Vehicle.updateAll(db, dirtyColumn.set(to: true))
                try Fuel.updateAll(db, dirtyColumn.set(to: true))
                try Trip.updateAll(db, dirtyColumn.set(to: true))
            }
        } catch {
            print(error.localizedDescription)
            await ViewUtils.presentError(error)
        }
    }
    
    func clearSyncTimestamp() {
        UserDefaults.standard.set(nil, forKey: lastSyncDateKey)
    }
    
    private func buildSyncRequest() async -> SyncRequest? {
        do {
            return try await db.pool.read { db in
                let dirtyDeletes = try Deleted
                    .fetchAll(db)
                    .map { Trips5Delete.fromCanonical(deleted: $0)}
                
                let dirtyFuels = try Fuel
                    .filter(dirtyColumn == true)
                    .fetchAll(db)
                    .map { Trips5Fuel.fromCanonical(fuel: $0)}
                
                let dirtyTrips = try Trip
                    .filter(dirtyColumn == true)
                    .fetchAll(db)
                    .map { Trips5Trip.fromCanonical(trip: $0)}
                
                let dirtyVehicles = try Vehicle
                    .filter(dirtyColumn == true)
                    .fetchAll(db)
                    .map { Trips5Vehicle.fromCanonical(vehicle: $0)}
                
                var syncRequest = SyncRequest(deleted: dirtyDeletes,
                                              fuels: dirtyFuels,
                                              trips: dirtyTrips,
                                              vehicles: dirtyVehicles)
                
                if let lastSync = UserDefaults.standard.object(forKey: lastSyncDateKey) as? Date {
                    syncRequest.lastSync = lastSync
                }
                
                return syncRequest
            }
        } catch {
            print(error.localizedDescription)
            await ViewUtils.presentError(error)
        }
        
        return nil
    }
    
    private func processSyncResponse(_ body: Data, response: HTTPURLResponse) async {
        guard response.statusCode >= 200 && response.statusCode < 300 else { return }
        
        do {
            let syncResponse = try jsonDecoder.decode(SyncRequest.self, from: body)
            
            try await db.pool.write { db in
                guard syncResponse.isEmpty() == false else {
                    try Fuel.filter(dirtyColumn == true).updateAll(db, dirtyColumn.set(to: false))
                    try Trip.filter(dirtyColumn == true).updateAll(db, dirtyColumn.set(to: false))
                    try Vehicle.filter(dirtyColumn == true).updateAll(db, dirtyColumn.set(to: false))
                    try Deleted.deleteAll(db)
                    let newSync = Date()
                    UserDefaults.standard.set(newSync, forKey: lastSyncDateKey)
                    return
                }
                
                let fuels = syncResponse.fuels.map { $0.asCanonical() }
                let trips = syncResponse.trips.map { $0.asCanonical() }
                let vehicles = syncResponse.vehicles.map { $0.asCanonical() }
                let deletedRecords = syncResponse.deleted.map { $0.asCanonical() }
                let newSync = Date()
                
                for modifiedVehicle in vehicles {
                    try modifiedVehicle.save(db)
                }
                
                for modifiedFuel in fuels {
                    try modifiedFuel?.save(db)
                }
                
                for modifiedTrip in trips {
                    try modifiedTrip?.save(db)
                }
                
                for deleted in deletedRecords {
                    switch deleted.record {
                    case .fuel: try Fuel.deleteOne(db, id: deleted.id)
                    case .trip: try Trip.deleteOne(db, id: deleted.id)
                    case .vehicle: try Vehicle.deleteOne(db, id: deleted.id)
                    }
                }
                
                try Fuel.filter(dirtyColumn == true).updateAll(db, dirtyColumn.set(to: false))
                try Trip.filter(dirtyColumn == true).updateAll(db, dirtyColumn.set(to: false))
                try Vehicle.filter(dirtyColumn == true).updateAll(db, dirtyColumn.set(to: false))
                try Deleted.deleteAll(db)
                UserDefaults.standard.set(newSync, forKey: lastSyncDateKey)
            }
        } catch {
            print(error.localizedDescription)
            await ViewUtils.presentError(error)
        }
    }
}
