//
//  ScheduleService.swift
//  MPCRevisited
//
//  Created by Douglas Mandarino on 3/12/15.
//  Copyright (c) 2015 Appcoda. All rights reserved.
//

import Foundation

class ScheduleService {
    let mySchedule = "schedule"
    let freeTime = "freetime"
    let scheduleDao = ScheduleDao()
    let jService = JSONService()
    var schedule = [Time]()
    var id = 0
    
    func createDefaultSchedule(){
        var day:String
        
        for (var i = 0; i<=4; i++ ){
            var list = createDailyDefaultSchedule()
            
            if(i==0) {
                  day = "segunda"
            } else if (i==1){
                day = "terca"
            } else if (i==2){
                day = "quarta"
            } else if (i==3){
                day = "quinta"
            } else {
                day = "sexta"
            }
        
            for time in list{
                time.day = day
                schedule.append(time)
            }
        }
        let jsonString = jService.createJSON(schedule)
        scheduleDao.saveGameData(jsonString, key: mySchedule)
    }
    
    func saveMySchedule(grid:[Int]){
        var timeList = getScheduleFromPlist()
        var i = 0
        
        for time in timeList {
            if grid[i] == 0 {
                time.busy = false
                time.optional = false
            } else if grid[i] == 1 {
                time.busy = true
                time.optional = false
            } else {
                time.busy = false
                time.optional = true
            }
            i++
        }
        
        let jsonString = jService.createJSON(timeList)
        scheduleDao.saveGameData(jsonString, key: mySchedule)
        saveFreeTime(timeList)
    }
    
    func getMySchedule() ->[Int]{
        let timeList = getScheduleFromPlist()
        var arrayIndex = [Int]()
        
        if timeList.count == 0{
            createDailyDefaultSchedule()
            for (var i=0; i<74; i++) {
                arrayIndex.append(0)
            }
        } else {
             println(jService.createJSON(timeList))
            for time in timeList{
                if time.busy == true{
                   arrayIndex.append(1)
                } else if time.optional == true{
                    arrayIndex.append(2)
                } else {
                    arrayIndex.append(0)
                }
            }
        }
        return arrayIndex
    }
    
    func sendMyFreeTime()->String{
        return scheduleDao.loadScheduleData(freeTime)
    }
    
    func compareSchedules(stringoes:[String]) -> [Time]{
        let myFreeString = sendMyFreeTime()
        var myFree = jService.convertToJSON(myFreeString)
        var received:[Time]
        for stringao in stringoes{
            println(stringao)
            received = jService.convertToJSON(stringao)
            var aux = myFree
            
            myFree.removeAll(keepCapacity: false)
            println(myFree.count)
            for a in aux{
                for r in received {
                    if a.timeIndex == r.timeIndex {
                        myFree.append(r)
                        break
                    }
                }
            }
        }
        return myFree
    }
    
    private func saveFreeTime(timeList:[Time]){
        var freeTimeArray = [Time]()
        
        for time in timeList{
            if time.busy == false || time.optional == true{
                freeTimeArray.append(time)
            }
        }
        
        let jsonString = jService.createJSON(freeTimeArray)
        scheduleDao.saveGameData(jsonString, key: freeTime)
    }
    
    private func getScheduleFromPlist() ->[Time]{
        let string = scheduleDao.loadScheduleData(mySchedule)
        var savedArray = [Time]()
        if string != "" {
            var savedArray = jService.convertToJSON(string)
            return savedArray
        }
        return savedArray
    }
    
    private func createDailyDefaultSchedule() ->[Time]{
        var time = Time();
        var timeList = [Time]()
        for (var i = 7 ; i<=21 ; i++){
            time = createTime(i)
            timeList.append(time)
            id++
        }
        return timeList
    }
    
    private func createTime(hour:Int) -> Time{
        let time = Time();
        time.timeIndex = id
        time.hour = hour
        time.optional = false
        time.busy = false
        return time
    }
}