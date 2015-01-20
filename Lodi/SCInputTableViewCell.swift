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

class SCInputFilterTableViewCell: UITableViewCell {
    
    @IBOutlet weak var inputFilterTextField: UITextField!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        var numbarToolbar = UIToolbar()
        numbarToolbar.barStyle = UIBarStyle.Default
        numbarToolbar.items = [
            UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace, target: nil, action: nil),
            UIBarButtonItem(
                title: NSLocalizedString("Done", comment: ""),
                style: UIBarButtonItemStyle.Bordered,
                target: self,
                action: "done")
        ]
        numbarToolbar.sizeToFit()
        
        if let inputFilterTextField = self.inputFilterTextField {
            inputFilterTextField.inputAccessoryView = numbarToolbar
        }
    }
    
    func done() {
        self.inputFilterTextField.resignFirstResponder()
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}
