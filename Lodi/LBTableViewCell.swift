//
//  LBTableViewCell.swift
//  Lodi
//
//  Created by Taishi Ikai on 2014/11/20.
//  Copyright (c) 2014年 Taishi Ikai. All rights reserved.
//

import UIKit

class LBTableViewCell: UITableViewCell {
    
    @IBOutlet weak var firstLabel: UILabel!
    @IBOutlet weak var secondLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func layoutMargins() -> UIEdgeInsets {
        return UIEdgeInsetsZero
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
