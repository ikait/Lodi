//
//  Lexer.swift
//  SparqlSwift
//
//  Created by Taishi Ikai on 2014/09/30.
//  Copyright (c) 2014年 ikai. All rights reserved.
//

import UIKit

class Lexer {
    var _query: String
    var _tokens: [Token]
    var _current_position: Int
    
    let DELIMITERS = [  // XXX
        " ",
        "\n",
        "{",
        "}",
        ".",
        ";",
        ","
    ]
    
    init(query: String) {
        _query = query
        _tokens = [Token]()
        _current_position = 0
    }
    
    class func create(query: String) -> Lexer {
        return Lexer(query: query)
    }
    
    class func analyze(query: AnyObject) -> [Token] {
        let lexer: Lexer = Lexer.create(query as NSString)
        return lexer.startlex()
    }
    
    func startlex() -> [Token] {
        if (_tokens.count > 0) {
            return _tokens
        }
        self.preProcess();
        self.process();
        self.postProcess();
        
        return _tokens
    }
    
    func preProcess() -> Lexer {
        _current_position = 0
        _tokens = [Token]()
        return self
    }
    
    func postProcess() -> Lexer {
        _current_position = NSNotFound
        return self
    }
    
    func process() -> Lexer {
        if (_current_position == NSNotFound) {
            self.preProcess()
        }
        while (self.hasNext()) {
            self.addToken()
        }
        return self
    }
    
    func hasNext() -> Bool {
        return _current_position < _query.utf16Count
    }
    
    func getCurrentChar() -> String {
        if _query.utf16Count > _current_position {
            var _nsquery = _query as NSString  // XXX
            return _nsquery.substringWithRange(NSMakeRange(self._current_position, 1))
        } else {
            return ""
        }
    }
    
    func isDelimiter(character: NSString, delimiter: AnyObject?) -> Bool {
        // Mutableも含めたいのでMemberOfでなくKindOf
        if (delimiter?.isKindOfClass(NSString) != nil) {
            return character.isEqualToString(delimiter as NSString)
        } else if (delimiter?.isKindOfClass(NSArray) != nil) {
            return delimiter!.indexOfObject(character) != NSNotFound
        }
        return NSArray(array: DELIMITERS).indexOfObject(character) != NSNotFound
    }
    
    func isCurrentCharDelimiter(delimiter: AnyObject?) -> Bool {
        return self.isDelimiter(self.getCurrentChar(), delimiter: delimiter)
    }
    
    func getLanguageTag() -> NSString {
        var buf: NSMutableString
        if (self.getCurrentChar() != "@") {
            return ""
        }
        buf = NSMutableString(string: self.getCurrentChar())
        _current_position = _current_position + 1
        buf.appendString(self.getTokenString(""))
        
        return buf
    }
    
    func getStringLiteral() -> NSString {
        var buf: NSMutableString
        if (self.getCurrentChar() != "\"") {
            return ""
        }
        buf = NSMutableString(string: self.getCurrentChar())
        _current_position = _current_position + 1
        
        buf.appendString(self.getTokenString("\""))
        buf.appendString(self.getCurrentChar())
        _current_position = _current_position + 1

        buf.appendString(self.getLanguageTag())
        
        return buf
    }
    
    func getURLLiteral() -> NSString {
        var buf: NSMutableString
        if (self.getCurrentChar() != "<") {
            return ""
        }
        
        buf = NSMutableString(string: self.getCurrentChar())
        _current_position = _current_position + 1
        
        buf.appendString(self.getTokenString(">"))
        
        buf.appendString(self.getCurrentChar())
        _current_position = _current_position + 1
        
        return buf
    }
    
    func getTokenString(delimiter: AnyObject?) -> NSString {
        var buf: NSMutableString = NSMutableString()
        
        if (self.isCurrentCharDelimiter(delimiter)) {
            buf = NSMutableString(string: self.getCurrentChar())
            _current_position = _current_position + 1
        } else if (self.getCurrentChar() == "\"") {
            buf = NSMutableString(string: self.getStringLiteral())
        } else if (self.getCurrentChar() == "<") {
            buf = NSMutableString(string: self.getURLLiteral())
        } else {
            while (self.hasNext() && !self.isCurrentCharDelimiter(delimiter)) {
                var char = self.getCurrentChar()
                _current_position = _current_position + 1
                buf.appendString(char)
            }
        }
        
        return buf
    }
    
    func createToken(str: NSString) -> Token? {
        if str.rangeOfString(NSString(format: "^\\s+$"), options: .RegularExpressionSearch).location != NSNotFound {
            return nil
        } else if str == "{" {
            return Token(query: str, type: Token.type.OPEN_BRACKET)
        } else if str == "}" {
            return Token(query: str, type: Token.type.CLOSE_BRACKET)
        } else if str == "(" {
            return Token(query: str, type: Token.type.OPEN_PARENTHESIS)
        } else if str == ")" {
            return Token(query: str, type: Token.type.CLOSE_PARENTHESIS)
        } else if str == "." {
            return Token(query: str, type: Token.type.PERIOD)
        } else if str == ";" {
            return Token(query: str, type: Token.type.SEMICOLON)
        } else if str.substringToIndex(1) == "<" {
            return Token(query: str, type: Token.type.URI)
        } else if str.substringToIndex(1) == "?" {
            return Token(query: str, type: Token.type.VARIABLE)
        } else if (str as String).toInt() != nil {
            return Token(query: str, type: Token.type.NUMBER)
        } else if str.rangeOfString(NSString(format: "\"@"), options: .RegularExpressionSearch).location != NSNotFound {
            return Token(query: str, type: Token.type.STRING_WITH_LANGUAGE_TAG)
        } else if str.substringToIndex(1) == "\"" {
            return Token(query: str, type: Token.type.STRING)
        } else {
            return Token(query: str, type: Token.type.SYMBOL)
        }
        
//        switch str {
//        case "{":
//            return Token(query: str, type: Token.type.CLOSE_BRACKET)
//        case "}":
//            return Token(query: str, type: Token.type.CLOSE_BRACKET)
//        case "(":
//            return Token(query: str, type: Token.type.OPEN_PARENTHESIS)
//        case ")":
//            return Token(query: str, type: Token.type.CLOSE_PARENTHESIS)
//        case ".":
//            return Token(query: str, type: Token.type.PERIOD)
//        case ";":
//            return Token(query: str, type: Token.type.SEMICOLON)
//        }
//        
//        switch str.substringToIndex(1) {
//        case "<":
//            return Token(query: str, type: Token.type.URI)
//        case "?":
//            return Token(query: str, type: Token.type.VARIABLE)
//        }
        
    }
    
    func buildToken() -> Token? {
        var str: NSString = self.getTokenString(nil)
        return self.createToken(str)
    }
    
    func addToken() -> Lexer {
        var _token: Token? = self.buildToken()
        if let token = _token {
            self._tokens.append(token)
        }
        return self
    }
    
}
