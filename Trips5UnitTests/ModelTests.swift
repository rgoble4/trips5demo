//
//  ModelTests.swift
//  Trips5UnitTests
//
//  Created by Rob Goble on 2/11/23.
//

import XCTest

final class ModelTests: XCTestCase {
    private let vehicle = Vehicle(id: UUID().uuidString, name: "test", modified: Date(), dirty: false)
    
    override func setUpWithError() throws { }
    override func tearDownWithError() throws { }
    
    func testFuel() {
        var fuel = Fuel(id: UUID().uuidString, vehicleId: "test", date: "date", fromOdo: 1, toOdo: 11, distance: 11, fuelAmount: 2, modified: Date(), dirty: false)
        
        fuel.date = "date2"
        XCTAssertTrue(fuel.dirty)
        fuel.dirty = false
        
        fuel.fromOdo = 0
        XCTAssertTrue(fuel.dirty)
        fuel.dirty = false
        
        fuel.toOdo = 10
        XCTAssertTrue(fuel.dirty)
        fuel.dirty = false
        
        fuel.fuelAmount = 1
        XCTAssertTrue(fuel.dirty)
        fuel.dirty = false
        
        XCTAssertEqual(fuel.mpg, 10.0)
        
        let newFuel = Fuel.new(for: vehicle, withPrevTOdo: 10)
        
        XCTAssertEqual(newFuel.fromOdo, 10)
    }
    
    func testTrip() {
        var trip = Trip(id: UUID().uuidString, vehicleId: "test", date: "date", fromOdo: 1, toOdo: 12, distance: 11, modified: Date(), dirty: false)
        
        trip.date = "date2"
        XCTAssertTrue(trip.dirty)
        trip.dirty = false
        
        trip.fromOdo = 0
        XCTAssertTrue(trip.dirty)
        trip.dirty = false
        
        trip.toOdo = 10
        XCTAssertTrue(trip.dirty)
        trip.dirty = false
        
        XCTAssertEqual(trip.distance, 10)
        
        let newTrip = Trip.new(for: vehicle, withPrevTOdo: 10)
        
        XCTAssertEqual(newTrip.fromOdo, 10)
    }
}
