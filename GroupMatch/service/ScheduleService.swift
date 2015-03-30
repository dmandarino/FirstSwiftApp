//
//  ScheduleService.swift
//  MPCRevisited
//
//  Created by Douglas Mandarino on 3/12/15.
//  Copyright (c) 2015 Appcoda. All rights reserved.
//

import Foundation

class ScheduleService {
    
    private let daysOfWeek = ConfigValues.sharedInstance.daysOfWeek
    private let firstHour = ConfigValues.sharedInstance.firstHour
    private let lastHour = ConfigValues.sharedInstance.lastHour
    private let freeTimeIndex = ConfigValues.sharedInstance.freeTimeIndex
    private let busyTimeIndex = ConfigValues.sharedInstance.busyTimeIndex
    private let optionalTimeIndex = ConfigValues.sharedInstance.optionalTimeIndex
    private let numberOfSchedule:Int?
    private let mySchedule = "schedule"
    private let freeTime = "freetime"
    private let scheduleDao = ScheduleDao()
    private let jService = JSONService()
    private var schedule = [Time]()
    
    init() {
        numberOfSchedule = (lastHour - firstHour)*daysOfWeek
    }
    
    //Salva a minha grade de horário. Recebe um array de Int com o índice com o
    //estado do horário. 0 == livre, 1==ocupado, 2==opcional
    func saveMySchedule(grid:[Int]){
        var timeList = getScheduleFromPlist(mySchedule)
        
        if timeList.count == 0 {
            timeList = createDefaultSchedule()
        }
        
        for var i = 0; i < timeList.count; i++ {
            if grid[i] == freeTimeIndex {
                timeList[i].setBusy(false)
                timeList[i].setOptional(false)
            } else if grid[i] == busyTimeIndex {
                timeList[i].setBusy(true)
                timeList[i].setOptional(false)
            } else if grid[i] == optionalTimeIndex{
                timeList[i].setBusy(false)
                timeList[i].setOptional(true)
            }
        }
        
        let jsonString = jService.strinfyTimeArray(timeList)
        scheduleDao.saveScheduleData(jsonString, key: mySchedule)
    }
    
    //Pega os horarios salvos e retorna o indice de cada estado em um array de Int
    func getMySchedule() ->[Int]{
        let timeList = getScheduleFromPlist(mySchedule)
        var arrayIndex = [Int]()
        
        if timeList.count == 0{
            var list = createDefaultSchedule()
            for l in list {
                arrayIndex.append(freeTimeIndex)
            }
        } else {
            for time in timeList{
                if time.isBusy() {
                   arrayIndex.append(busyTimeIndex)
                } else if time.isOptional() {
                    arrayIndex.append(optionalTimeIndex)
                } else {
                    arrayIndex.append(freeTimeIndex)
                }
            }
        }
        return arrayIndex
    }
    
    //Envia meus horários para quem pediu.
    func sendMySchedule()->String{
        return jService.stringfyIntArray(getMySchedule())
    }
    
    //compara os horários de todos e retorna um array de Time com o horário em seu estado comum a todos
    func compareSchedules(receivedDatas:[String]) -> [Response]{
        var commomSchedule = getMySchedule()
        
        for data in receivedDatas{
            var received = jService.convertStringToIntArray(data)
            var aux = commomSchedule
            commomSchedule.removeAll(keepCapacity: false)
            
            for var i=0 ; i < numberOfSchedule ; i++ {
                if (aux[i]==freeTimeIndex && received[i]==freeTimeIndex){
                    commomSchedule.append(freeTimeIndex)
                } else if (aux[i]==busyTimeIndex || received[i]==busyTimeIndex){
                    commomSchedule.append(busyTimeIndex)
                } else {
                    commomSchedule.append(optionalTimeIndex)
                }
            }
        }
        let timeArrayResult = createTimeArrayResponse(commomSchedule)
        return getResponseResult(timeArrayResult)
    }
    
