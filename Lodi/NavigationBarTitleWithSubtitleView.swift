//
//  NavigationBarTitleWithSubtitleView.swift
//  Lodi
//
//  Created by Taishi Ikai on 2014/11/29.
//  Copyright (c) 2014年 Taishi Ikai. All rights reserved.
//

import UIKit

class NavigationBarTitleWithSubtitleView: UIView {

    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */
    
    var titleLabel: UILabel!
    var detailLabel: UILabel!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.clearColor()
        //self.autoresizesSubviews = true
        
        self.titleLabel = UILabel()
        self.titleLabel.backgroundColor = UIColor.clearColor()
        self.titleLabel.font = UIFont.boldSystemFontOfSize(16)
        self.titleLabel.textAlignment = NSTextAlignment.Center
        self.titleLabel.textColor = UIColor.blackColor()
        self.titleLabel.shadowColor = UIColor.clearColor()
        //self.titleLabel.shadowOffset = CGSize(width: 0, height: -1)
        self.titleLabel.text = ""
        self.titleLabel.adjustsFontSizeToFitWidth = true
        self.titleLabel.setTranslatesAutoresizingMaskIntoConstraints(false)
        self.addSubview(self.titleLabel)
        
        self.detailLabel = UILabel()
        self.detailLabel.backgroundColor = UIColor.clearColor()
        self.detailLabel.font = UIFont.systemFontOfSize(12)
        self.detailLabel.textAlignment = NSTextAlignment.Center
        self.detailLabel.textColor = UIColor.darkGrayColor()
        self.detailLabel.shadowColor = UIColor.clearColor()
        //self.detailLabel.shadowOffset = CGSize(width: 0, height: -1)
        self.detailLabel.text = ""
        self.detailLabel.adjustsFontSizeToFitWidth = true
        self.detailLabel.setTranslatesAutoresizingMaskIntoConstraints(false)
        self.addSubview(self.detailLabel)
        
        
        var views = [
            "titleLabel": self.titleLabel,
            "detailLabel": self.detailLabel
        ]
        self.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat(
        "V:|-5-[titleLabel]-(-5)-[detailLabel]-5-|",
            options: nil,
            metrics: nil,
            views: views))
        self.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat(
            "H:|-0-[titleLabel]-0-|",
            options: nil,
            metrics: nil,
            views: views))
        self.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat(
            "H:|-0-[detailLabel]-0-|",
            options: nil,
            metrics: nil,
            views: views))
    }

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    var titleText: String {
        get {
            return self.titleLabel.text!
        }
        set(text) {
            self.titleLabel.text = text
        }
    }
    
    var detailText: String {
        get {
            return self.detailLabel.text!
        }
        set(text) {
            self.detailLabel.text = text
        }
    }
    
}
