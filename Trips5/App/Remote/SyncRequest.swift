//
//  SyncRequest.swift
//  Trips5
//
//  Created by Rob Goble on 9/2/22.
//

import Foundation

struct SyncRequest: Codable {
    var lastSync: Date?
    var deleted: [Trips5Delete]
    var fuels: [Trips5Fuel]
    var trips: [Trips5Trip]
    var vehicles: [Trips5Vehicle]
    
    func isEmpty() -> Bool {
        return deleted.count == 0 && fuels.count == 0 && trips.count == 0 && vehicles.count == 0
    }
}

extension SyncRequest: URLPathProviding {
    static func url(for requestType: RequestType) -> URL? {
        switch requestType {
        case .post: return Env.shared.host.base?.appendingPathComponent("/trips5demo/sync")
        default: return nil
        }
    }
}
