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
        var time = Time(timeIndex: 3, day: "Terca", hour: 5)
        time.setBusy(true)
        
        XCTAssertEqual(time.getDay(), "Terca")
        XCTAssertEqual(time.getHour(), 5)
        XCTAssertEqual(time.isBusy(), true)
        XCTAssertEqual(time.isOptional(), false)
        XCTAssertEqual(time.getTimeIndex(), 3)
    }
    
    func testFailGetScheduleValues() {
        var time = Time(timeIndex: 2, day: "Terca", hour: 4)
        
        XCTAssertNotEqual(time.getDay(), "Quarta")
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measureBlock() {
            // Put the code you want to measure the time of here.
        }
    }
}