//
//  Schedule.swift
//  MPCRevisited
//
//  Created by Douglas Mandarino on 3/12/15.
//  Copyright (c) 2015 Appcoda. All rights reserved.
//

import Foundation

class Time {
    
    private var timeIndex:Int!
    private var day:String!
    private var hour:Int!
    private var busy:Bool!
    private var optional:Bool!
    
    init(timeIndex:Int, day:String, hour:Int){
        self.timeIndex = timeIndex
        self.day = day
        self.hour = hour
        busy = false
        optional = false
    }
    
    func getDay() -> String{
        return self.day
    }
    
    func setDay(day:String) {
        self.day = day
    }
    
    func getTimeIndex() -> Int{
        return self.timeIndex
    }
    
    func setTimeIndex(timeIndex:Int) {
        self.timeIndex = timeIndex
    }
    func getHour() -> Int{
        return self.hour
    }
    
    func setHour(hour:Int) {
        self.hour = hour
    }
    func isBusy() -> Bool{
        return self.busy
    }
    
    func setBusy(busy:Bool) {
        self.busy = busy
    }
    
    func isOptional() -> Bool{
        return self.optional
    }
    
    func setOptional(optional:Bool) {
        self.optional = optional
    }
}