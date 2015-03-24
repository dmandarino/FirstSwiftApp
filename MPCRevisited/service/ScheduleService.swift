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
    func createDefaultSchedule(){
        for var i = 0; i<5; i++ {
            var day = ""
            var list = createDailyDefaultSchedule()
            
            switch (i) {
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
            
            for time in list{
                time.day = day
                schedule.append(time)
            }
        }
        
        let jsonString = jService.strinfyTimeArray(schedule)
        scheduleDao.saveScheduleData(jsonString, key: mySchedule)
    }
    
    //Salva a minha grade de horário. Recebe um array de Int com o índice com o 
    //estado do horário. 0 == livre, 1==ocupado, 2==opcional
    func saveMySchedule(grid:[Int]){
        var timeList = getScheduleFromPlist(mySchedule)
        
        if timeList.count == 0 {
            createDefaultSchedule()
            timeList = schedule
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
            createDailyDefaultSchedule()
            for (var i=0; i<75; i++) {
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
        for (var i = 0; i<75; i++ ){
            var day = ""
            var hour:Int = (i/5) + 7
            
            if i%5 == 0 {
                day = "Segunda"
            } else if i%5 == 1 {
                day = "Terça"
            } else if i%5 == 2 {
                day = "Quarta"
            } else if i%5 == 3 {
                day = "Quinta"
            } else if i%5 == 4 {
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
        for( var i:Int = 0 ; i<5 ; i++)
        {
            /* Varre as linhas */
            for( var j:Int = i ; j<75 ; j += 5 )
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
                else if( (horas[j].busy == true  && flag == true) || ( j+5 >= 75 ))
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
                else if( (optional == true && ( horas[j].optional == false ) && flag == true) || ( j+5 >= 75 ))
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
    
    //Cria pra cada um dia só de horários livres
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
    private func createTime(hour:Int) -> Time{
        let time = Time();
        time.timeIndex = id
        time.hour = hour
        time.optional = false
        time.busy = false
        return time
    }
}