//
//  Prefix.swift
//  SparqlSwift
//
//  Created by Taishi Ikai on 2014/10/02.
//  Copyright (c) 2014年 ikai. All rights reserved.
//

import UIKit

class Prefix {
    var _namespaces: LabelList
    
    class func isPrefixToken(token: AnyObject?) -> Bool {
        if let token: Token = token as? Token {
            return token.belongsTo(Token.type.SYMBOL) && self.testTokenString(token)
        }
        return false
    }
    
    init(namespaces: LabelList) {
//        _namespaces = self.extractLabel(tokens)
        self._namespaces = namespaces
    }
    
    convenience init(tokens: [Token]) {
        self.init(namespaces: LabelList(tokens: tokens))
    }
    
    func toString() -> NSString {
        return ""
    }
    
    class func testTokenString(token: Token) -> Bool {
        var token_string: NSString = token.toString().lowercaseString
        return token_string === "prefix"
    }
    
    func extractLabel(tokens: [Token]) -> LabelList {
        return LabelList(tokens: tokens)
    }
}