//
//  JSONService.swift
//  MPCRevisited
//
//  Created by Douglas Mandarino on 3/14/15.
//  Copyright (c) 2015 Appcoda. All rights reserved.
//

import Foundation

class JSONService {
    
    var scheduleDao = ScheduleDao()
    
    func createJSON(timeList:[Time]) -> String{
    
        var jsonObject: [AnyObject] = []
    
        for time in timeList {
            let schedule:AnyObject = ["timeId" : (time.timeId), "day" : (time.day), "hour": (time.hour), "optional": (time.optional), "busy": (time.busy)]
        
            jsonObject.append(schedule)
        }
        
        let schedule: AnyObject = [ "schedule" : jsonObject]

        func JSONStringify(value: AnyObject, prettyPrinted: Bool = false) -> String {
            var options = prettyPrinted ? NSJSONWritingOptions.PrettyPrinted : nil
            if NSJSONSerialization.isValidJSONObject(value) {
                if let data = NSJSONSerialization.dataWithJSONObject(value, options: options, error: nil) {
                    if let string = NSString(data: data, encoding: NSUTF8StringEncoding) {
                        return string
                    }
                }
            }
            return ""
        } 

        let jsonString = JSONStringify(jsonObject)
        
        return jsonString
    }
    
    func convertToJSON(jsonString:String) -> [Time]{

        var timeList = [Time]()
        var time = Time()
        
        func JSONParseArray(jsonString: String) -> [AnyObject] {
            if let data = jsonString.dataUsingEncoding(NSUTF8StringEncoding) {
                if let array = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions(0), error: nil)  as? [AnyObject] {
                    return array
                }
            }
            return [AnyObject]()
        }
    
        let array = JSONParseArray(jsonString)
    
        for schedule:AnyObject in array {
            time.timeId = schedule["id"] as Int
            time.day = schedule["day"] as String
            time.busy = schedule["busy"] as Bool
            time.hour = schedule["hour"] as Int
            time.optional = schedule["optional"] as Bool
            
            timeList.append(time)
        }
        return timeList
    }
}