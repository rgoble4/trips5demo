//
//  FuelStore.swift
//  Trips5
//
//  Created by Rob Goble on 9/5/22.
//

import Combine
import Foundation
import GRDB

actor FuelsViewModel: ObservableObject, PagingEnabledViewModel {
    typealias Item = VehicleFuel
    typealias Section = FuelSection
    
    typealias Dependencies = DatabaseProvider & FormatterProvider & VehicleStoreProvider
    
    struct FuelSection: Identifiable, Hashable {
        var id: String
        var description: String
        var items: [VehicleFuel]
        
        func hash(into hasher: inout Hasher) {
            hasher.combine(id)
        }
    }
    
    @MainActor
    @Published
    var sections = [FuelSection]()
    
    private let db: Database
    private let formatter: Formatter
    private let vehicleStore: VehicleStore
    
    @MainActor
    var page = 1
    @MainActor
    var all = [VehicleFuel]()
    @MainActor
    var itemIdxById = [String: Int]()
    @MainActor
    var totalCount = 0
    
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
    
    func loadMoreData() async {
        guard let activeVeh = await vehicleStore.active else { return }
        let page = await page
        
        do {
            let fuels: [VehicleFuel] = try await db.pool.read { db in
                return try activeVeh.fuels
                    .including(required: Fuel.vehicle)
                    .asRequest(of: VehicleFuel.self)
                    .order(Column("toOdo").desc)
                    .limit(Constants.pageSize, offset: page * Constants.pageSize)
                    .fetchAll(db)
            }
            
            await self.appendItems(fuels)
            await self.bumpPage()
        } catch {
            print(error.localizedDescription)
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
            resetState()
        }
        
        guard let activeVeh = await self.vehicleStore.active else { return }
        
        do {
            try await db.pool.read { [weak self] db in
                guard let self = self else { return }
                
                let count = try activeVeh.fuels.fetchCount(db)
                
                let fuels = try activeVeh.fuels
                        .including(required: Fuel.vehicle)
                        .asRequest(of: VehicleFuel.self)
                        .order(Column("toOdo").desc)
                        .limit(Constants.pageSize)
                        .fetchAll(db)
                
                Task {
                    await self.setCount(count)
                    await self.appendItems(fuels)
                }
            }
        } catch {
            print(error.localizedDescription)
        }
    }
    
    @MainActor
    func setupSections() {
        let sectionLookup = all.reduce(into: [String: FuelSection]()) { result, vehicleFuel in
            let groupDateId = formatter.monthYearSortFormatter.string(from: vehicleFuel.date)
            let groupDateDescription = formatter.monthYearFormatter.string(from: vehicleFuel.date)
            
            if result[groupDateId] != nil {
                result[groupDateId]?.items.append(vehicleFuel)
            } else {
                result[groupDateId] = FuelSection(id: groupDateId, description: groupDateDescription, items: [vehicleFuel])
            }
        }
        
        // Decorate section descriptions
        let sections = sectionLookup.values.map { section in
            var sec = section
            let totalMiles = section.items.reduce(into: 0) { result, vehicleFuel in
                result += vehicleFuel.fuel.distance
            }
            let totalFuel = section.items.reduce(into: 0) { result, vehicleFuel in
                result += vehicleFuel.fuel.fuelAmount
            }
            
            let mpg = formatter.round2Str((Double(totalMiles) / totalFuel))
            sec.description = "\(section.description) - \(mpg) mpg"
            return sec
        }.sorted(by: { $0.id > $1.id })
        
        self.sections = sections
    }
}
