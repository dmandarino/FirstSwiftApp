//
//  Response.swift
//  GroupMatch
//
//  Created by Douglas Mandarino on 3/23/15.
//  Copyright (c) 2015 Appcoda. All rights reserved.
//

import Foundation

class AvailableTime {
    private var day: String!
    private var hour: String!
    
    init(day:String, hour:String){
        self.day = day
        self.hour = hour
    }
    
    func getDay() ->String {
        return day
    }
    
    func setDay(day:String) {
        self.day = day
    }
    
    func getHour() ->String {
        return hour
    }
    
    func setHour(hour:String) {
        self.hour = hour
    }
}