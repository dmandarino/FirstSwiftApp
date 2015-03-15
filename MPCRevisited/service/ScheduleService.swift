//
//  ScheduleService.swift
//  MPCRevisited
//
//  Created by Douglas Mandarino on 3/12/15.
//  Copyright (c) 2015 Appcoda. All rights reserved.
//

import Foundation

class ScheduleService {
    let scheduleDao = ScheduleDao()
    let jSONService = JSONService()
    var timeList = [Time]()
    
    func createDefaultSchedule(){
        var day:String
        
        createDailyDefaultSchedule()
        
        for (var i = 0; i<=4; i++ ){
       
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
        
            for time in timeList{
                time.day = day
            }
            
            let teste = jSONService.createJSON(timeList)
            let json = jSONService.convertJSON(teste)
        }
    }
    
    func createDailyDefaultSchedule() {
        var time = Time();
        for (var i = 7 ; i<=22 ; i++){
            time = createTime(i)
            timeList.append(time)
        }
    }
    
    func createTime(hour:Int) -> Time{
        let time = Time();
        time.hour = hour
        time.optional = false
        time.busy = false
        return time
    }
}