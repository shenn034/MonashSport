//
//  MonashSportTests.swift
//  MonashSportTests
//
//  Created by 杨申 on 8/5/18.
//  Copyright © 2018 Shen Yang. All rights reserved.
//

import XCTest
@testable import MonashSport

class MonashSportTests: XCTestCase {
    var run : Runs!
    
    override func setUp() {
        super.setUp()
        run = Runs()
        
    }
    func test_Run(){
        run.setSteps(step: 1)
        XCTAssertEqual(run.userSteps, 1)
    }
    
}
