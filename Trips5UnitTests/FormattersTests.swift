//
//  FormattersTests.swift
//  Trips5UnitTests
//
//  Created by Rob Goble on 2/11/23.
//

import XCTest

final class FormattersTests: XCTestCase {
    override func setUpWithError() throws { }
    override func tearDownWithError() throws { }
    
    func testRounding() {
        let value = 1.6666
        
        let roundedToOneDigit = Formatter.shared.round1(value)
        let roundedToTwoDigits = Formatter.shared.round2(value)
        let roundedToTwoDigitsStr = Formatter.shared.round2Str(value)
        
        XCTAssertEqual(roundedToOneDigit, 1.7)
        XCTAssertEqual(roundedToTwoDigits, 1.67)
        XCTAssertEqual(roundedToTwoDigitsStr, "1.67")
    }
}
