//
//  Trips5UIUITests.swift
//  Trips5UIUITests
//
//  Created by Rob Goble on 2/11/23.
//

import XCTest

let springboard = XCUIApplication(bundleIdentifier: "com.apple.springboard")

func deleteApp() {
    XCUIApplication().terminate()

    let bundleDisplayName = "Trips5"

    let icon = springboard.icons[bundleDisplayName]
    if icon.exists {
        icon.press(forDuration: 1)

        let buttonRemoveApp = springboard.buttons["Remove App"]
        if buttonRemoveApp.waitForExistence(timeout: 5) {
            buttonRemoveApp.tap()
        } else {
            XCTFail("Button \"Remove App\" not found")
        }

        let buttonDeleteApp = springboard.alerts.buttons["Delete App"]
        if buttonDeleteApp.waitForExistence(timeout: 5) {
            buttonDeleteApp.tap()
        }
        else {
            XCTFail("Button \"Delete App\" not found")
        }

        let buttonDelete = springboard.alerts.buttons["Delete"]
        if buttonDelete.waitForExistence(timeout: 5) {
            buttonDelete.tap()
        }
        else {
            XCTFail("Button \"Delete\" not found")
        }
    }
}

final class Trips5UIUITests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testInitialLaunch() throws {
        // UI tests must launch the application that they test.
        let app = XCUIApplication()
        app.launch()
        
        let tabBar = app.tabBars["Tab Bar"]
        tabBar.buttons["Home"].tap()
        
        // Sample data means there shouldn't be this default text.
        XCTAssertFalse(app.staticTexts["noDataText"].exists)
    }
    
    func testAddDeleteVehicle() throws {
        let app = XCUIApplication()
        app.launch()
        
        app.tabBars["Tab Bar"].buttons["Settings"].tap()
        app.collectionViews/*@START_MENU_TOKEN@*/.buttons["Vehicles"]/*[[".cells.buttons[\"Vehicles\"]",".buttons[\"Vehicles\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
        
        XCTAssertEqual(1, app.collectionViews.count)
        
        app.navigationBars["Vehicles"]/*@START_MENU_TOKEN@*/.buttons["Add"]/*[[".otherElements[\"Add\"].buttons[\"Add\"]",".buttons[\"Add\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
        app.navigationBars["Vehicle"]/*@START_MENU_TOKEN@*/.buttons["Save"]/*[[".otherElements[\"Save\"].buttons[\"Save\"]",".buttons[\"Save\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
        
        XCTAssertTrue(app.collectionViews.buttons["New Vehicle"].waitForExistence(timeout: 1))
        
        app.collectionViews.buttons["New Vehicle"].tap()
        app.collectionViews.buttons["Delete"].tap()
        
        XCTAssertFalse(app.collectionViews.buttons["New Vehicle"].waitForExistence(timeout: 1))
    }
}
