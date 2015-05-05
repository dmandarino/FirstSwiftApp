//
//  MPCManager.swift
//  MPCRevisited
//
//  Created by Victor Yves Crispim on 03/5/15.
//  Copyright (c) 2015 BEPiD. All rights reserved.
//

import UIKit
import MultipeerConnectivity


class MPCManager: NSObject, MCSessionDelegate{
    
    //MARK: Private attributes
    
    private var matchDataArray = [String]()
    private var receivedDataCount = 0
    private var delegate: MPCManagerDelegate?
    let scheduleService = ScheduleService()
    
    //MARK: Public attributes
    
    var session: MCSession?
    var peer: MCPeerID?
    var browserViewController: MCBrowserViewController?
    var advertiser: MCAdvertiserAssistant?
    var foundPeers = [MCPeerID]()

    
    //MARK: Initializer method
    
    init(displayName: String, andDelegate delegate: MPCManagerDelegate){
        
        super.init()
        
        peer = MCPeerID(displayName: displayName)
        session = MCSession(peer: peer)
        session!.delegate = self;

        self.delegate = delegate
    }
    
    //MARK: MCBrowserViewController methods
    
    func setupMCBrowser(){
    
        browserViewController = MCBrowserViewController(serviceType: "Match", session: session)
        browserViewController?.title = NSLocalizedString("SearchViewTitle", comment: "SearchViewTitle")
    }
    
    
    //MARK: MCAdvertiserAssistant methods

    func advertiseSelf(shouldAdvertise:Bool){
        
        if shouldAdvertise{
            
            advertiser = MCAdvertiserAssistant(serviceType: "Match", discoveryInfo: nil, session: session)
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
    
        delegate?.mpcManagerPeerDidChangedState(peerInfo)
    }
    
    func session(session: MCSession!, didReceiveData data: NSData!, fromPeer peerID: MCPeerID!) {
  
        let receivedMessage:AnyObject = NSKeyedUnarchiver.unarchiveObjectWithData(data) as AnyObject!
        let requestType = receivedMessage["request"] as! String
        
        if requestType == "ScheduleDataRequest"{

            let scheduleData: [String:AnyObject] =  [   "request":"ScheduleDataSent",
                                                        "data"   :scheduleService.sendMySchedule()
                                                    ]
            var host = [peerID]
            
            sendData(scheduleData, toPeers: host)
        }
        else if requestType == "ScheduleDataSent"{
            
            --receivedDataCount
        
            //save the received data
            matchDataArray.append(receivedMessage["data"] as! String)
            
            //if data from all requested peers arrived
            if (receivedDataCount == 0){
                
                var resultSchedule = scheduleService.compareSchedules(matchDataArray)
                
                //scheduleService.stringfyResponseArray()
                
                let json = JSONService()
                
                var encodedSchedule = json.stringfyAvailableTimeArray(resultSchedule)
                
                let dataToSend: [String:AnyObject] =    [   "request":"ResultDataProcessed",
                                                            "data"   :encodedSchedule
                                                        ]
                
                sendData(dataToSend, toPeers: session.connectedPeers as! [MCPeerID])
                
                delegate?.mpcManagerPresentResultScheduleWithData(resultSchedule)
            }
        }
        else if requestType == "ResultDataProcessed"{
      
            let json = JSONService()
            
            let decodedSchedule = json.convertStringToAvailableTimeArray(receivedMessage["data"] as! String)
            delegate?.mpcManagerPresentResultScheduleWithData(decodedSchedule)
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
    
    
    func resetDisplayNameTo(newName: String){
        
        if newName != ""{
            
            //shut down all functionality
            browserViewController = nil
            session = nil
            peer = nil
            advertiseSelf(false)
            
            //recreate everything with new name
            peer = MCPeerID(displayName: newName)
            session = MCSession(peer: peer)
            session!.delegate = self;
            setupMCBrowser()
        }
    }
    
    
    //MARK: Private Methods
    
    private func sendData(data: Dictionary<String,AnyObject>, toPeers peers: [MCPeerID!]) -> Bool{
        
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
}