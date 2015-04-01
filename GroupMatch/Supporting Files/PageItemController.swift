//
//  PageItemController.swift
//  GroupMatch
//
//  Created by Suzana Souza on 01/04/15.
//  Copyright (c) 2015 Appcoda. All rights reserved.
//

import Foundation

import UIKit

class PageItemController: UIViewController{
    
    var itemIndex: Int = 0
    var imageName: String = ""{
        
        didSet {
            
            if let imageView = contentImageView{
                imageView.image = UIImage(named: imageName)
            }
        }
    }
    override func viewDidLoad(){
        super.viewDidLoad()
        contentImageView!.image = UIImage(named: imageName)
    }
    
    @IBOutlet var contentImageView: UIImageView?
    
    
    
}

