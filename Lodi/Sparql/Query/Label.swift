//
//  Label.swift
//  SparqlSwift
//
//  Created by Taishi Ikai on 2014/10/02.
//  Copyright (c) 2014年 ikai. All rights reserved.
//

import UIKit

class Label {
    var _token: Token
    var _uri_token: Token
    
    init(token: Token, uri_token: Token) {
        _token = token
        _uri_token = uri_token
    }
    
    func isAnonymousLabel() -> Bool {
        return self.getLabelString().utf16Count == 0
    }
    
    func toString() -> String {
        return NSString(format: "(%@ %@)",
            _token.toString(),
        _uri_token.toString())
    }
    
    func getLabelString() -> String {
        var token_str = _token.toString() as NSString
        return token_str.substringWithRange(NSMakeRange(0, token_str.length - 1))
    }
}