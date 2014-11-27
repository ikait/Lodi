//
//  SRTableViewCell.swift
//  Lodi
//
//  Created by Taishi Ikai on 2014/11/21.
//  Copyright (c) 2014年 Taishi Ikai. All rights reserved.
//

import UIKit

class SRTableViewCell: UITableViewCell {

    @IBOutlet weak var firstTextLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
