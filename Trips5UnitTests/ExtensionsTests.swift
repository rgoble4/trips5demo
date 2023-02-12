//
//  ExtensionsTests.swift
//  Trips5UnitTests
//
//  Created by Rob Goble on 2/11/23.
//

import XCTest

final class ExtensionsTests: XCTestCase {
    
    override func setUpWithError() throws { }
    override func tearDownWithError() throws { }
    
    func testStartOfMonth() throws {
        let cal = Calendar.current
        
        let components = DateComponents(calendar: cal, year: 2023, month: 02, day: 6)
        let expComponents = DateComponents(calendar: cal, year: 2023, month: 02, day: 1)
        let date = cal.date(from: components)
        let expDate = cal.date(from: expComponents)
        
        guard let date = date,
              let expDate = expDate else {
            XCTFail()
            return
        }
        
        let startOfMonth = date.startOfMonth
        
        XCTAssertEqual(expDate, startOfMonth)
    }
    
    func testStartOfYear() throws {
        let cal = Calendar.current
        
        let components = DateComponents(calendar: cal, year: 2023, month: 02, day: 6)
        let expComponents = DateComponents(calendar: cal, year: 2023, month: 01, day: 1)
        let date = cal.date(from: components)
        let expDate = cal.date(from: expComponents)
        
        guard let date = date,
              let expDate = expDate else {
            XCTFail()
            return
        }
        
        let startOfYear = date.startOfYear
        
        XCTAssertEqual(expDate, startOfYear)
    }
    
    func testIsSameMonthAsToday() throws {
        let cal = Calendar.current
        let now = Date()
        
        let sameMonthComponents = cal.dateComponents([.year, .month], from: now)
        
        var newMonth = (sameMonthComponents.month ?? 0) + 1
        
        // If it was December, use November as test month instead
        if newMonth == 13 { newMonth = 11 }
        
        let notSameMonthComponents = DateComponents(calendar: cal, year: sameMonthComponents.year, month: newMonth)
        
        let expSameMonthDate = cal.date(from: sameMonthComponents)
        let expNotSameMonthDate = cal.date(from: notSameMonthComponents)
        
        guard let expSameMonthDate = expSameMonthDate,
              let expNotSameMonthDate = expNotSameMonthDate else {
            XCTFail()
            return
        }
        
        XCTAssertTrue(expSameMonthDate.isSameMonthAsToday)
        XCTAssertFalse(expNotSameMonthDate.isSameMonthAsToday)
    }
    
    func testNumberOfDaysInMonth() throws {
        let cal = Calendar.current
        let components = DateComponents(calendar: cal, year: 2023, month: 01, day: 6)
        let date = cal.date(from: components)
        
        guard let date = date else {
            XCTFail()
            return
        }
        
        XCTAssertEqual(date.numberOfDaysInMonth, 31)
    }
    
    func testDayOfMonth() throws {
        let cal = Calendar.current
        let components = DateComponents(calendar: cal, year: 2023, month: 01, day: 6)
        let date = cal.date(from: components)
        
        guard let date = date else {
            XCTFail()
            return
        }
        
        XCTAssertEqual(date.dayInMonth, 6)
    }
    
    func testWithoutTime() throws {
        let cal = Calendar.current
        let components = DateComponents(calendar: cal, year: 2023, month: 01, day: 6, hour: 8)
        let expComponents = DateComponents(calendar: cal, year: 2023, month: 01, day: 6)
        
        let date = cal.date(from: components)
        let expDate = cal.date(from: expComponents)
        
        guard let date = date,
              let expDate = expDate else {
            XCTFail()
            return
        }
        
        XCTAssertEqual(date.withoutTime(), expDate)
    }
    
    func testMonthsAgo() throws {
        let monthsAgo = Date.monthsAgo(1)
        
        XCTAssertGreaterThan(Date(), monthsAgo)
    }
    
    func testYearsAgo() throws {
        let yearsAgo = Date.yearsAgo(1)
        
        XCTAssertGreaterThan(Date(), yearsAgo)
    }
}
