//
//  ResultViewController.swift
//  GroupMatch
//
//  Created by Victor Yves Crispim on 03/5/15.
//  Copyright (c) 2015 Appcoda. All rights reserved.
//

import UIKit

class ResultViewController: UITableViewController{

    private let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate

    private var resultData = [Response]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "Available Times"

        tableView.delegate = self
        tableView.dataSource = self
        
        NSNotificationCenter.defaultCenter().addObserverForName("ResultDataProcessed",
            object: nil,
            queue: NSOperationQueue.mainQueue())
            { (notification: NSNotification?) -> Void in
                
                self.resultData = notification?.object as [Response]
                self.tableView.reloadData()
                
                //teste
                for data in self.resultData{
                    println(data.getDay() + "   " + data.getHour() + "\n")
                }
            }
    }

    //MARK: TableView DataSource Methods
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return resultData.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        var cell = tableView.dequeueReusableCellWithIdentifier("ResultTableViewCell") as? ResultTableViewCell
        
        if cell == nil{
            let nib = UINib(nibName: "ResultCustomCell", bundle: NSBundle.mainBundle())
            tableView.registerNib(nib, forCellReuseIdentifier: "ResultTableViewCell")
            cell = tableView.dequeueReusableCellWithIdentifier("ResultTableViewCell") as? ResultTableViewCell
        }
        
        cell?.weekDay.text = resultData[indexPath.row].getDay()
        cell?.timeSpan.text = resultData[indexPath.row].getHour()
        
        return cell!
    }
    
    //MARK: TableView Delegate Methods
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 60.0
    }
}
