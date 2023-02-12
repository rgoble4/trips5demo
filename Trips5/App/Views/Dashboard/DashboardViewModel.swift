//
//  DashboardViewModel.swift
//  Trips5
//
//  Created by Rob Goble on 2/4/23.
//

import Combine
import Foundation
import GRDB

class DashboardViewModel: ObservableObject {
    typealias Dependencies = DatabaseProvider & FormatterProvider & VehicleStoreProvider
    
    @MainActor
    @Published
    var gauges: [GaugeGroupData] = []
    
    @MainActor
    @Published
    var graphs: [LineGraphData] = []
    
    @MainActor
    @Published
    var isLoading: Bool = true
    
    private var activeVeh: Vehicle? {
        didSet {
            if activeVeh != oldValue {
                Task {
                    await refreshData()
                }
            }
        }
    }
    private let database: Database
    private let dependencies: Dependencies
    private let formatter: Formatter
    private let sqlHelper: AggregateSqlHelper
    
    private var cancellables = Set<AnyCancellable>()
    
    init(_ dependencies: Dependencies) {
        self.database = dependencies.database
        self.dependencies = dependencies
        self.formatter = dependencies.formatter
        self.sqlHelper = AggregateSqlHelper(database, formatter: formatter)
        
        Task {
            activeVeh = await dependencies.vehicleStore.active
            
            await dependencies.vehicleStore.$active
                .sink { [weak self] vehicle in
                    guard let self else { return }
                    self.activeVeh = vehicle
                }
                .store(in: &cancellables)
            
            let observation = DatabaseRegionObservation(tracking: Table("trip"), Table("fuel"))
            observation.publisher(in: database.pool)
                .sink(receiveCompletion: { _ in }, receiveValue: { [weak self] _ in
                    guard let self else { return }
                    
                    Task {
                        await self.refreshData()
                    }
                })
                .store(in: &cancellables)
        }
    }
    
    @MainActor
    private func setGauges(_ gauges: [GaugeGroupData]) {
        self.gauges = gauges
    }
    
    @MainActor
    private func setGraphs(_ graphs: [LineGraphData]) {
        self.graphs = graphs
    }
    
    @MainActor
    private func setIsLoading(_ value: Bool) {
        isLoading = value
    }
    
    private func refreshData() async {
        await setIsLoading(true)
        await populateGauges()
        await populateGraphs()
        await setIsLoading(false)
    }
    
    private func populateGauges() async {
        guard let activeVeh = self.activeVeh else { return }
        
        var mpgGauges = [GaugeData]()
        var distanceGauges = [GaugeData]()
        
        if let shortMpg = await sqlHelper.getMpg(for: activeVeh.id, from: Date.monthsAgo(3)) {
            var gauge = GaugeData.mpgGauge()
            gauge.value = formatter.round1(shortMpg)
            gauge.text = "3 mo"
            mpgGauges.append(gauge)
        }
        
        if let allMpg = await sqlHelper.getMpg(for: activeVeh.id) {
            var gauge = GaugeData.mpgGauge()
            gauge.value = formatter.round1(allMpg)
            gauge.text = "all"
            mpgGauges.append(gauge)
        }
        
        if let shortDistance = await sqlHelper.getDistance(for: activeVeh.id, from: Date().startOfYear) {
            var gauge = GaugeData.distanceGauge()
            gauge.value = Double(shortDistance)
            gauge.text = "ytd"
            distanceGauges.append(gauge)
        }
        
        if let allDistance = await sqlHelper.getDistance(for: activeVeh.id) {
            var gauge = GaugeData.distanceGauge()
            gauge.value = Double(allDistance)
            gauge.max = 200000
            gauge.text = "all"
            distanceGauges.append(gauge)
        }
        
        let finalGauges = [GaugeGroupData(title: "MPG", gauges: mpgGauges), GaugeGroupData(title: "Miles", gauges: distanceGauges)]
        
        Task {
            await self.setGauges(finalGauges)
        }
    }
    
    private func populateGraphs() async {
        var graphs = [LineGraphData]()
        
        if let mpgGraph = await buildMpgGraph() {
            graphs.append(mpgGraph)
        }
        
        if let distanceGraph = await buildDistanceGraph() {
            graphs.append(distanceGraph)
        }
        
        let finalGraphs = graphs
        
        Task {
            await self.setGraphs(finalGraphs)
        }
    }
    
