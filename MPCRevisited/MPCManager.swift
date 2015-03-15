//
//  MPCManager.swift
//  MPCRevisited
//
//  Created by Gabriel Theodoropoulos on 11/1/15.
//  Copyright (c) 2015 Appcoda. All rights reserved.
//

import UIKit
import MultipeerConnectivity


//protocol MPCManagerDelegate {
//    
//    func foundPeer()
//    
//    func lostPeer()
//    
//    func invitationWasReceived(fromPeer: String)
//    
//    func connectedWithPeer(peerID: MCPeerID)
//}


class MPCManager: NSObject, MCSessionDelegate{

//    var delegate: MPCManagerDelegate?
    
    var session: MCSession?
    
    var peer: MCPeerID?
    
    var browser: MCBrowserViewController?
    
    var advertiser: MCAdvertiserAssistant?
    
    var foundPeers = [MCPeerID]()
    
    var invitationHandler: ((Bool, MCSession!)->Void)!
    
    
//    override init() {
//        
//        peer = MCPeerID(displayName: displayName)
//        
//        session = MCSession(peer: peer)
//        
//        browser = MCBrowserViewController(serviceType: "group-match", session: session)
//        
//        advertiser = MCAdvertiserAssistant(serviceType: "group-match", discoveryInfo: nil, session: session)
//
//        advertiser.start()
//        
//        super.init()
//        session.delegate = self
//    }
    
    func setupPeerAndSessionWithDisplayName(displayName: String){

        peer = MCPeerID(displayName: displayName)
    
        session = MCSession(peer: peer)
    
        session!.delegate = self;
    }
    
    func setupMCBrowser(){
        browser = MCBrowserViewController(serviceType: "teste", session: session)
    }
    
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
    
    // MARK: MCSessionDelegate method implementation
    
    func session(session: MCSession!, peer peerID: MCPeerID!, didChangeState state: MCSessionState) {

        var peerInfo: [String:NSObject] = ["peerID":peerID, "state":state.rawValue]
        
        NSNotificationCenter.defaultCenter().postNotificationName(
            "MCDidChangeStateNotification", object: nil, userInfo: peerInfo)
    }
    
    func session(session: MCSession!, didReceiveData data: NSData!, fromPeer peerID: MCPeerID!) {
       
        let dictionary: [String: AnyObject] = ["data": data, "fromPeer": peerID]
        
        NSNotificationCenter.defaultCenter().postNotificationName("receivedMPCDataNotification", object: dictionary)
    }
    
    func session(session: MCSession!, didStartReceivingResourceWithName resourceName: String!, fromPeer peerID:
        MCPeerID!, withProgress progress: NSProgress!) { }
    
    func session(session: MCSession!, didFinishReceivingResourceWithName resourceName: String!, fromPeer peerID: MCPeerID!, atURL localURL: NSURL!, withError error: NSError!) { }
    
    func session(session: MCSession!, didReceiveStream stream: NSInputStream!, withName streamName: String!, fromPeer peerID: MCPeerID!) { }
    
    
    
    // MARK: Custom method implementation
    
    func sendData(dictionaryWithData dictionary: Dictionary<String, String>, toPeer targetPeer: MCPeerID) -> Bool {
//        let dataToSend = NSKeyedArchiver.archivedDataWithRootObject(dictionary)
//        let peersArray = NSArray(object: targetPeer)
//        var error: NSError?
//        
//        if !session.sendData(dataToSend, toPeers: peersArray, withMode: MCSessionSendDataMode.Reliable, error: &error) {
//            println(error?.localizedDescription)
//            return false
//        }
//        
      return true
    }
    
}