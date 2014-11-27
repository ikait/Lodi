//
//  Variable.swift
//  SparqlSwift
//
//  Created by Taishi Ikai on 2014/10/02.
//  Copyright (c) 2014年 ikai. All rights reserved.
//

import UIKit

class Variable {
    var _token: Token
    var _name: NSString
    
    init(token: Token) {
        _token = token
        
        var token_string = token.toString() as NSString
        _name = token_string.substringWithRange(NSMakeRange(token_string.length - 1, 1))
    }
    
    func isAnonymousVariable() -> Bool {
        return _name.length == 0
    }
    
    func toString() -> String {
        return _token.toString()
    }
}