//
//  ScheduleService.swift
//  MPCRevisited
//
//  Created by Douglas Mandarino on 3/12/15.
//  Copyright (c) 2015 Appcoda. All rights reserved.
//

import Foundation

class ScheduleService {
    
    let numberOfSchedule = 75
    let daysOfWeek = 5
    let firstHour = 7
    let lastHour = 21
    private let mySchedule = "schedule"
    private let freeTime = "freetime"
    private let scheduleDao = ScheduleDao()
    private let jService = JSONService()
    private var schedule = [Time]()
    private var id = 0
    
    init() {
        //TESTE DE TRANSFERENCIA DE DADOS DO MPC
        NSNotificationCenter.defaultCenter().addObserverForName("receivedAllData",
        object: nil,
        queue: NSOperationQueue.mainQueue()){
            (notification: NSNotification?) -> Void in
        
           // navigationController!.pushViewController(/*resultViewController*/, animated: true)
            
            let dataArray = notification!.object as Array<String>
            
            let resultData = self.compareSchedules(dataArray)
            
            //metodo do luan
            var result = self.getAllFreeTime(resultData)
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
            var hour = (i/(lastHour-firstHour))+firstHour
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
        var loadedSchedule = scheduleDao.loadScheduleData(mySchedule)
        println(loadedSchedule)
        return jService.stringfyIntArray(getMySchedule())
    }
    
    //compara os horários de todos e retorna um array de Time com o horário em seu estado comum a todos
    func compareSchedules(receivedDatas:[String]) -> [Time]{
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
        
        var timeList = [Time]()
        for (var i = 0; i<numberOfSchedule; i++ ){
            var day = ""
            var hour:Int = (i/daysOfWeek) + firstHour
            
            var div = daysOfWeek
            if i%div == 0 {
                day = "Segunda"
            } else if i%div == 1 {
                day = "Terça"
            } else if i%div == 2 {
                day = "Quarta"
            } else if i%div == 3 {
                day = "Quinta"
            } else if i%div == 4 {
                day = "Sexta"
            }
            
            if (myFree[i] == 0){
                var time = Time()
                time.day = day
                time.hour = hour
                timeList.append(time)
            } else if myFree[i] == 2 {
                var time = Time()
                time.day = day
                time.hour = hour
                time.optional = true
                timeList.append(time)
            } else {
                var time = Time()
                time.day = day
                time.hour = hour
                time.busy = true
                timeList.append(time)
            }
        }
        return timeList
    }
    
    /* Recebe um vetor com os horarios livres e opcionais dos usuarios
        retornando outro array com dias e horas livres para exibição
    */    
    func getAllFreeTime( horas:[Time] ) -> [Response]
    {
        /* Cria o vetor com os resultados */
        var resultados = [Response]()
       
        var flag:Bool = false
        
        var optional:Bool = false
       
        var respAux = Response()
        
        /* Varre as colunas */
        for( var i:Int = 0 ; i<daysOfWeek ; i++)
        {
            /* Varre as linhas */
            for( var j:Int = i ; j<horas.count ; j += daysOfWeek )
            {
                /* Se achar um horario livre */
                if( horas[j].busy == false && flag == false )
                {
                    /* Adiciona o dia na resposta */
                    respAux.dia = horas[j].day
                    
                    /* Adiciona o horário inicial na resposta */
                    respAux.hora = "\(horas[j].hour):00 - "
                    
                    flag = true
                    
                    if( horas[j].optional == true )
                    {
                        respAux.dia += " (Opcional)"
                        optional = true
                    }
        
                }
                else if( (horas[j].busy == true  && flag == true) || ( j+daysOfWeek >= horas.count ))
                {
                    if respAux.hora != ""
                    {
                        respAux.hora += "\(horas[j].hour):00"
                        
                        var novoResp = Response()
                        
                        novoResp.dia = respAux.dia
                        novoResp.hora = respAux.hora
                        
                        flag = false
                        resultados.append(novoResp)
                        respAux.hora = ""
                    }
                }
                else if( (optional == true && ( horas[j].optional == false ) && flag == true) || ( j+daysOfWeek >= horas.count ))
                {
                    if respAux.hora != ""
                    {
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
        
        /* Retorna o vetor de resultados */
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
}