//
//  SCLabelTableViewCell.swift
//  Lodi
//
//  Created by Taishi Ikai on 2014/11/26.
//  Copyright (c) 2014年 Taishi Ikai. All rights reserved.
//

import UIKit

class SCLabelInputTableViewCell: UITableViewCell {

    @IBOutlet weak var variableLabelTextField: UITextField!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}


class SCLabelChooseTableViewCell: UITableViewCell {
    
    @IBOutlet weak var variableLabelLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}
