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
    
    /* Recebe um vetor com os horarios livres e opcionais dos usuarios
        retornando outro array com dias e horas livres para exibição
    */
    func getAllFreeTime( horas:[Time] ) -> [resposta]
    {
        /* Cria o vetor com os resultados */
        var resultados = [resposta]()
        
        
        for( var x:Int = 0 ; x < horas.count ; x++ )
        {
            /* Se achar um horario livre */
            if( horas[x].busy == false && horas[x].optional == false)
            {
                /* Cria uma nova entrada para ser introduzida no array */
                var novaResp = resposta()
                
                /* Adiciona o dia na resposta */
                novaResp.dia = horas[x].day
                
                /* Adiciona o horário inicial na resposta */
                novaResp.hora = "Horário Inicial: \(horas[x].hour):00 "
                
                /* Olha os próximos elementos em busca de continuidade de horas livres até o final do dia
                    ou até achar um horario não livre
                */
                for( var y:Int = x + 1 ; horas[y].hour != 7 ; y++ )
                {
                    /* Achando um horário não livre ou o "fim" do dia */
                    if( horas[y].busy || horas[y].optional || horas[y].hour == 21)
                    {
                        /* Adiciona esse horário como final */
                        novaResp.hora += "Horário Final: \(horas[y].hour):00"
                        /* muda o valor do x para y e sai desse loop interno */
                        x = y
                        break;
                    }
                }
                
                /* Adiciona essa resposta nos resultados */
                resultados.append(novaResp)
                
            }
            else if( horas[x].optional == true )
            {
                /* Achando um opcional faz a mesma coisa, mas como opcional */
                /* Cria uma nova entrada para ser introduzida no array */
                var novaOpcional = resposta()
                
                /* Adiciona o dia na resposta com tag de opcional */
                novaOpcional.dia = horas[x].day + "(Opcional)"
                
                /* Adiciona o horário inicial na resposta */
                novaOpcional.hora = "Horário Inicial: \(horas[x].hour):00 "
                
                /* Olha os próximos elementos em busca de continuidade de horas opcionais até o final do dia
                    ou até achar um horario não opcional
                */
                for( var y:Int = x + 1 ; horas[y].hour != 7 ; y++ )
                {
                    /* Achando um horário não opcional ou o "fim" do dia */
                    if( horas[y].busy || horas[y].optional || horas[y].hour == 21)
                    {
                        /* Adiciona esse horário como final */
                        novaOpcional.hora += "Horário Final: \(horas[y].hour):00"
                        /* muda o valor do x para y e sai desse loop interno */
                        x = y
                        break;
                    }
                }
                
                /* Adiciona essa resposta nos resultados */
                resultados.append(novaOpcional)
            }
            
        }
    
        /* Retorna o vetor de resultados */
        return resultados
    }
    
    
}

class resposta
{
    var dia: String = ""
    var hora: String = ""
}