//
//  ScheduleService.swift
//  MPCRevisited
//
//  Created by Douglas Mandarino on 3/12/15.
//  Copyright (c) 2015 Appcoda. All rights reserved.
//

import Foundation

class ScheduleService {
    
    private let daysOfWeek = 5
    private let firstHour = 7
    private let lastHour = 22
    private let numberOfSchedule:Int?
    private let mySchedule = "schedule"
    private let freeTime = "freetime"
    private let scheduleDao = ScheduleDao()
    private let jService = JSONService()
    private var schedule = [Time]()
    private var id = 0
    
    init() {
        numberOfSchedule = (lastHour - firstHour)*daysOfWeek
        //TESTE DE TRANSFERENCIA DE DADOS DO MPC
        NSNotificationCenter.defaultCenter().addObserverForName("receivedAllData",
        object: nil,
        queue: NSOperationQueue.mainQueue()){
            (notification: NSNotification?) -> Void in
        
           // navigationController!.pushViewController(/*resultViewController*/, animated: true)
            
            let dataArray = notification!.object as Array<String>
            
//            let resultData = self.compareSchedules(dataArray)
            
            //metodo do luan
            var result = self.compareSchedules(dataArray)
            if result.count == 0{
                var resp = Response()
                resp.dia = "Nenhum Horario Em Comum"
                result.append(Response())
            }
            
            NSNotificationCenter.defaultCenter().postNotificationName("ResultDataProcessed",
                object: result)
        }
    }
    
    //Cria uma grade padrão e livre em todos os horários
    func createDefaultSchedule() ->[Time]{
        schedule.removeAll(keepCapacity: false)
        for var i = 0; i<numberOfSchedule; i++ {
            var day = ""
                
            switch (i%daysOfWeek) {
            case (0):
                day = "Segunda"
            case (1):
                day = "Terça"
            case (2):
                day = "Quarta"
            case (3):
                day = "Quinta"
            default:
                day = "Sexta"
            }
            var hour = (i/(daysOfWeek))+firstHour
            schedule.append(createTime(hour, day: day))
        }
        let jsonString = jService.strinfyTimeArray(schedule)
        scheduleDao.saveScheduleData(jsonString, key: mySchedule)
        return schedule
    }
    
    //Salva a minha grade de horário. Recebe um array de Int com o índice com o 
    //estado do horário. 0 == livre, 1==ocupado, 2==opcional
    func saveMySchedule(grid:[Int]){
        var timeList = getScheduleFromPlist(mySchedule)
        
        if timeList.count == 0 {
            timeList = createDefaultSchedule()
        }
        
        var i = 0
        for time in timeList {
            if grid[i] == 0 {
                time.busy = false
                time.optional = false
            } else if grid[i] == 1 {
                time.busy = true
                time.optional = false
            } else if grid[i] == 2{
                time.busy = false
                time.optional = true
            }
            i++
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
                arrayIndex.append(0)
            }
        } else {
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
    
    //Envia meus horários para quem pediu.
    func sendMySchedule()->String{
        return jService.stringfyIntArray(getMySchedule())
    }
    
    //compara os horários de todos e retorna um array de Time com o horário em seu estado comum a todos
    func compareSchedules(receivedDatas:[String]) -> [Response]{
        var myFree = getMySchedule()
        
        var received:[Int]
        for r in receivedDatas{
            received = jService.convertStringToIntArray(r)
            var aux = myFree
            myFree.removeAll(keepCapacity: false)
            
            for var i=0 ; i<received.count ; i++ {
                if (aux[i]==0 && received[i]==0){
                    myFree.append(0)
                } else if (aux[i]==1 || received[i]==1){
                    myFree.append(1)
                } else {
                    myFree.append(2)
                }
            }
        }
        let groupTimeState = myFree
        let timeArrayResult = createTimeArrayResponse(groupTimeState)
        return getResponseResult(timeArrayResult)
    }
    
    /* Recebe um vetor com os horarios livres e opcionais dos usuarios
        retornando outro array com dias e horas livres para exibição
    */    
    private func getResponseResult( horas:[Time] ) -> [Response] {
        var resultados = [Response]()
        var flag:Bool = false
        var optional:Bool = false
        var respAux = Response()
        
        
        for( var i:Int = 0 ; i<daysOfWeek ; i++) {
            for( var j:Int = i ; j<horas.count ; j += daysOfWeek ) {
                if( horas[j].busy == false && flag == false ) {
                    respAux.dia = horas[j].day
                    
                    respAux.hora = "\(horas[j].hour):00 - "
                    
                    flag = true
                    
                    if( horas[j].optional == true ) {
                        respAux.dia += " (Opcional)"
                        optional = true
                    }
                }
                else if( (horas[j].busy == true  && flag == true) || ( j+daysOfWeek >= horas.count )) {
                    if respAux.hora != "" {
                        respAux.hora += "\(horas[j].hour):00"
                        
                        var novoResp = Response()
                        
                        novoResp.dia = respAux.dia
                        novoResp.hora = respAux.hora
                        
                        flag = false
                        resultados.append(novoResp)
                        respAux.hora = ""
                    }
                }
                else if( (optional == true && ( horas[j].optional == false ) && flag == true) || ( j+daysOfWeek >= horas.count )) {
                    if respAux.hora != "" {
                        respAux.hora += "\(horas[j].hour):00"
                        
                        var novoResp = Response()
                        
                        novoResp.dia = respAux.dia
                        novoResp.hora = respAux.hora
                        
                        flag = false
                        optional = false
                        resultados.append(novoResp)
                        respAux.hora = ""
                    }
                }
            }
        }
        return resultados
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
    private func createTime(hour:Int, day:String) -> Time{
        var time = Time();
        time.timeIndex = id
        time.hour = hour
        time.optional = false
        time.busy = false
        time.day = day
        id++
        return time
    }
    
    //Cria um array de Time com o estato de cada horário recebido pelo array state
    private func createTimeArrayResponse(state:[Int]) ->[Time]{
        let mySavedSchedule = scheduleDao.loadScheduleData(mySchedule)
        var timeList = jService.convertStringToTimeArray(mySavedSchedule)
        
        for var i=0; i<state.count; i++ {
            if state[i] == 0 {
                timeList[i].busy = false
                timeList[i].optional = false
            } else if state[i] == 1 {
                timeList[i].optional = false
                timeList[i].busy = true
            } else {
                timeList[i].busy = false
                timeList[i].optional = true
            }
        }
        return timeList
    }
}