//
//  JSONServiceTests.swift
//  GroupMatch
//
//  Created by Douglas Mandarino on 3/30/15.
//  Copyright (c) 2015 Appcoda. All rights reserved.
//

import Foundation
import XCTest

class JSONServiceTests : XCTestCase{

    let jService = JSONService()
    
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testStringfyIntArray() {
        let array:[Int] = [1,0,2,0,0,1]
        
        var result = jService.stringfyIntArray(array)
        let string = "[{\"index\":1},{\"index\":0},{\"index\":2},{\"index\":0},{\"index\":0},{\"index\":1}]"
        
        XCTAssertEqual(result, string)
    }
   
    
    func testConvertStringToIntArray() {
        let string = "[{\"index\":1},{\"index\":0},{\"index\":2},{\"index\":0},{\"index\":0},{\"index\":1}]"
        
        let result = jService.convertStringToIntArray(string)
        let array = [1,0,2,0,0,1]
        
        XCTAssertEqual(result, array)
    }
    
    func testStringfyTimeArray() {
        var time = Time(timeIndex: 1, day: "Segunda", hour: 1)
        
        var time2 = Time(timeIndex: 5, day: "Terca", hour: 2)
        
        let array:[Time] = [time,time2]
        
        var result = jService.strinfyTimeArray(array)
        let string = "[{\"optional\":false,\"timeIndex\":1,\"busy\":false,\"day\":\"Segunda\",\"hour\":1},{\"optional\":false,\"timeIndex\":5,\"busy\":false,\"day\":\"Terca\",\"hour\":2}]"
        
        XCTAssertEqual(result, string)
    }
    
    func testConvertStringToTimeArray() {
        let string = "[{\"optional\":false,\"timeIndex\":1,\"busy\":false,\"day\":\"Segunda\",\"hour\":1}]"
        let result = jService.convertStringToTimeArray(string)
        let time = result.first!
        
        XCTAssertEqual("Segunda", time.getDay())
        XCTAssertEqual(1, time.getTimeIndex())
        XCTAssertEqual(1, time.getHour() )
        XCTAssertFalse( time.isOptional() )
        XCTAssertFalse( time.isBusy() )
    }
    
    func testFailConvertStringToTimeArray() {
        let string = "[{\"optional\":false,\"timeIndex\":1,\"busy\":false,\"day\":\"Segunda\",\"hour\":1}]"
        let result = jService.convertStringToTimeArray(string)
        let time = result.first!
        
        XCTAssertNotEqual("Terca", time.getDay())
        XCTAssertNotEqual(4, time.getTimeIndex())
        XCTAssertNotEqual(2, time.getHour() )
        XCTAssertTrue( !time.isOptional() )
        XCTAssertTrue( !time.isBusy() )
    }
    
    func testStringfyAvailableTimeArray() {
        let a1 = AvailableTime(day: "Segunda", hour: "07:00 - 08:00")
        let a2 = AvailableTime(day: "Segunda", hour: "10:00 - 20:00")
        
        let array:[AvailableTime] = [a1,a2]
        
        var result = jService.stringfyAvailableTimeArray(array)
        let string = "[{\"hour\":\"07:00 - 08:00\",\"day\":\"Segunda\"},{\"hour\":\"10:00 - 20:00\",\"day\":\"Segunda\"}]"
        
        XCTAssertEqual(result, string)
    }
    
    func testConvertStringToAvailableTimeArray() {
        let string = "[{\"hour\":\"07:00 - 08:00\",\"day\":\"Segunda\"},{\"hour\":\"10:00 - 20:00\",\"day\":\"Segunda\"}]"
        let result = jService.convertStringToAvailableTimeArray(string)
        let time = result.first!
        let time2 = result.last!
        
        XCTAssertEqual("Segunda", time.getDay())
        XCTAssertEqual("07:00 - 08:00", time.getHour())
        XCTAssertEqual("Segunda", time2.getDay())
        XCTAssertEqual("10:00 - 20:00", time2.getHour())
    }

}