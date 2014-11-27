//
//  Parser.swift
//  SparqlSwift
//
//  Created by Taishi Ikai on 2014/09/30.
//  Copyright (c) 2014年 ikai. All rights reserved.
//

import UIKit

class Parser {
    var _tokens: [Token]
    var _tree: [AnyObject]
    
    init(tokens: [Token]) {
        self._tokens = [Token](tokens)
        self._tree = [AnyObject]()
    }
    
    func parseTokens() -> [AnyObject] {
        return self.query(self._tokens)
    }
    
    func query(var tokens: [Token]) -> [AnyObject] {
        var token: AnyObject = tokens.removeAtIndex(0)
        if Prefix.isPrefixToken(token) {
            if _tree.count == 0 || (_tree.count > 0 && _tree[0].isMemberOfClass(Prefix)) {
                _tree.append(Prefix(tokens: tokens));
            }
        } else if Select.isSelectToken(token) {
            _tree.append(Select(tokens: tokens));
        }
        if tokens.count > 0 {
            self.query(tokens)
        }
        return _tree
    }
}