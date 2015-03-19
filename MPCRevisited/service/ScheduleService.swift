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
        queue: NSOperationQueue.mainQueue())
        { (notification: NSNotification?) -> Void in
        
           // navigationController!.pushViewController(/*resultViewController*/, animated: true)
            
            let dataArray = notification!.object as Array<String>
            
//            for data in dataArray{
//                println(data)
//            }
            
            let resultData = self.compareSchedules(dataArray)
            
            //metodo do luan
            var result = self.getAllFreeTime(resultData)
            if result.count == 0{
                var resp = resposta()
                resp.dia = "Nenhum Horario Em Comum"
                result.append(resposta())
            }
//            println(result.count)
////            println(result.description)
//            for r in result {
//                println(r.dia)
//                println(r.hora)
//            }
            
            NSNotificationCenter.defaultCenter().postNotificationName("ResultDataProcessed",
                object: result)
        }
    }
    func createDefaultSchedule(){
        var day:String
        
        createAllFree()
        
        let jsonString = jService.createJSON(schedule)
        scheduleDao.saveGameData(jsonString, key: mySchedule)
    }
    
    func saveMySchedule(grid:[Int]){
        var timeList = getScheduleFromPlist(mySchedule)
        
        if timeList.count == 0 {
            createAllFree()
        }
        
        if schedule.count > 0 {
            timeList = schedule
        }
        
        for var i=0 ; i<timeList.count ; i++  {
            if grid[i] == 0 {
                timeList[i].busy = false
                timeList[i].optional = false
            } else if grid[i] == 1 {
                timeList[i].busy = true
                timeList[i].optional = false
            } else if grid[i] == 2{
                timeList[i].busy = false
                timeList[i].optional = true
            }
        }
        
        let jsonString = jService.createJSON(timeList)
        scheduleDao.saveGameData(jsonString, key: mySchedule)
        
        saveFreeTime()
    }
    
    func getMySchedule() ->[Int]{
        let timeList = getScheduleFromPlist(mySchedule)
        var arrayIndex = [Int]()
        
        if timeList.count == 0{
            createDailyDefaultSchedule()
            for (var i=0; i<75; i++) {
                arrayIndex.append(0)
            }
        } else {
//             println(jService.createJSON(timeList))
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
        return jService.createIntJson(getMySchedule())
    }
    
    func compareSchedules(stringoes:[String]) -> [Time]{
        var myFreeString = sendMyFreeTime()
        var myFree = jService.convertIntToJSON(myFreeString)
        
        var received:[Int]
        for stringao in stringoes{
            received = jService.convertIntToJSON(stringao)
            var aux = myFree
            println(aux)
            println("==========")
            println(received)
            
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
            
//            for a in aux{
//                for r in received {
//                    if (a==0 && r==0){
//                        myFree.append(0)
//                        break
//                    } else if (a==1 || r==1){
//                        myFree.append(1)
//                        break
//                    } else {
//                        myFree.append(2)
//                    }
//                }
//            }
        }
        
        println(myFree.description)
        
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
    
    private func saveFreeTime(){
        var timeList = getScheduleFromPlist(freeTime)
        
        if timeList.count == 0 {
            createAllFree()
        }
        
        if schedule.count > 0 {
            timeList = schedule
        }
        
        var freeTimeArray = [Time]()
        
        for time in timeList{
            if time.busy == false {
                freeTimeArray.append(time)
                println(time.day)
                println(time.hour)
            } else if time.optional == true{
                freeTimeArray.append(time)
                println(time.day)
                println(time.hour)
            }
        }
        
        let jsonString = jService.createJSON(freeTimeArray)
        scheduleDao.saveGameData(jsonString, key: freeTime)
    }
    
    private func getScheduleFromPlist(key:String) ->[Time]{
        let string = scheduleDao.loadScheduleData(key)
        var savedArray = [Time]()
        if string != "[]" {
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
//    func getAllFreeTime( horas:[Time] ) -> [resposta]
//    {
//        /* Cria o vetor com os resultados */
//        var resultados = [resposta]()
//        
//        /* Cria um novo vetor organizado dos horarios  */
//        var horaOrganizada = [Time]()
//        
//        /* Guarda a hora atual */
//        var horaAtual = 0
//        
//        /* Varre as colunas */
//        for( var i:Int = 0 ; i<5 ; i++)
//        {
//            /* Pega o indice do inicio do dia */
//            horaAtual = i;
//            /* Varre as linhas */
//            for( var j:Int = 0 ; j < 15 ; j++ )
//            {
//                /* Se achar um horario livre */
//                if( horas[horaAtual].busy == false && horas[horaAtual].optional == false)
//                {
//                    /* Cria uma nova entrada para ser introduzida no array */
//                    var novaResp = resposta()
//                    
//                    /* Adiciona o dia na resposta */
//                    novaResp.dia = horas[horaAtual].day
//                    
//                    /* Adiciona o horário inicial na resposta */
//                    novaResp.hora = "Horário Inicial: \(horas[horaAtual].hour):00 "
//                    
//                    /* Olha os próximos elementos em busca de continuidade de horas livres até o final do dia
//                    ou até achar um horario não livre
//                    */
//                    for( var y:Int = horaAtual + 5 ; 15 - j ; y += 5 )
//                    {
//                        /* Achando um horário não livre ou o "fim" do dia */
//                        if( horas[y].busy || horas[y].optional || horas[y].hour == 21)
//                        {
//                            /* Adiciona esse horário como final */
//                            novaResp.hora += "Horário Final: \(horas[y].hour):00"
//                            /* muda o valor do x para y e sai desse loop interno */
//                            x = y
//                            break;
//                        }
//                    }
//                    
//                    /* Adiciona essa resposta nos resultados */
//                    resultados.append(novaResp)
//                    
//                }
//                else if( horas[horaAtual].optional == true )
//                {
//                    /* Achando um opcional faz a mesma coisa, mas como opcional */
//                    /* Cria uma nova entrada para ser introduzida no array */
//                    var novaOpcional = resposta()
//                    
//                    /* Adiciona o dia na resposta com tag de opcional */
//                    novaOpcional.dia = horas[horaAtual].day + "(Opcional)"
//                    
//                    /* Adiciona o horário inicial na resposta */
//                    novaOpcional.hora = "Horário Inicial: \(horas[horaAtual].hour):00 "
//                    
//                    /* Olha os próximos elementos em busca de continuidade de horas opcionais até o final do dia
//                    ou até achar um horario não opcional
//                    */
//                    for( var y:Int = x + 1 ; horas[y].hour != 7 || y == 75 ; y++ )
//                    {
//                        /* Achando um horário não opcional ou o "fim" do dia */
//                        if( horas[y].busy || horas[y].optional || horas[y].hour == 21)
//                        {
//                            /* Adiciona esse horário como final */
//                            novaOpcional.hora += "Horário Final: \(horas[y].hour):00"
//                            /* muda o valor do x para y e sai desse loop interno */
//                            x = y
//                            break;
//                        }
//                    }
//                    
//                    /* Adiciona essa resposta nos resultados */
//                    resultados.append(novaOpcional)
//                }
//                
//                /* Adiciona 5 no indice da hora atual */
//                horaAtual += 5
//            }
//            
//        }
//        
//    
//        /* Retorna o vetor de resultados */
//        return resultados
//    }
    
    func getAllFreeTime( horas:[Time] ) -> [resposta]
    {
        /* Cria o vetor com os resultados */
        var resultados = [resposta]()
       
        var flag:Bool = false
        
        var optional:Bool = false
       
        var respAux = resposta()
        
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
                        
                        var novoResp = resposta()
                        
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
                        
                        var novoResp = resposta()
                        
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

    
     private func createAllFree(){
        for (var i = 0; i<=4; i++ ){
            var day = ""
            var list = createDailyDefaultSchedule()
            
            if(i==0) {
                day = "Segunda"
            } else if (i==1){
                day = "Terça"
            } else if (i==2){
                day = "Quarta"
            } else if (i==3){
                day = "Quinta"
            } else {
                day = "Sexta"
            }
            
            for time in list{
                time.day = day
                schedule.append(time)
            }
        }
    }
}

class resposta
{
    var dia: String = ""
    var hora: String = ""
}


