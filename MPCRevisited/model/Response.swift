//
//  Response.swift
//  GroupMatch
//
//  Created by Douglas Mandarino on 3/23/15.
//  Copyright (c) 2015 Appcoda. All rights reserved.
//

import Foundation

class Response {
    private var day: String!
    private var hour: String!
    
    init(){
        self.day = ""
        self.hour = ""
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