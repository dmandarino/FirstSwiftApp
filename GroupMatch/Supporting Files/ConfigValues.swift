//
//  ConfigValues.swift
//  GroupMatch
//
//  Created by Luan Barbalho Kalume on 30/03/15.
//  Copyright (c) 2015 Appcoda. All rights reserved.
//

private let _configValues = ConfigValues()

class ConfigValues {
    
    let daysOfWeek = 5
    let firstHour = 7
    let lastHour = 22
    let freeTimeIndex = 0
    let busyTimeIndex = 1
    let optionalTimeIndex = 2
    
    class var sharedInstance: ConfigValues {
        return _configValues
    }
   
}
