//
//  MPCManager.swift
//  MPCRevisited
//
//  Created by Victor Yves Crispim on 03/5/15.
//  Copyright (c) 2015 BEPiD. All rights reserved.
//

import UIKit

import MultipeerConnectivity



//Class responsible for managing the MPC framework
class MPCManager: NSObject, MCSessionDelegate{
    
    //MARK: Private attributes
    
    private var matchDataArray = [String]()
    private var receivedDataCount = 0
    let scheduleService = ScheduleService()
    
    //MARK: Public attributes
    
    var session: MCSession?
    var peer: MCPeerID?
    var browser: MCBrowserViewController?
    var advertiser: MCAdvertiserAssistant?
    var foundPeers = [MCPeerID]()

    
    //MARK: Initialzer method
    
    func setupPeerAndSessionWithDisplayName(displayName: String){
        
        peer = MCPeerID(displayName: displayName)
        session = MCSession(peer: peer)
        session!.delegate = self;
    }
    
    
    //MARK: MCBrowserViewController methods
    
    func setupMCBrowser(){
    
        browser = MCBrowserViewController(serviceType: "teste", session: session)
        browser?.title = "Group Finder"
    }
    
    
    //MARK: MCAdvertiserAssistant methods

    func advertiseSelf(shouldAdvertise:Bool){
        
        if shouldAdvertise{
            
            advertiser = MCAdvertiserAssistant(serviceType: "teste", discoveryInfo: nil, session: session)
            advertiser?.start()
        }
        else{
            
            advertiser?.stop()
            advertiser = nil
        }
    }

    
    //MARK: MCSessionDelegate methods
    
    func session(session: MCSession!, peer peerID: MCPeerID!, didChangeState state: MCSessionState) {
        
        var peerInfo: [String:NSObject] = ["peerID":peerID, "state":state.rawValue]
    
        NSNotificationCenter.defaultCenter().postNotificationName("MCDidChangeStateNotification", object: nil, userInfo: peerInfo)
    }
    
    func session(session: MCSession!, didReceiveData data: NSData!, fromPeer peerID: MCPeerID!) {
  
        let receivedMessage:AnyObject = NSKeyedUnarchiver.unarchiveObjectWithData(data) as AnyObject!
        let requestType = receivedMessage["request"] as String
        
        if requestType == "ScheduleDataRequest"{

            let scheduleData: [String:AnyObject] =  [    "request":"ScheduleDataSent",
                                                        "data"   :scheduleService.sendMySchedule()
                                                    ]
            
            //            var host = [MCPeerID]()
            //            host.append(peerID)
            var host = [peerID]
            
            sendData(scheduleData, toPeers: host)
        }
        else if requestType == "ScheduleDataSent"{
            
            //decrease the counter
            --receivedDataCount
        
            //save the received data
            matchDataArray.append(receivedMessage["data"] as String)
            
            //if data from all requested peers arrived
            if (receivedDataCount == 0){
                
                var resultSchedule = scheduleService.compareSchedules(matchDataArray)
                
                //teste
                for data in resultSchedule{
                    
                    println(data.getDay() + "   " + data.getHour() + "\n")
                }
            
                let encodedSchedule = encodeScheduleForTransfer(schedule: resultSchedule)
                
                let data: [String:AnyObject] =  [   "request":"ResultDataProcessed",
                                                    "data"   :encodedSchedule
                    
                                                ]
                
                sendData(data, toPeers: session.connectedPeers as [MCPeerID])
                
                NSNotificationCenter.defaultCenter().postNotificationName("ResultDataProcessed", object: resultSchedule)
            }
        }
        //TODO: aqui é onde os cliente recebem a resposta.
        //Voltamos ao problema de ter que instanciar o ResultViewController
        else if requestType == "ResultDataProcessed"{
      
            let resultSchedule = receivedMessage["data"] as [Response]
            
            //            let storyboard = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle())
            //            let resultViewController = storyboard.instantiateViewControllerWithIdentifier("ResultViewController") as UIViewController
            //
            //            storyboard.
            
            NSNotificationCenter.defaultCenter().postNotificationName("ResultDataProcessed", object: resultSchedule)
        }
    }
    
    /*Methods to handle file and data stream transfer. Not used, but needed*/
    func session(session: MCSession!, didStartReceivingResourceWithName resourceName: String!, fromPeer peerID:
        
        MCPeerID!, withProgress progress: NSProgress!) { }
    
    func session(session: MCSession!, didFinishReceivingResourceWithName resourceName: String!, fromPeer peerID: MCPeerID!, atURL localURL: NSURL!, withError error: NSError!) { }
    
    func session(session: MCSession!, didReceiveStream stream: NSInputStream!, withName streamName: String!, fromPeer peerID: MCPeerID!) { }

    
    //MARK: Custom methods

    func requestScheduleDataFromConnectedPeers() -> Bool{
    
        var message: Dictionary<String,AnyObject> = ["request":"ScheduleDataRequest"]
        
        //guarda o numero de peers conectados: ou seja,
        //o numero de respostas que tem que ser recebidas
        receivedDataCount = session!.connectedPeers.count
        
        let dataToSend = NSKeyedArchiver.archivedDataWithRootObject(message)
        var error: NSError?
    
        //OBS: pode dar problema se connectedPeers estiver vazio. Tratar na interface
        if !session!.sendData(  dataToSend,
                                toPeers: session!.connectedPeers,
                                withMode: MCSessionSendDataMode.Reliable,
                                error: &error) {
                
                println(error?.localizedDescription)
                return false
        }
        
        return true
    }
    
    private func sendData(data: Dictionary<String,AnyObject>, toPeers peers: [MCPeerID!]) -> Bool{
        
        var encodedData:[AnyObject] = []
        var aux: AnyObject = ["request":data["request"]!]
        var aux2: AnyObject = ["data":data["data"]!]
        
        encodedData.append(aux)
        encodedData.append(aux2)
        
        let dataToSend = NSKeyedArchiver.archivedDataWithRootObject(data)
        var error: NSError?
    
        if !session!.sendData(  dataToSend,
                                toPeers: peers,
                                withMode: MCSessionSendDataMode.Reliable,
                                error: &error) {
                
                println(error?.localizedDescription)
                
                return false
        }
        return true
    }

    private func encodeScheduleForTransfer(schedule responseArray: [Response]) -> [AnyObject]{
        
        var encodedResponseArray:[AnyObject] = []
        
        for response in responseArray{
            
            let encodedResponse:AnyObject = ["dia":response.getDay(), "hora":response.getHour()]
            
            encodedResponseArray.append(encodedResponse)
            
        }
        return encodedResponseArray
    }
}