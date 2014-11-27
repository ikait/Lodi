//
//  SCInputTableViewCell.swift
//  Lodi
//
//  Created by Taishi Ikai on 2014/11/18.
//  Copyright (c) 2014年 Taishi Ikai. All rights reserved.
//

import UIKit


class SCInputTableViewCell: UITableViewCell {
    
    @IBOutlet weak var labelTextField: UITextField!
    @IBOutlet weak var keywordTextField: UITextField!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

class SCInputVariableSwitchTableViewCell: UITableViewCell {
    
    
    @IBOutlet weak var variableSwitch: UISwitch!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
}

class SCInputShowSwitchTableViewCell: UITableViewCell {
    
    @IBOutlet weak var showSwitch: UISwitch!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
}

