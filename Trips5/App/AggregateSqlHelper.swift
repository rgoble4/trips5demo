//
//  AggregateSqlHelper.swift
//  Trips5
//
//  Created by Rob Goble on 2/5/23.
//

import Foundation
import GRDB

fileprivate let mpgSql = """
    SELECT sum(distance) / sum(fuelAmount)
    FROM fuel
    WHERE vehicleId = ?
    AND date >= ?
"""

fileprivate let distanceSql = """
    SELECT sum(distance)
    FROM trip
    WHERE vehicleId = ?
    AND date >= ?
"""

struct AggregateSqlHelper {
    private let database: Database
    private let formatter: Formatter
    
    init(_ database: Database, formatter: Formatter) {
        self.database = database
        self.formatter = formatter
    }
    
    func getMpg(for vehicleId: String, from date: Date? = nil) async -> Double? {
        let value: Double? = await getWithSql(mpgSql, for: vehicleId, from: date)
        return value
    }
    
    func getDistance(for vehicleId: String, from date: Date? = nil) async -> Int64? {
        let value: Int64? = await getWithSql(distanceSql, for: vehicleId, from: date)
        return value
    }
    
    private func getWithSql<T>(_ sql: String, for vehicleId: String, from date: Date?) async -> T? {
        
        do {
            let row = try await database.pool.read { db in
                var dateStr = "1970-01-01"
                
                if let date = date {
                    dateStr = formatter.noTimeFormatter.string(from: date)
                }
                
                return try Row.fetchOne(db, sql: sql, arguments: [vehicleId, dateStr])
            }
            
            guard let value = row?[0] as? T else { return nil }
            return value
        } catch {
            print(error.localizedDescription)
        }
        
        return nil
    }
}
