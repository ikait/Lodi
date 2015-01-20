//
//  ResourceSearchResultTableViewCell.swift
//  Lodi
//
//  Created by Taishi Ikai on 2015/01/19.
//  Copyright (c) 2015年 Taishi Ikai. All rights reserved.
//

import UIKit

class ResourceSearchResultTableViewCell: UITableViewCell {

    @IBOutlet weak var labelLabel: UILabel!
    @IBOutlet weak var commentLabel: UILabel!
    @IBOutlet weak var iriLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
