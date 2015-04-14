//
//  ScheduleDao.swift
//  MPCRevisited
//
//  Created by Douglas Mandarino on 3/12/15.
//  Copyright (c) 2015 BEPiD. All rights reserved.
//

import Foundation

class ScheduleDao{

    class func saveScheduleData(jsonString:String, key:String) {
        let path = getPath(key)
        var dict: NSMutableDictionary = [key: jsonString]
        //saving values
        dict.setObject(jsonString, forKey: key)
        dict.writeToFile(path, atomically: true)
    }

    class func loadScheduleData(key:String) -> String{
        // getting path to GameData.plist
        let path = getPath(key)
        let fileManager = NSFileManager.defaultManager()
        //check if file exists
        if(!fileManager.fileExistsAtPath(path)) {
            // If it doesn't, copy it from the default file in the Bundle
            if let bundlePath = NSBundle.mainBundle().pathForResource(key, ofType: "plist") {
                let resultDictionary = NSMutableDictionary(contentsOfFile: bundlePath)
                fileManager.copyItemAtPath(bundlePath, toPath: path, error: nil)
            }
        }
        let resultDictionary = NSMutableDictionary(contentsOfFile: path)
        
       var myDict = NSDictionary(contentsOfFile: path)
        if let dict = myDict {
            var schedules: AnyObject? = dict[key]
            if schedules?.description != nil{
                return schedules!.description
            }
        } else {
            println("WARNING: Couldn't create dictionary from GameData.plist! Default values will be used!")
        }
        return ""
    }

    private class func getPath(key:String) -> String{
        let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true) as NSArray
        let documentsDirectory = paths.objectAtIndex(0) as! NSString
        let path = documentsDirectory.stringByAppendingPathComponent(key+".plist")
        return path
    }
}