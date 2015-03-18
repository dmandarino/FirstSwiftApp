//
//  ResultTableViewCell.swift
//  GroupMatch
//
//  Created by Victor Yves Crispim on 03/5/15.
//  Copyright (c) 2015 Appcoda. All rights reserved.
//

import UIKit

class ResultTableViewCell: UITableViewCell {

    @IBOutlet weak var weekDay: UILabel!
    @IBOutlet weak var timeSpan: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
//        println("Cell Bounds:" + "\(self.contentView.bounds.height)" + "-\(self.contentView.bounds.width)")
        
        
        self.bounds = CGRectMake(0, 0, UIScreen.mainScreen().bounds.width, self.bounds.height)
        
//        println("\(UIScreen.mainScreen().bounds.width)")
//        println("Cell Bounds:" + "\(self.contentView.bounds.height)" + "-\(self.contentView.bounds.width)")
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
