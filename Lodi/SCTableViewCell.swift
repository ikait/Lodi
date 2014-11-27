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
            UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.Bordered, target: self, action: "done")
        ]
        numbarToolbar.sizeToFit()
        self.limitTextField.inputAccessoryView = numbarToolbar
    }
    
    func done() {
        self.limitTextField.resignFirstResponder()
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}
