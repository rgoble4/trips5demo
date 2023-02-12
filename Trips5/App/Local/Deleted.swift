//
//  Deleted.swift
//  Trips5
//
//  Created by Rob Goble on 9/4/22.
//

import Foundation
import GRDB

struct Deleted: Codable, Identifiable {
    var id: String
    var record: RecordType
    var deleted: Date
}

extension Deleted: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

// MARK: GRDB Conformance

extension Deleted: TableRecord {
    enum Columns {
        static let id = Column(CodingKeys.id)
        static let record = Column(CodingKeys.record)
        static let deleted = Column(CodingKeys.deleted)
    }
}

extension Deleted: FetchableRecord { }
extension Deleted: PersistableRecord { }
