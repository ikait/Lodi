//
//  SCTableViewCell.swift
//  Lodi
//
//  Created by Taishi Ikai on 2014/11/19.
//  Copyright (c) 2014年 Taishi Ikai. All rights reserved.
//

import UIKit

class SCTableViewCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

class SCElementsTableViewCell: UITableViewCell {
    
    
    
    @IBOutlet weak var labelSubject: UILabel!
    @IBOutlet weak var labelPredicate: UILabel!
    @IBOutlet weak var labelObject: UILabel!
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}

class SCKeywordTableViewCell: UITableViewCell {
    
    @IBOutlet weak var inputKeywordTextField: UITextField!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}

class SCLimitTableViewCell: UITableViewCell {
    
    @IBOutlet weak var limitTextField: UITextField!
    
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
        
        if let limitTextField = self.limitTextField {
            limitTextField.inputAccessoryView = numbarToolbar
        }
    }
    
    func done() {
        self.limitTextField.resignFirstResponder()
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}

class SCTitleTableViewCell: UITableViewCell {
    
    @IBOutlet weak var titleTextField: UITextField!
    
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
        
        if let titleTextField = self.titleTextField {
            titleTextField.inputAccessoryView = numbarToolbar
        }
    }
    
    func done() {
        self.titleTextField.resignFirstResponder()
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}
