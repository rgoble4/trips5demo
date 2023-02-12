//
//  EnvTests.swift
//  Trips5UnitTests
//
//  Created by Rob Goble on 2/11/23.
//

import XCTest

final class EnvTests: XCTestCase {
    override func setUpWithError() throws { }
    override func tearDownWithError() throws { }
    
    func testSettingHost() {
        Env.shared.setEnv(to: .none)
        Env.shared.setEnv(to: .local)
        
        XCTAssertEqual(Env.shared.host, .local)
        
        Env.shared.setEnv(to: .none)
    }
}
