//
//  Dependencies.swift
//  Trips5
//
//  Created by Rob Goble on 2/4/23.
//

import Foundation

protocol DatabaseProvider {
    var database: Database { get }
}

protocol EnvProvider {
    var env: Env { get }
}

protocol FormatterProvider {
    var formatter: Formatter { get }
}

protocol FuelStoreProvider {
    var fuelStore: FuelStore { get }
}

protocol SyncProvider {
    var syncManager: SyncManager { get }
}

protocol ThemeProvider {
    var theme: Theme { get }
}

protocol TripStoreProvider {
    var tripStore: TripStore { get }
}

protocol VehicleStoreProvider {
    var vehicleStore: VehicleStore { get }
}

class DependencyManager {
    lazy var database = Database()
    lazy var fuelStore = FuelStore(self)
    lazy var env = Env.shared
    lazy var formatter = Formatter.shared
    lazy var syncManager = SyncManager(self)
    lazy var theme = Theme()
    lazy var tripStore = TripStore(self)
    lazy var vehicleStore = VehicleStore(self)
}

extension DependencyManager: DatabaseProvider { }
extension DependencyManager: EnvProvider { }
extension DependencyManager: FormatterProvider { }
extension DependencyManager: FuelStoreProvider { }
extension DependencyManager: SyncProvider { }
extension DependencyManager: ThemeProvider { }
extension DependencyManager: TripStoreProvider { }
extension DependencyManager: VehicleStoreProvider { }