    private func buildDistanceGraph() async -> LineGraphData? {
        guard let activeVeh = self.activeVeh else { return nil }
        
        let sixMonthDate = Date.monthsAgo(6).startOfMonth
        
        do {
            let vehTrips: [VehicleTrip] = try await database.pool.read { db in
                return try activeVeh.trips
                    .including(required: Trip.vehicle)
                    .filter(Column("date") >= self.formatter.noTimeFormatter.string(from: sixMonthDate))
                    .asRequest(of: VehicleTrip.self)
                    .fetchAll(db)
            }
            
            guard vehTrips.count > 0 else { return nil }
            
            var totalDist = 0
            
            let dateGroup = vehTrips.reduce(into: [Date: Int]()) { result, vehTrip in
                let date = vehTrip.date.startOfMonth
                totalDist += vehTrip.trip.distance
                
                if let existingSum = result[date] {
                    result[date] = existingSum + vehTrip.trip.distance
                } else {
                    result[date] = vehTrip.trip.distance
                }
            }
            
            var minDist = Double.greatestFiniteMagnitude
            var maxDist = Double.leastNonzeroMagnitude
            
            let lineData = dateGroup.sorted(by: { $0.key < $1.key })
                .map {
                    let value = Double($1)
                    
                    if value < minDist {
                        minDist = value
                    }
                    
                    if value > maxDist {
                        maxDist = value
                    }
                    
                    return LineGraphEntry(label: $0, value: value)
                }
            
            return LineGraphData(chartLabel: "Miles",
                                 xLabelKey: "Date",
                                 yLabelKey: "Miles",
                                 averageValue: round(Double(totalDist) / Double(dateGroup.values.count)),
                                 minValue: minDist,
                                 maxValue: maxDist,
                                 entries: lineData)
        } catch {
            print(error.localizedDescription)
        }
        
        return nil
    }
    
    private func buildMpgGraph() async -> LineGraphData? {
        guard let activeVeh = self.activeVeh else { return nil }
        
        let sixMonthDate = Date.monthsAgo(6).startOfMonth
        
        do {
            let vehFuels: [VehicleFuel] = try await database.pool.read { db in
                return try activeVeh.fuels
                    .including(required: Fuel.vehicle)
                    .filter(Column("date") >= self.formatter.noTimeFormatter.string(from: sixMonthDate))
                    .asRequest(of: VehicleFuel.self)
                    .fetchAll(db)
            }
            
            guard vehFuels.count > 0 else { return nil }
            
            var totalDist = 0
            var totalFuel = 0.0
            let dateGroup = vehFuels.reduce(into: [Date: (distance: Int, fuel: Double)]()) { result, vehFuel in
                let date = vehFuel.date.startOfMonth
                
                totalDist += vehFuel.fuel.distance
                totalFuel += vehFuel.fuel.fuelAmount
                
                if let (distance, fuel) = result[date] {
                    result[date] = (distance + vehFuel.fuel.distance, fuel + vehFuel.fuel.fuelAmount)
                } else {
                    result[date] = (vehFuel.fuel.distance, vehFuel.fuel.fuelAmount)
                }
            }
            
            var minMpg = Double.greatestFiniteMagnitude
            var maxMpg = Double.leastNonzeroMagnitude
            let lineData = dateGroup.sorted(by: { $0.key < $1.key })
                .map {
                    let mpg = Double($1.distance) / Double($1.fuel)
                    
                    if mpg < minMpg {
                        minMpg = mpg
                    }
                    
                    if mpg > maxMpg {
                        maxMpg = mpg
                    }
                    
                    return LineGraphEntry(label: $0, value: mpg)
                }
            
            return LineGraphData(chartLabel: "MPG",
                                 xLabelKey: "Date",
                                 yLabelKey: "MPG",
                                 averageValue: formatter.round1(Double(totalDist) / totalFuel),
                                 minValue: minMpg,
                                 maxValue: maxMpg,
                                 entries: lineData)
        } catch {
            print(error.localizedDescription)
        }
        
        return nil
    }
}
