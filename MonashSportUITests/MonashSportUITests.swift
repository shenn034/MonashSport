//
//  MonashSportUITests.swift
//  MonashSportUITests
//
//  Created by 杨申 on 8/5/18.
//  Copyright © 2018 Shen Yang. All rights reserved.
//

import XCTest

class MonashSportUITests: XCTestCase {
        
    override func setUp() {
        super.setUp()
        
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false
        // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
        XCUIApplication().launch()

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
        
        
        
        let app = XCUIApplication()
        app.children(matching: .window).element(boundBy: 0).children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .staticText).matching(identifier: "0.0").element(boundBy: 0).tap()
        XCTAssertTrue(app.staticTexts["Cals"].exists)
        
    }
    
    func testTableVIew(){
        
        let app = XCUIApplication()
        app.navigationBars["Home"].children(matching: .button).matching(identifier: "Item").element(boundBy: 0).tap()
        app.staticTexts["Friends"].tap()
        XCTAssertTrue(app.tables/*@START_MENU_TOKEN@*/.staticTexts["test"]/*[[".cells.staticTexts[\"test\"]",".staticTexts[\"test\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.exists)
        
        
    }
}
