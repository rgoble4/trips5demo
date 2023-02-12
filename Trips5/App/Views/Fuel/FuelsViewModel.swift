//
//  FuelStore.swift
//  Trips5
//
//  Created by Rob Goble on 9/5/22.
//

import Combine
import Foundation
import GRDB

actor FuelsViewModel: ObservableObject {
    typealias Dependencies = DatabaseProvider & FormatterProvider & VehicleStoreProvider
    
    struct FuelSection: Identifiable, Hashable {
        var id: String
        var description: String
        var fuels: [VehicleFuel]
        
        func hash(into hasher: inout Hasher) {
            hasher.combine(id)
        }
    }
    
    @MainActor
    @Published
    var fuelSections = [FuelSection]()
    
    private let db: Database
    private let formatter: Formatter
    private let vehicleStore: VehicleStore
    
    @MainActor
    private var page = 1
    @MainActor
    var allFuels = [VehicleFuel]()
    @MainActor
    private var fuelIdxById = [String: Int]()
    @MainActor
    private var totalFuelCount = 0
    
    private var fuelsSub: AnyCancellable?
    
    init(_ dependencies: Dependencies) {
        self.db = dependencies.database
        self.formatter = dependencies.formatter
        self.vehicleStore = dependencies.vehicleStore
        
        Task {
            await subscribeToChanges()
        }
    }
    
    func start() {
        Task {
            await loadInitialData()
        }
    }
    
    @MainActor
    func itemAppeared(_ fuel: VehicleFuel) {
        guard allFuels.count > 0,
              let index = fuelIdxById[fuel.id],
              index >= allFuels.count - (Constants.pageSize / 2),
              allFuels.count < totalFuelCount else { return }
        
        Task {
            guard let activeVeh = vehicleStore.active else { return }
            let page = page
            
            do {
                let fuels: [VehicleFuel] = try await db.pool.read { db in
                    return try activeVeh.fuels
                        .including(required: Fuel.vehicle)
                        .asRequest(of: VehicleFuel.self)
                        .order(Column("toOdo").desc)
                        .limit(Constants.pageSize, offset: page * Constants.pageSize)
                        .fetchAll(db)
                }
                
                appendFuels(fuels)
                bumpPage()
            } catch {
                print(error.localizedDescription)
            }
        }
    }
    
    private func subscribeToChanges() {
        let observation = DatabaseRegionObservation(tracking: Table("fuel"))
        
        Task {
            fuelsSub = observation
                .publisher(in: db.pool)
                .sink(receiveCompletion: { print ("completion: \($0)") },
                      receiveValue: { [weak self] _ in
                    guard let self else { return }
                    
                    Task {
                        await self.loadInitialData()
                    }
                })
        }
    }
    
    private func loadInitialData() async {
        await MainActor.run {
            self.resetState()
        }
        
        guard let activeVeh = await self.vehicleStore.active else { return }
        
        do {
            try await db.pool.read { db in
                let count = try activeVeh.fuels.fetchCount(db)
                
                let fuels = try activeVeh.fuels
                        .including(required: Fuel.vehicle)
                        .asRequest(of: VehicleFuel.self)
                        .order(Column("toOdo").desc)
                        .limit(Constants.pageSize)
                        .fetchAll(db)
                
                Task {
                    await self.setFuelCount(count)
                    await self.appendFuels(fuels)
                }
            }
        } catch {
            print(error.localizedDescription)
        }
    }
    
    @MainActor
    private func resetState() {
        page = 1
        fuelSections = []
        allFuels = []
        fuelIdxById = [:]
        totalFuelCount = 0
    }
    
    @MainActor
    private func appendFuels(_ fuels: [VehicleFuel]) {
        allFuels.append(contentsOf: fuels)
        
        for (idx, fuel) in allFuels.enumerated() {
            fuelIdxById[fuel.id] = idx
        }
        
        setupSections()
    }
    
    @MainActor
    private func setFuelCount(_ count: Int) {
        totalFuelCount = count
    }
    
    @MainActor
    private func setupSections() {
        let sectionLookup = allFuels.reduce(into: [String: FuelSection]()) { result, vehicleFuel in
            let groupDateId = formatter.monthYearSortFormatter.string(from: vehicleFuel.date)
            let groupDateDescription = formatter.monthYearFormatter.string(from: vehicleFuel.date)
            
            if result[groupDateId] != nil {
                result[groupDateId]?.fuels.append(vehicleFuel)
            } else {
                result[groupDateId] = FuelSection(id: groupDateId, description: groupDateDescription, fuels: [vehicleFuel])
            }
        }
        
        // Decorate section descriptions
        let sections = sectionLookup.values.map { section in
            var sec = section
            let totalMiles = section.fuels.reduce(into: 0) { result, vehicleFuel in
                result += vehicleFuel.fuel.distance
            }
            let totalFuel = section.fuels.reduce(into: 0) { result, vehicleFuel in
                result += vehicleFuel.fuel.fuelAmount
            }
            
            let mpg = formatter.round2Str((Double(totalMiles) / totalFuel))
            sec.description = "\(section.description) - \(mpg) mpg"
            return sec
        }.sorted(by: { $0.id > $1.id })
        
        fuelSections = sections
    }
    
    @MainActor
    private func bumpPage() {
        page += 1
    }
}
