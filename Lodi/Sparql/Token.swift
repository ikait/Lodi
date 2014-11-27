//
//  Token.swift
//  SparqlSwift
//
//  Created by Taishi Ikai on 2014/09/30.
//  Copyright (c) 2014年 ikai. All rights reserved.
//

import UIKit

class Token: Printable {
    var _query: String
    var _type: Token.type
    
    init(query: String, type: Token.type) {
        self._query = query
        self._type = type
    }
    
    func toString() -> String {
        return self._query
    }
    
    var description: String {
        return "query: \"\(self._query)\", type: \"\(self._type.rawValue)\""
    }
    
    func belongsTo(type: Token.type) -> Bool {
        return self._type == type
    }
    
    class func isToken(obj: AnyObject) -> Bool {
        return obj.isKindOfClass(Token)
    }
    
    enum type : String {
        case EOT = "EOT",
        SYMBOL = "SYMBOL",
        OPEN_PARENTHESIS = "OPEN_PARENTHESIS",
        CLOSE_PARENTHESIS = "CLOSE_PARENTHESIS",
        OPEN_BRACKET = "OPEN_BRACKET",
        CLOSE_BRACKET = "CLOSE_BRACKET",
        SEMICOLON = "SEMICOLON",
        PERIOD = "PERIOD",
        STRING = "STRING",
        STRING_WITH_LANGUAGE_TAG = "STRING_WITH_LANGUAGE_TAG",
        NUMBER = "NUMBER",
        URI = "URI",
        BLANK_NODE = "BLANK_NODE",
        VARIABLE = "VARIABLE",
        PREFIXED_NAME = "PREFIXED_NAME"
    }
}