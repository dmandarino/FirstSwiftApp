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
        var time = Time()
        time.setTimeIndex(1)
        time.setHour(1)
        time.setDay("Segunda")
        
        var time2 = Time()
        time2.setTimeIndex(5)
        time2.setHour(2)
        time2.setDay("Terca")
        
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

}