//
//  AppLaunchUITestCase.swift
//  FLYR
//
//  Created by Garric Nahapetian on 9/18/16.
//  Copyright © 2016 Garric Nahapetian. All rights reserved.
//

import XCTest

class AppLaunchUITestCase: XCTestCase {
    let app = XCUIApplication()

    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        app.launch()
    }
    
    override func tearDown() {
        super.tearDown()
    }

    func testAppDisplaysFeedTabBarItem() {
        let feedTabBarItem = app.tabBars.buttons["FEED"]
        XCTAssert(feedTabBarItem.exists, "Could not find feed tab bar item")
    }

    func testAppDisplaysAddItemTabBarItem() {
        let postTabBarItem = app.tabBars.buttons["POST"]
        XCTAssert(postTabBarItem.exists, "Could not find post tab bar item")
    }
}
