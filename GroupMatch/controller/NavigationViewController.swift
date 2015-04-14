//
//  NavigationViewController.swift
//  GroupMatch
//
//  Created by Victor Yves Crispim on 03/5/15.
//  Copyright (c) 2015 BEPiD. All rights reserved.
//

import UIKit
import MultipeerConnectivity

class NavigationViewController: UINavigationController, MPCManagerDelegate, MCBrowserViewControllerDelegate {

    //MARK: Properties
    
    var mpcManager: MPCManager?
    
    
    //MARK: UIViewController methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        mpcManager = MPCManager(displayName: UIDevice.currentDevice().name, andDelegate: self)
        mpcManager?.advertiseSelf(true)
    }

    
    //MARK: MPCManagerDelegate methods
    
    func mpcManagerPeerDidChangedState(peerInfo: Dictionary<String, NSObject>) {
        
        let matchViewController = self.viewControllers![0] as! MatchViewController
        
        matchViewController.updatePeerInformation(peerInfo)
        
    }
    
    func mpcManagerPresentResultScheduleWithData(scheduleData: [AvailableTime]) {
        
        let resultViewController = self.storyboard!.instantiateViewControllerWithIdentifier(
                                                    "ResultViewController") as! ResultViewController
        
        dispatch_async(dispatch_get_main_queue(), {

            self.pushViewController(resultViewController, animated: true)
            
            resultViewController.loadScheduleData(scheduleData)
            
            });
    }
    
    
    //MARK: MCBrowserViewControllerDelegate methods
    
    func browserViewControllerDidFinish(browserViewController: MCBrowserViewController!) {
    
        mpcManager?.requestScheduleDataFromConnectedPeers()
    }
    
    func browserViewControllerWasCancelled(browserViewController: MCBrowserViewController!) {
        
        popViewControllerAnimated(true)
    }
    
    
    //MARK: Custom Methods
    
    func startBrowsingForPeers(){
        
        mpcManager?.setupMCBrowser()
        mpcManager?.browserViewController?.delegate = self
        pushViewController(mpcManager!.browserViewController!, animated: true)
    }
    
    func resetDisplayNameTo(newName: String){

        mpcManager?.resetDisplayNameTo(newName)
    }
    
    func getNumberOfConnectedPeers() -> Int{
        
        if let count = mpcManager?.session?.connectedPeers.count{
            return count
        }
        else{
            return 0
        }
    }
    
    func disconnectFromSession(){
        mpcManager?.session?.disconnect()
    }
    
    func startAdvertising(){
        mpcManager?.advertiseSelf(true)
    }
}
