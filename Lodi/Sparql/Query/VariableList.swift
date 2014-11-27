//
//  VariableList.swift
//  SparqlSwift
//
//  Created by Taishi Ikai on 2014/10/02.
//  Copyright (c) 2014年 ikai. All rights reserved.
//

import UIKit

class VariableList {
    var _list: [AnyObject]
    
    init(tokens: [Token]) {
        _list = [AnyObject]()
        _list = createVariableList(tokens, list: nil)
    }
    
    func toString() -> NSString {
        return "(" + NSArray(array: _list).componentsJoinedByString(",")  + ")"
    }
    
    var count: Int {
        return self._list.count;
    }
    
    func isVariable(token: Token) -> Bool {
        var token_string = token.toString()
        
        return token_string.hasPrefix("?") ||
        token_string.hasPrefix("$") ||
        token_string.hasPrefix("*")
    }
    
    func hasNext(tokens: [Token]) -> Bool {
        if (!(tokens.count > 0)) { return false }
        if (!(self.isVariable(tokens[0]))) { return false }
        return true
    }
    
    func createVariableList(var tokens: [Token], list: [AnyObject]?) -> [AnyObject] {
        var variableList = (list != nil) ? list! : []
        if (tokens.count > 0) {
            if (self.isVariable(tokens[0])) {
                variableList.append(Variable(token: tokens[0]))
                tokens.removeAtIndex(0)  // ここで tokens を削っても、呼び出し元には反映されない! (配列が値渡しのため)
                if (self.hasNext(tokens)) {
                    self.createVariableList(tokens, list: variableList)
                }
            }
        }
        return variableList
    }

}