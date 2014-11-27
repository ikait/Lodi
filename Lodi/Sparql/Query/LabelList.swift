//
//  LabelList.swift
//  SparqlSwift
//
//  Created by Taishi Ikai on 2014/10/02.
//  Copyright (c) 2014年 ikai. All rights reserved.
//

import UIKit

class LabelList {
    var _list: [AnyObject]?
    
    init(tokens: [Token]) {
        _list = NSMutableArray()
        _list = createLabelList(tokens, list: nil)
    }
    
    func toString() -> String {
        var listComponentsString: String?;
        if let _list = self._list {
            listComponentsString = NSArray(array: _list).componentsJoinedByString(",")
        } else {
            listComponentsString = "none"
        }
        return "(\(listComponentsString))"
    }
    
    func createLabelList(var tokens: [Token], list: [AnyObject]?) -> [AnyObject]? {
        var labelList = list != nil ? list : NSMutableArray()
        if (tokens.count > 1) {
            if (self.isLabel(tokens[0]) && self.isURI(tokens[1])) {
                labelList!.append(Label(token: tokens[0], uri_token: tokens[1]))
                tokens.removeAtIndex(0)  // label:
                tokens.removeAtIndex(0)  // <uri>
                if (self.hasNext(tokens)) {
                    tokens.removeAtIndex(0)  // prefix
                    self.createLabelList(tokens, list: labelList!)
                }
            }
        }
        return labelList!
    }
    
    func isLabel(token: Token) -> Bool {
        var token_string = token.toString()
        return token_string.hasSuffix(":")
    }
    
    func isURI(token: Token) -> Bool {
        var token_string = token.toString()
        return token_string.hasPrefix("<") && token_string.hasSuffix(">") && token.belongsTo(Token.type.URI)
    }
    
    func hasNext(tokens: [Token]) -> Bool {
        return Prefix.testTokenString(tokens[0])
    }
}