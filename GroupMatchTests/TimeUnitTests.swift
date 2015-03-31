//
//  TimeUnitTests.swift
//  GroupMatch
//
//  Created by Douglas Mandarino on 3/30/15.
//  Copyright (c) 2015 Appcoda. All rights reserved.
//

import Foundation
import XCTest

class TimeUnitTests : XCTestCase {
 
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testGetScheduleValues() {
        var time = Time()
        time.setDay("Terca")
        time.setHour(5)
        time.setBusy(true)
        time.setOptional(false)
        time.setTimeIndex(3)
        
        XCTAssertEqual(time.getDay(), "Terca")
        XCTAssertEqual(time.getHour(), 5)
        XCTAssertEqual(time.isBusy(), true)
        XCTAssertEqual(time.isOptional(), false)
        XCTAssertEqual(time.getTimeIndex(), 3)
    }
    
    func testFailGetScheduleValues() {
        var time = Time()
        time.setDay("Terca")
        
        XCTAssertNotEqual(time.getDay(), "Quarta")
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measureBlock() {
            // Put the code you want to measure the time of here.
        }
    }
}