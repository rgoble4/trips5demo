//
//  Database.swift
//  Trips5
//
//  Created by Rob Goble on 8/14/22.
//

import Foundation
import GRDB

class Database {
    let pool: DatabaseWriter
    let location: URL
    
    init() {
        do {
            let folderURL = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
            try FileManager.default.createDirectory(at: folderURL, withIntermediateDirectories: true)
            
            let dbURL = folderURL.appendingPathComponent("trips5.sqlite")
            location = folderURL
            
            let migrator = Migrator()
            let pool = try DatabasePool(path: dbURL.path)
            try migrator.migrate(for: pool)
            self.pool = pool
        } catch {
            fatalError(error.localizedDescription)
        }
    }
    
    func deleteAll() async {
        do {
            try await pool.write { db in
                try Vehicle.deleteAll(db)
                try Deleted.deleteAll(db)
            }
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func releaseMemory() {
        do {
            try pool.write { db in
                db.releaseMemory()
            }
        } catch {
            print(error.localizedDescription)
        }
    }
}

class Migrator {
    
    private var migrator: DatabaseMigrator
    
    init() {
        var migrator = DatabaseMigrator()
        
        #if DEBUG
        // Speed up development by nuking the database when migrations change
        // See https://github.com/groue/GRDB.swift/blob/master/Documentation/Migrations.md#the-erasedatabaseonschemachange-option
        migrator.eraseDatabaseOnSchemaChange = true
        #endif
        
        self.migrator = migrator
        self.migrator = v1(migrator)
    }
    
    func migrate(for databaseWriter: DatabaseWriter) throws {
        try migrator.migrate(databaseWriter)
    }
    
    func v1(_ dm: DatabaseMigrator) -> DatabaseMigrator {
        var migrator = dm
        
        migrator.registerMigration("1") { db in
            try db.create(table: "vehicle") { t in
                t.column("id", .text).primaryKey(onConflict: .replace)
                t.column("name", .text).notNull()
                t.column("modified", .datetime).notNull()
                t.column("dirty", .boolean).notNull().defaults(to: false)
            }
            
            try db.create(table: "fuel") { t in
                t.column("id", .text).primaryKey(onConflict: .replace)
                t.column("vehicleId", .text).notNull().indexed().references("vehicle", onDelete: .cascade)
                t.column("date", .text).notNull()
                t.column("fromOdo", .integer).notNull()
                t.column("toOdo", .integer).notNull()
                t.column("distance", .integer).notNull()
                t.column("fuelAmount", .double).notNull()
                t.column("modified", .datetime).notNull()
                t.column("dirty", .boolean).notNull().defaults(to: false)
            }

            try db.create(table: "trip") { t in
                t.column("id", .text).primaryKey(onConflict: .replace)
                t.column("vehicleId", .text).notNull().indexed().references("vehicle", onDelete: .cascade)
                t.column("date", .text).notNull()
                t.column("fromOdo", .integer).notNull()
                t.column("toOdo", .integer).notNull()
                t.column("distance", .integer).notNull()
                t.column("modified", .datetime).notNull()
                t.column("dirty", .boolean).notNull().defaults(to: false)
            }
            
            try db.create(table: "deleted") { t in
                t.column("id", .text).primaryKey(onConflict: .replace)
                t.column("record", .text).notNull()
                t.column("deleted", .datetime).notNull()
            }
            
            try db.create(index: "fuel_date", on: "fuel", columns: ["date"])
            try db.create(index: "trip_date", on: "trip", columns: ["date"])
        }
        
        return migrator
    }
}

enum RecordType: String, Codable {
    case fuel, trip, vehicle
}

extension RecordType: DatabaseValueConvertible { }
