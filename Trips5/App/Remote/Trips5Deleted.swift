//
//  Trips5Deleted.swift
//  Trips5
//
//  Created by Rob Goble on 9/4/22.
//

import Foundation

struct Trips5Delete: Codable, Identifiable {
    var id: String
    var record: RecordType
    var deleted: Date
    
    func asCanonical(setDirty dirty: Bool = false) -> Deleted {
        return Deleted(id: id,
                       record: record,
                       deleted: deleted)
    }
    
    static func fromCanonical(deleted: Deleted) -> Trips5Delete {
        return Trips5Delete(id: deleted.id,
                            record: deleted.record,
                            deleted: deleted.deleted)
    }
}
