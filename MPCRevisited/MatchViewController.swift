//
//  MatchViewController.swift
//  MPCRevisited
//
//  Created by Victor Yves Crispim on 03/5/15.
//  Copyright (c) 2015 Appcoda. All rights reserved.
//

import UIKit
import MultipeerConnectivity

class MatchViewController: UIViewController, MCBrowserViewControllerDelegate, UITextFieldDelegate, UITableViewDataSource, UITableViewDelegate {
    
    //MARK: private variables
    
    private var connectedDevices: [String] = []
    private let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
    
    //MARK: public variables
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var visibleSwitch: UISwitch!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var disconnectButton: UIButton!
    
    //MARK: ViewController Methods
    
    override func viewDidLoad() {
        
        self.title = "Match Options"
        
        //TableView configuration
        tableView.delegate = self
        tableView.dataSource = self
        tableView.reloadData()
        
        //TODO disable name change when you are already connected
        //TextField configuration
        nameTextField.delegate = self
        nameTextField.enabled = false
        
        //MPC configuration
        appDelegate.mpcManager.setupPeerAndSessionWithDisplayName(UIDevice.currentDevice().name)
        appDelegate.mpcManager.advertiseSelf(visibleSwitch.on)
        
        //Register as an observer of peer status' changes
        NSNotificationCenter.defaultCenter().addObserverForName("MCDidChangeStateNotification",
                                                                object: nil,
                                                                queue: NSOperationQueue.mainQueue())
        { (notification: NSNotification?) -> Void in
            
            self.peerDidChangeStateWithNotification(notification!)
        }
        
        //TESTE DE TRANSFERENCIA DE DADOS DO MPC
        NSNotificationCenter.defaultCenter().addObserverForName("receivedAllData",
            object: nil,
            queue: NSOperationQueue.mainQueue())
            { (notification: NSNotification?) -> Void in

//              navigationController!.pushViewController(/*resultViewController*/, animated: true)
                
                let dataArray = notification!.object as Array<String>
                
                for data in dataArray{
                    println(data)
                }
            }
    }

    //MARK: IBAction Methods
    
    @IBAction func toggleVisibility(sender: UISwitch) {
        appDelegate.mpcManager.advertiseSelf(sender.on)
        nameTextField.enabled = !sender.on
    }
   
    @IBAction func disconnect(sender: UIButton){

        appDelegate.mpcManager.session?.disconnect()
        
        nameTextField.enabled = true
        
        connectedDevices.removeAll(keepCapacity: true)
        tableView.reloadData()
    }
    
    @IBAction func searchForPeers(sender: UIBarButtonItem){

        appDelegate.mpcManager.setupMCBrowser()
        appDelegate.mpcManager.browser!.delegate = self
        
        
        navigationController!.pushViewController(appDelegate.mpcManager.browser!,
                                                    animated: true)
    }
    
    //MARK: TextFieldDelegate Methods
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        
        //some com o teclado
        nameTextField.resignFirstResponder()
        
        /*Destroi todos os objetos do MPC*/
        appDelegate.mpcManager.peer = nil
        appDelegate.mpcManager.session = nil
        appDelegate.mpcManager.browser = nil
        
        if visibleSwitch.on{
            appDelegate.mpcManager.advertiser?.stop()
        }
        
        appDelegate.mpcManager.advertiser = nil
        
        /*Cria todos os objetos do MPC com novo nome*/
        
        //if the textField is empty, use default display name
        if nameTextField.text != ""{
            appDelegate.mpcManager.setupPeerAndSessionWithDisplayName(nameTextField.text)
        }
        else{
            appDelegate.mpcManager.setupPeerAndSessionWithDisplayName(UIDevice.currentDevice().name)
        }

        appDelegate.mpcManager.setupMCBrowser()
        appDelegate.mpcManager.advertiseSelf(visibleSwitch.on)
        
        return true
    }
    
    //MARK: TableView DataSource Methods
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return connectedDevices.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        var cell = tableView.dequeueReusableCellWithIdentifier("CellIdentifier") as? UITableViewCell
        
        if cell == nil{
            cell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: "CellIdentifier")
        }
        
        cell!.textLabel.text = connectedDevices[indexPath.row]
        
        return cell!
    }

    //MARK: TableView Delegate Methods
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 60.0
    }
    
    //MARK: MCBrowserViewControllerMethods
    
    func browserViewControllerDidFinish(browserViewController: MCBrowserViewController!) {
        
        appDelegate.mpcManager.requestMatchDataFromConnectedPeers()
        
        navigationController!.pushViewController(
            ResultViewController.init(nibName: "ResultViewController", bundle: NSBundle.mainBundle()),
            animated: true)
    }
    
    func browserViewControllerWasCancelled(browserViewController: MCBrowserViewController!) {
        
        navigationController!.popViewControllerAnimated(true)
    }

    //MARK: Private Functions
    
    //manages the connectedDevices array, the tableView Data Source
    private func peerDidChangeStateWithNotification(notification: NSNotification){
     
        //retrieves the peer display name
        let peerID = notification.userInfo!["peerID"] as MCPeerID
        let peerDisplayName = peerID.displayName
        
        //retrieves the peer state
        let state = MCSessionState(rawValue: notification.userInfo!["state"] as Int)
        
        //if peer is not connecting
        if state != MCSessionState.Connecting {
            
            if state == MCSessionState.Connected {
                connectedDevices.append(peerDisplayName)
            }
            else if state == MCSessionState.NotConnected{
                
                if connectedDevices.count > 0 {
                    for var index = 0; index < connectedDevices.count; ++index{
                        if connectedDevices[index] == peerDisplayName{
                            connectedDevices.removeAtIndex(index)
                        }
                    }
                }
            }
            
            //if the peer has been connected or disconnected, reload the table
            tableView.reloadData()
            
            //if there are any peers
            let peersExist: Bool = appDelegate.mpcManager.session?.connectedPeers.count == 0

            disconnectButton.enabled = !peersExist
            nameTextField.enabled = peersExist
        }
    }
}