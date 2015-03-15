//
//  MPCManager.swift
//  MPCRevisited
//
//  Created by Gabriel Theodoropoulos on 11/1/15.
//  Copyright (c) 2015 Appcoda. All rights reserved.
//

import UIKit
import MultipeerConnectivity

//Class responsible for managing the MPC framework
class MPCManager: NSObject, MCSessionDelegate{
    
    //MARK: Private attributes
    private var matchDataArray = [String]()
    private var receivedDataCount = 0
    
    //MARK: Public attributes
    var session: MCSession?
    
    var peer: MCPeerID?
    
    var browser: MCBrowserViewController?
    
    var advertiser: MCAdvertiserAssistant?
    
    var foundPeers = [MCPeerID]()
    
    var invitationHandler: ((Bool, MCSession!)->Void)!
    
    //MARK: Initialzer method
    
    func setupPeerAndSessionWithDisplayName(displayName: String){

        peer = MCPeerID(displayName: displayName)
    
        session = MCSession(peer: peer)
    
        session!.delegate = self;
    }
    
    //MARK: MCBrowserViewController methods
    
    func setupMCBrowser(){
        browser = MCBrowserViewController(serviceType: "teste", session: session)
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
        
        NSNotificationCenter.defaultCenter().postNotificationName(
            "MCDidChangeStateNotification", object: nil, userInfo: peerInfo)
    }
    
    func session(session: MCSession!, didReceiveData data: NSData!, fromPeer peerID: MCPeerID!) {

        let receivedMessage = NSKeyedUnarchiver.unarchiveObjectWithData(data) as Dictionary<String,String>
        
        let requestType = receivedMessage["request"]
        
        if requestType! == "MatchDataRequest"{
            
            sendMatchData(toPeer: peerID)
        }
        else if requestType! == "SendMatchDataRequest"{
         
            //decrease the counter
            --receivedDataCount
            //save the received data
            matchDataArray.append(receivedMessage["data"]!)
            
            //if data from all requested peers arrived
            if (receivedDataCount == 0){
                NSNotificationCenter.defaultCenter().postNotificationName("receivedAllData",
                                                                        object: matchDataArray)
            }
        }
    }
    
    /*Methods to handle file and data stream transfer. Not used, but needed*/
    func session(session: MCSession!, didStartReceivingResourceWithName resourceName: String!, fromPeer peerID:
        MCPeerID!, withProgress progress: NSProgress!) { }
    
    func session(session: MCSession!, didFinishReceivingResourceWithName resourceName: String!, fromPeer peerID: MCPeerID!, atURL localURL: NSURL!, withError error: NSError!) { }
    
    func session(session: MCSession!, didReceiveStream stream: NSInputStream!, withName streamName: String!, fromPeer peerID: MCPeerID!) { }
    
    
    //MARK: Custom methods
   
    func requestMatchDataFromConnectedPeers() -> Bool{
        
        //envia mensagem requisitando os dados
        let data: Dictionary<String,String> = ["request":"MatchDataRequest"]

        //guarda o numero de peers conectados: ou seja,
        //o numero de respostas que tem que ser recebidas
        receivedDataCount = session!.connectedPeers.count
        
        let dataToSend = NSKeyedArchiver.archivedDataWithRootObject(data)
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
    
    //envia os dados necessários para match para o peer host
    private func sendMatchData(toPeer peer: MCPeerID) -> Bool{
        
        let data: [String:String] = [   "request":"SendMatchDataRequest",
                                        "data":"teste"]
        
        //Aqui que vem a string do JSON
        let dataToSend = NSKeyedArchiver.archivedDataWithRootObject(data)
        let peersArray = NSArray(object: peer)
        var error: NSError?
        
        //OBS: pode dar problema se connectedPeers estiver vazio. Tratar na interface
        if !session!.sendData(  dataToSend,
                                toPeers: peersArray,
                                withMode: MCSessionSendDataMode.Reliable,
                                error: &error) {
                
                println(error?.localizedDescription)
                return false
        }
        return true
    }
}