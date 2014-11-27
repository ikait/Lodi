//
//  Select.swift
//  SparqlSwift
//
//  Created by Taishi Ikai on 2014/10/02.
//  Copyright (c) 2014年 ikai. All rights reserved.
//

import UIKit

class Select {
    
    var _modifier: Token?
    var _variables: VariableList?
    var _graphpatterns: GraphPattern?
    
    class func isSelectToken(token: AnyObject?) -> Bool {
        if let token: Token = token as? Token {
            return token.belongsTo(Token.type.SYMBOL) && self.testTokenString(token)
        }
        return false
    }
    
    init(var tokens: [Token]) {
        if (self.hasModifier(tokens)) {
            self._modifier = tokens[0]
            tokens.removeAtIndex(0)
        }
        self._variables = extractVariable(tokens)
        if let count: Int = self._variables?.count {
            for _ in 0..<count {  // 変数として拾った分だけ削る
                tokens.removeAtIndex(0)
            }
        }
        if (self.hasWhereClause(tokens)) {
            tokens.removeAtIndex(0)
            _graphpatterns = extractGraphPatterns(tokens)
        }
    }
    
    func description() -> String {
        return self.toString()
    }
    
    func toString() -> String {
        return "(select \(_variables!.toString()) \(_graphpatterns!.toString()))"
    }
    
    class func testTokenString(token: Token) -> Bool {
        return token.toString().lowercaseString == "select"
    }
    
    func extractVariable(tokens: [Token]) -> VariableList {
        return VariableList(tokens: tokens)
    }
    
    func extractGraphPatterns(tokens: [Token]) -> GraphPattern {
        return GraphPattern(tokens: tokens)
    }
    
    func hasModifier(tokens: [Token]?) -> Bool {
        if let unwrappedTokens = tokens {
            var token: Token = unwrappedTokens[0]
            var token_string = token.toString().lowercaseString
            return token_string == "distinct" || token_string == "reduced"
        }
        return false
    }
    
    func hasWhereClause(tokens: [Token]?) -> Bool {
        if let tokens = tokens {
            var token_string = (tokens[0]).toString().lowercaseString
            return tokens.count > 0 &&
                token_string == "where" ||
                token_string == "{"
        }
        return false
    }
}

//
// 文法
// http://www.asahi-net.or.jp/~ax2s-kmtn/internet/rdf/rdf-sparql-query.html#sparqlGrammar
//
// こっち!
// http://www.asahi-net.or.jp/~ax2s-kmtn/internet/rdf/REC-sparql11-query-20130321.html
//
