//
//  BasicGraphPattern.swift
//  SparqlSwift
//
//  Created by Taishi Ikai on 2014/10/02.
//  Copyright (c) 2014年 ikai. All rights reserved.
//

import UIKit

class BasicGraphPattern {
    
    var _triples: [AnyObject]?
    
    init(tokens: [Token]) {
        _triples = [AnyObject]()
        _triples = self.extractTriples(tokens)
    }
    
    func isTokenValue(tokens: [Token], value: String, index: Int) -> Bool {
        var token: Token? = tokens[index]
        
        if (!(tokens.count > index)) { return false }
        if (token == nil) { return false }
        if (token!.toString() == value) { return true }
        return false
    }
    
    func toString() -> NSString {
        var listComponentsString: String?;
        if let _triples = self._triples {
            listComponentsString = NSArray(array: _triples).componentsJoinedByString(",")
        } else {
            listComponentsString = "none"
        }
        return "(bgp \(listComponentsString))"
    }
    
    func isTerminated(tokens: [Token]) -> Bool {
        return self.isTokenValue(tokens, value: "}", index: 0)
    }
    
    func extractTriples(var tokens: [Token]) -> [AnyObject] {
        var list = [AnyObject]()
        var subject: Token?
        
        // WHERE省略時、即ち既に変数宣言に入っていた場合を考慮
        if (self.isTokenValue(tokens, value: "{", index: 0)) {
            tokens.removeAtIndex(0)
        }
        
        while !self.isTerminated(tokens) {
            subject = subject != nil ? subject : tokens.removeAtIndex(0)
            var predicate: Token
            var object: Token
            
            predicate = tokens.removeAtIndex(0)
            object = tokens.removeAtIndex(0)
            
            list.append(Triple(subject: subject!, predicate: predicate, object: object))
            
            if (self.isTokenValue(tokens, value: ";", index: 0)) {
                // subject = subject
            } else if (self.isTokenValue(tokens, value: ".", index: 0)) {
                subject = nil
                tokens.removeAtIndex(0)
            }
        }
        
        // tokens.removeObjectAtIndex(0)  // "}" を削除
        
        return list
    }
}