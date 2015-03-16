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
    let freeTime = "freeTime"
    let scheduleDao = ScheduleDao()
    let jService = JSONService()
    var schedule = [Time]()
    var id = 1
    
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
        let string = scheduleDao.loadGameData()
        println(string)
    }
    
    func saveMySchedule(array:[Int]){
        var timeList = getScheduleFromPlist()
        timeList = setAllFreeDay(timeList)
        
        for day in array{
            timeList[day].busy = true
        }
            
        let jsonString = jService.createJSON(timeList)
        scheduleDao.saveGameData(jsonString, key: mySchedule)
        
        saveFreeTime(timeList)
    }
    
    func getMySchedule(array:[Int]) ->[Int]{
        let timeList = getScheduleFromPlist()
        var arrayIndex = [Int]()
        
        if timeList.count == 0{
            createDailyDefaultSchedule()
        } else {
            for time in timeList{
                if time.busy{
                   arrayIndex.append(time.timeId)
                }
            }
        }
        return arrayIndex
    }
    
    private func saveFreeTime(timeList:[Time]){
        var freeTimeArray = [Time]()
        for time in timeList{
            if !time.busy{
                freeTimeArray.append(time)
            }
        }
        let jsonString = jService.createJSON(freeTimeArray)
        scheduleDao.saveGameData(jsonString, key: freeTime)
    }
    
    private func setAllFreeDay(timeList:[Time]) ->[Time]{
        for day in timeList{
            day.busy = false
        }
        return timeList
    }
    
    private func getScheduleFromPlist() ->[Time]{
        let string = scheduleDao.loadGameData()
        var savedArray = jService.convertToJSON(string)
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
        time.timeId = id
        time.hour = hour
        time.optional = false
        time.busy = false
        return time
    }
}