    //Cria uma grade padrão e livre em todos os horários
    private func createDefaultSchedule() ->[Time]{
        var id = 0;
        schedule.removeAll(keepCapacity: false)
        for var i = 0; i<numberOfSchedule; i++ {
            var day = ""
            
            switch (i%daysOfWeek) {
            case (0):
                day = "Monday"
            case (1):
                day = "Tuesday"
            case (2):
                day = "Wednesday"
            case (3):
                day = "Thursday"
            default:
                day = "Friday"
            }
            var hour = (i/(daysOfWeek))+firstHour
            schedule.append(createTime(hour, day: day, id:id))
            id++
        }
        return schedule
    }
    
    // Recebe um vetor com os horarios livres e opcionais dos usuarios
    // retornando outro array com dias e horas livres para exibição
    private func getResponseResult( times:[Time] ) -> [Response] {
        var responseList = [Response]()
        var respAux = Response()
        var isResponseOpen = false
        var timeType = -1
        var freeTime = 0
        var busyTime = 1
        var optionalTime = 2
        
        for( var i:Int = 0 ; i<daysOfWeek ; i++) {
            for( var j:Int = i ; j<times.count ; j += daysOfWeek ) {
                var isEndDay = (j+daysOfWeek) >= times.count
                
                if !times[j].isBusy() && !times[j].isOptional() && (freeTime != timeType){
                    if isResponseOpen {
                        respAux = endResponse(times[j], response: respAux)
                        responseList.append(respAux)
                        isResponseOpen = false
                    }
                    respAux = createNewResponse(times[j])
                    timeType = freeTime
                    isResponseOpen = true
                } else if times[j].isOptional() {
                    if isResponseOpen {
                        respAux = endResponse(times[j], response: respAux)
                        responseList.append(respAux)
                        isResponseOpen = false
                    }
                    respAux = createNewResponse(times[j])
                    respAux.setDay(respAux.getDay() + " (optional)")
                    
                    respAux = endResponse(times[j+daysOfWeek], response: respAux)
                    responseList.append(respAux)

                    timeType = optionalTime
                    isResponseOpen = false

                } else if times[j].isBusy() || (isEndDay && isResponseOpen){
                    if isResponseOpen {
                        respAux = endResponse(times[j], response: respAux)
                        responseList.append(respAux)
                        isResponseOpen = false
                        timeType = busyTime
                    }
                } else if isEndDay {
                    timeType = -1
                }
            }
        }
        for r in responseList {
            println(r.getDay() + " : " + r.getHour())
        }
        return responseList
    }
    
    //Pega o hor;ario do usuário salvo na plist
    private func getScheduleFromPlist(key:String) ->[Time]{
        let string = scheduleDao.loadScheduleData(key)
        var savedArray = [Time]()
        if string != "[]" {
            var savedArray = jService.convertStringToTimeArray(string)
            return savedArray
        }
        return savedArray
    }
    
    //Cria uma entidade Time
    private func createTime(hour:Int, day:String, id:Int) -> Time{
        var time = Time();
        time.setTimeIndex(id)
        time.setHour(hour)
        time.setOptional(false)
        time.setBusy(false)
        time.setDay(day)
        return time
    }
    
    //Cria um array de Time com o estato de cada horário recebido pelo array state
    private func createTimeArrayResponse(state:[Int]) ->[Time]{
        var timeList = createDefaultSchedule()
        
        for var i=0; i < state.count; i++ {
            if state[i] == busyTimeIndex {
                timeList[i].setBusy(true)
            } else if state[i] == optionalTimeIndex {
                timeList[i].setOptional(true)
            }
        }
        return timeList
    }
    
    private func closeResponse(time:Time, response:Response, responseList:[Response]) -> ([Response], Bool){
        var resp = endResponse(time, response: response)
        var newList = responseList
        
        newList.append(resp)
        var isResponseOpen = false
        
        return (newList, isResponseOpen)
    }
    
    private func createNewResponse(time:Time) -> Response {
        var response = Response()
        response.setDay(time.getDay())
        response.setHour("\(time.getHour()):00 - ")
        
        return response
    }

    private func endResponse(time:Time, response:Response) -> Response {
        response.setHour(response.getHour() + "\(time.getHour()):00")

        return response
    }
}