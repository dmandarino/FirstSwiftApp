//
//  File.swift
//  MPCRevisited
//
//  Created by Douglas Mandarino on 3/12/15.
//  Copyright (c) 2015 Appcoda. All rights reserved.
//

import Foundation

class ScheduleDao{

    func saveGameData(jsonString:String, day:String) {
        let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true) as NSArray
        let documentsDirectory = paths.objectAtIndex(0) as NSString
        let path = documentsDirectory.stringByAppendingPathComponent("GameData.plist")
        var dict: NSMutableDictionary = [day: jsonString]
        //saving values
        dict.setObject(jsonString, forKey: day)
        //...
        //writing to GameData.plist
        dict.writeToFile(path, atomically: true)
        let resultDictionary = NSMutableDictionary(contentsOfFile: path)
        resultDictionary?.objectForKey(jsonString)
        println("Saved GameData.plist file is --> \(resultDictionary?.description)")
    }

    func loadGameData() -> String{
        // getting path to GameData.plist
        let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true) as NSArray
        let documentsDirectory = paths[0] as String
        let path = documentsDirectory.stringByAppendingPathComponent("GameData.plist")
        let fileManager = NSFileManager.defaultManager()
        //check if file exists
        if(!fileManager.fileExistsAtPath(path)) {
            // If it doesn't, copy it from the default file in the Bundle
            if let bundlePath = NSBundle.mainBundle().pathForResource("teste2", ofType: "plist") {
                let resultDictionary = NSMutableDictionary(contentsOfFile: bundlePath)
                println("Bundle GameData.plist file is --> \(resultDictionary?.description)")
                fileManager.copyItemAtPath(bundlePath, toPath: path, error: nil)
                println("copy")
            } else {
                println("GameData.plist not found. Please, make sure it is part of the bundle.")
            }
        } else {
            println("GameData.plist already exits at path.")
            // use this to delete file from documents directory
            //fileManager.removeItemAtPath(path, error: nil)
        }
        let resultDictionary = NSMutableDictionary(contentsOfFile: path)
        println("Loaded GameData.plist file is --> \(resultDictionary?.description)")
        
       var myDict = NSDictionary(contentsOfFile: path)
        if let dict = myDict {
            // Use your dict here
            var schedules = dict.allValues
            return schedules.description
            
        } else {
            println("WARNING: Couldn't create dictionary from GameData.plist! Default values will be used!")
        }
        return ""
    }

    
//    func saveSchedule(time:Time) {
//
//        var paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as String
//        var path = paths.stringByAppendingPathComponent("data.plist")
//        var data : NSMutableDictionary? =  NSMutableDictionary(contentsOfFile: path)
//        var fileManager = NSFileManager.defaultManager()
//        if (!(fileManager.fileExistsAtPath(path)))
//        {
//            
//            
//            
//            var bundle : NSString? = NSBundle.mainBundle().pathForResource("data", ofType: "plist")//            var text = String(contentsOfFile: teste!, encoding: NSUTF8StringEncoding, error: nil)!
//            println(bundle)
//            
////            var text = String(contentsOfFile: paths, encoding: NSUTF8StringEncoding, error: nil)!
////
//            
////            var bundle : NSString = NSBundle.mainBundle().pathForResource("data", ofType: "plist")!
////            fileManager.copyItemAtPath(bundle, toPath: paths, error:nil)
//        }
//        
//        data!.setObject(time, forKey: "teste")
//        data!.writeToFile(path, atomically: true)
//    }
//    
//    func getSchedule() {
//        var paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as String
//        var path = paths.stringByAppendingPathComponent("data.plist")
//        let save = NSDictionary(contentsOfFile: path)
//    }
}