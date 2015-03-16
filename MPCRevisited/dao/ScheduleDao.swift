//
//  File.swift
//  MPCRevisited
//
//  Created by Douglas Mandarino on 3/12/15.
//  Copyright (c) 2015 Appcoda. All rights reserved.
//

import Foundation

class ScheduleDao{

    func saveGameData(jsonString:String, key:String) {
        let path = getPath()
        var dict: NSMutableDictionary = [key: jsonString]
        //saving values
//        dict.setObject(jsonString, forKey: key)
        dict.writeToFile(path, atomically: true)
    }

    func loadGameData() -> String{
        // getting path to GameData.plist
        let path = getPath()
        let fileManager = NSFileManager.defaultManager()
        //check if file exists
        if(!fileManager.fileExistsAtPath(path)) {
            // If it doesn't, copy it from the default file in the Bundle
            if let bundlePath = NSBundle.mainBundle().pathForResource("Schedule", ofType: "plist") {
                let resultDictionary = NSMutableDictionary(contentsOfFile: bundlePath)
                fileManager.copyItemAtPath(bundlePath, toPath: path, error: nil)
            } else {
                println("Schedule.plist not found. Please, make sure it is part of the bundle.")
            }
        } else {
            println("GameData.plist already exits at path.")
            // use this to delete file from documents directory
            //fileManager.removeItemAtPath(path, error: nil)
        }
        let resultDictionary = NSMutableDictionary(contentsOfFile: path)
//        println("Loaded GameData.plist file is --> \(resultDictionary?.description)")
        
       var myDict = NSDictionary(contentsOfFile: path)
        if let dict = myDict {
            var schedules: AnyObject? = dict["schedule"]
            println(schedules!.description)
            return schedules!.description
            
        } else {
            println("WARNING: Couldn't create dictionary from GameData.plist! Default values will be used!")
        }
        return ""
    }

    private func getPath() -> String{
        let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true) as NSArray
        let documentsDirectory = paths.objectAtIndex(0) as NSString
        let path = documentsDirectory.stringByAppendingPathComponent("Schedule.plist")
        return path
    }
}