//
//  TripsViewModel.swift
//  Trips5
//
//  Created by Rob Goble on 9/17/22.
//

import Combine
import Foundation
import GRDB

actor TripsViewModel: ObservableObject {
    typealias Dependencies = DatabaseProvider & FormatterProvider & VehicleStoreProvider
    
    struct TripSection: Identifiable, Hashable {
        var id: String
        var description: String
        var trips: [VehicleTrip]
        
        func hash(into hasher: inout Hasher) {
            hasher.combine(id)
        }
    }
    
    @MainActor
    @Published
    var tripSections = [TripSection]()
    
    private let db: Database
    private let formatter: Formatter
    private let vehicleStore: VehicleStore
    
    @MainActor
    private var page = 1
    @MainActor
    var allTrips = [VehicleTrip]()
    @MainActor
    private var tripIdxById = [String: Int]()
    @MainActor
    private var totalTripCount = 0
    
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
    
    @MainActor
    func itemAppeared(_ trip: VehicleTrip) {
        guard allTrips.count > 0,
              let index = tripIdxById[trip.id],
              index >= allTrips.count - (Constants.pageSize / 2),
              allTrips.count < totalTripCount else { return }
        
        Task {
            guard let activeVeh = vehicleStore.active else { return }
            let page = page
            
            do {
                let trips: [VehicleTrip] = try await db.pool.read { db in
                    return try activeVeh.trips
                        .including(required: Trip.vehicle)
                        .asRequest(of: VehicleTrip.self)
                        .order(Column("toOdo").desc)
                        .limit(Constants.pageSize, offset: page * Constants.pageSize)
                        .fetchAll(db)
                }
                
                appendTrips(trips)
                bumpPage()
            } catch {
                print(error.localizedDescription)
            }
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
                    await self.setTripCount(count)
                    await self.appendTrips(trips)
                }
            }
        } catch {
            print(error.localizedDescription)
        }
    }
    
    @MainActor
    private func resetState() {
        page = 1
        tripSections = []
        allTrips = []
        tripIdxById = [:]
        totalTripCount = 0
    }
    
    @MainActor
    private func appendTrips(_ trips: [VehicleTrip]) {
        allTrips.append(contentsOf: trips)
        
        for (idx, trip) in allTrips.enumerated() {
            tripIdxById[trip.id] = idx
        }
        
        setupSections()
    }
    
    @MainActor
    private func setTripCount(_ count: Int) {
        totalTripCount = count
    }
    
    @MainActor
    private func setupSections() {
        let sectionLookup = allTrips.reduce(into: [String: TripSection]()) { result, vehicleTrip in
            let groupDateId = formatter.monthYearSortFormatter.string(from: vehicleTrip.date)
            let groupDateDescription = formatter.monthYearFormatter.string(from: vehicleTrip.date)
            
            if result[groupDateId] != nil {
                result[groupDateId]?.trips.append(vehicleTrip)
            } else {
                result[groupDateId] = TripSection(id: groupDateId, description: groupDateDescription, trips: [vehicleTrip])
            }
        }
        
        // Decorate section descriptions
        let sections = sectionLookup.values.map { section in
            var sec = section
            let totalMiles = section.trips.reduce(into: 0) { result, vehicleTrip in
                result += vehicleTrip.trip.distance
            }
            
            var totalDays = 1
            
            if let lastDateStr = section.trips.first?.trip.date,
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
        
        tripSections = sections
    }
    
    @MainActor
    private func bumpPage() {
        page += 1
    }
}
