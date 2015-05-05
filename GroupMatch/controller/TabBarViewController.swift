//
//  TabBarViewController.swift
//  GroupMatch
//
//  Created by Luan Barbalho Kalume on 05/05/15.
//  Copyright (c) 2015 BEPiD. All rights reserved.
//

import UIKit

class TabBarViewController: UITabBarController
{

    override func viewDidLoad()
    {
        super.viewDidLoad()

        if let tabBarItems = self.tabBar.items as? [UITabBarItem]
        {
            
            tabBarItems[0].title = NSLocalizedString("ScheduleBarItem", comment: "Schedule icon")
            tabBarItems[1].title = NSLocalizedString("MatchBarItem", comment: "Match icon")
            tabBarItems[2].title = NSLocalizedString("HelpBarItem", comment: "Help icon")
            
        }
    }
}