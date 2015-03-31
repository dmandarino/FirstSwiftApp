//
//  JSONService.swift
//  MPCRevisited
//
//  Created by Douglas Mandarino on 3/14/15.
//  Copyright (c) 2015 Appcoda. All rights reserved.
//

import Foundation

public class JSONService {
    
    init(){
        
    }
    
    //Converter array de AvailablaTime para um String em formato Json
    func stringfyAvailableTimeArray(timeList:[AvailableTime]) -> String{
        var jsonObject: [AnyObject] = []
        
        for time in timeList {
            let schedule:AnyObject = [ "day" : "" ]
            
            jsonObject.append(schedule)
        }
        
        let jsonString = JSONStringify(jsonObject)
        return jsonString
    }
    
    //Converter String em formato Json par um array de AvailablaTime
    func convertStringToAvailableTimeArray(jsonString:String) -> [AvailableTime]{
        var timeList = [AvailableTime]()
//        
//        let array = JSONParseArray(jsonString)
//        for schedule:AnyObject in array {
//            var hr:Int!
//            hr = schedule["index"] as Int
//            
//            timeList.append(hr)
//        }
        return timeList
    }

    
    //Converter array de Int para um String em formato Json
    func stringfyIntArray(timeList:[Int]) -> String{
        var jsonObject: [AnyObject] = []
        
        for time in timeList {
            let schedule:AnyObject = [ "index" : time ]
            
            jsonObject.append(schedule)
        }
        
        let jsonString = JSONStringify(jsonObject)
        return jsonString
    }
    
    //Converter String em formato Json par um array de Int
    func convertStringToIntArray(jsonString:String) -> [Int]{
        var timeList = [Int]()
        
        let array = JSONParseArray(jsonString)
        for schedule:AnyObject in array {
            var hr:Int!
            hr = schedule["index"] as Int
            
            timeList.append(hr)
        }
        return timeList
    }
    
    //Converter array de Time para um String em formato Json
    func strinfyTimeArray(timeList:[Time]) -> String{
        var jsonObject: [AnyObject] = []
    
        for time in timeList {
            let schedule:AnyObject = ["day": (time.getDay()), "hour": (time.getHour()), "optional": (time.isOptional()), "busy": (time.isBusy()), "timeIndex": (time.getTimeIndex())]
        
            jsonObject.append(schedule)
        }
        
        let jsonString = JSONStringify(jsonObject)
        return jsonString
    }
    
    //Converter String em formato Json par um array de Time
    func convertStringToTimeArray(jsonString:String) -> [Time]{
        var timeList = [Time]()
        
        let array = JSONParseArray(jsonString)
        for schedule:AnyObject in array {
            let timeIndex = schedule["timeIndex"] as Int
            let day = schedule["day"] as String
            let hour = schedule["hour"] as Int
            
            var time = Time(timeIndex: timeIndex, day: day, hour: hour)
            time.setBusy(schedule["busy"] as Bool)
            time.setOptional(schedule["optional"] as Bool)
            
            timeList.append(time)
        }
        return timeList
    }
    
    private func JSONStringify(value: AnyObject, prettyPrinted: Bool = false) -> String {
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
    
    private func JSONParseArray(jsonString: String) -> [AnyObject] {
        if let data = jsonString.dataUsingEncoding(NSUTF8StringEncoding) {
            if let array = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions(0), error: nil)  as? [AnyObject] {
                return array
            }
        }
        return [AnyObject]()
    }
}