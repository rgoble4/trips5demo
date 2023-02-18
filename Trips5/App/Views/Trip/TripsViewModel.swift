//
//  TripsViewModel.swift
//  Trips5
//
//  Created by Rob Goble on 9/17/22.
//

import Combine
import Foundation
import GRDB

actor TripsViewModel: ObservableObject, PagingEnabledViewModel {
    typealias Dependencies = DatabaseProvider & FormatterProvider & VehicleStoreProvider
    
    typealias Item = VehicleTrip
    typealias Section = TripSection
    
    struct TripSection: Identifiable, Hashable {
        var id: String
        var description: String
        var items: [VehicleTrip]

        func hash(into hasher: inout Hasher) {
            hasher.combine(id)
        }
    }
    
    @MainActor
    @Published
    var sections = [TripSection]()
    
    private let db: Database
    private let formatter: Formatter
    private let vehicleStore: VehicleStore
    
    @MainActor
    var page = 1
    @MainActor
    var all = [VehicleTrip]()
    @MainActor
    var itemIdxById = [String: Int]()
    @MainActor
    var totalCount = 0
    
    private var tripsSub: AnyCancellable?
    
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
            let trips: [VehicleTrip] = try await db.pool.read { db in
                return try activeVeh.trips
                    .including(required: Trip.vehicle)
                    .asRequest(of: VehicleTrip.self)
                    .order(Column("toOdo").desc)
                    .limit(Constants.pageSize, offset: page * Constants.pageSize)
                    .fetchAll(db)
            }
            
            await appendItems(trips)
            await bumpPage()
        } catch {
            print(error.localizedDescription)
        }
    }
    
    private func subscribeToChanges() {
        let observation = DatabaseRegionObservation(tracking: Table("trip"))
        
        Task {
            tripsSub = observation
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
                let count = try activeVeh.trips.fetchCount(db)
                
                let trips = try activeVeh.trips
                        .including(required: Trip.vehicle)
                        .asRequest(of: VehicleTrip.self)
                        .order(Column("toOdo").desc)
                        .limit(Constants.pageSize)
                        .fetchAll(db)
                
                Task {
                    await self.setCount(count)
                    await self.appendItems(trips)
                }
            }
        } catch {
            print(error.localizedDescription)
        }
    }
    
    @MainActor
    func setupSections() {
        let sectionLookup = all.reduce(into: [String: TripSection]()) { result, vehicleTrip in
            let groupDateId = formatter.monthYearSortFormatter.string(from: vehicleTrip.date)
            let groupDateDescription = formatter.monthYearFormatter.string(from: vehicleTrip.date)
            
            if result[groupDateId] != nil {
                result[groupDateId]?.items.append(vehicleTrip)
            } else {
                result[groupDateId] = Section(id: groupDateId, description: groupDateDescription, items: [vehicleTrip])
            }
        }
        
        // Decorate section descriptions
        let sections = sectionLookup.values.map { section in
            var sec = section
            let totalMiles = section.items.reduce(into: 0) { result, vehicleTrip in
                result += vehicleTrip.trip.distance
            }
            
            var totalDays = 1
            
            if let lastDateStr = section.items.first?.trip.date,
               let lastDate = formatter.noTimeFormatter.date(from: lastDateStr) {
                
                if lastDate.isSameMonthAsToday {
                    totalDays = Date().dayInMonth
                } else {
                    totalDays = lastDate.numberOfDaysInMonth
                }
            }
            
            let perDay = formatter.round2Str((Double(totalMiles) / Double(totalDays)))
            
            sec.description = "\(section.description) - \(totalMiles) mi - \(perDay) / day"
            return sec
        }.sorted(by: { $0.id > $1.id })
        
        self.sections = sections
    }
}
