//
//  MPCManagerDelegate.swift
//  GroupMatch
//
//  Created by Victor Yves Crispim on 03/5/15.
//  Copyright (c) 2015 BEPiD. All rights reserved.
//

import Foundation

protocol MPCManagerDelegate : NSObjectProtocol{
    
    func mpcManagerPeerDidChangedState(peerInfo: Dictionary<String,NSObject>)
    
    func mpcManagerPresentResultScheduleWithData(scheduleData: [AvailableTime])
    
}