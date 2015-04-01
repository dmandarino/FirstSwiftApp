//
//  MatchViewController.swift
//  MPCRevisited
//
//  Created by Victor Yves Crispim on 03/5/15.
//  Copyright (c) 2015 Appcoda. All rights reserved.
//

import UIKit
import MultipeerConnectivity

class MatchViewController: UIViewController, UITextFieldDelegate, UITableViewDataSource, UITableViewDelegate {
    
    //MARK: private variables
    
    private var connectedDevices: [String] = []
    private var navigationViewController: NavigationViewController?
    
    //MARK: public variables
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var visibleSwitch: UISwitch!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var disconnectButton: UIButton!
    
    //MARK: ViewController Methods
    
    override func viewDidLoad() {
        
        //TableView configuration
        tableView.delegate = self
        tableView.dataSource = self
        tableView.reloadData()
        
        //TODO disable name change when you are already connected
        //TextField configuration
        nameTextField.delegate = self
        nameTextField.enabled = false
        
        //let teste = navigationController!
        
        navigationViewController = (navigationController! as NavigationViewController)
    }

    //MARK: IBAction Methods
    
    @IBAction func toggleVisibility(sender: UISwitch) {
    
        navigationViewController?.startAdvertising()
        nameTextField.enabled = !sender.on
    }
   
    @IBAction func disconnectFromSession(sender: UIButton){

        navigationViewController?.disconnectFromSession()
        
        nameTextField.enabled = true
        
        connectedDevices.removeAll(keepCapacity: true)
        tableView.reloadData()
    }
    
    @IBAction func searchForPeers(sender: UIBarButtonItem){
        
        navigationViewController?.startBrowsingForPeers()
    }
    
    
    //MARK: TextFieldDelegate Methods
    
    //Troca o nome do device exibido pelo advertiser
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        
        nameTextField.resignFirstResponder()
        
        navigationViewController?.resetDisplayNameTo(textField.text)
        
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
    
    
    //MARK: Custom Methods
    
    //Called whenever a peer status changes
    func updatePeerInformation(peerInfo: Dictionary<String, NSObject>){
        
        let peerID = peerInfo["peerID"] as MCPeerID
        let peerDisplayName = peerID.displayName
        
        let state = MCSessionState(rawValue: peerInfo["state"] as Int)
        
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
            
            let thereAreNoConnectedPeers: Bool = navigationViewController?.getNumberOfConnectedPeers() == 0
            
            disconnectButton.enabled = !thereAreNoConnectedPeers
            nameTextField.enabled = thereAreNoConnectedPeers
        }
        tableView.reloadData()
    }
}