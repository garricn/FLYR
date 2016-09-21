//
//  AddFlyrUITestCase.swift
//  FLYR
//
//  Created by Garric Nahapetian on 9/18/16.
//  Copyright © 2016 Garric Nahapetian. All rights reserved.
//

import XCTest

class AddFlyrUITestCase: XCTestCase {
    let app = XCUIApplication()

    override func setUp() {
        super.setUp()
        continueAfterFailure = true
        app.launch()
    }

    override func tearDown() {
        super.tearDown()
    }
}

func assertApp(isDisplaying element: XCUIElement) {
    XCTAssert(element.exists, "Could not find \(element).")
}
