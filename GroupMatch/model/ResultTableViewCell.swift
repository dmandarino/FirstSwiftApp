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
        
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
