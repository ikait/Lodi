//
//  SpraqlQueryResultsXml.swift
//  Lodi
//
//  Created by Taishi Ikai on 2014/11/15.
//  Copyright (c) 2014年 Taishi Ikai. All rights reserved.
//

import Foundation

class SparqlQueryResultsXml: NSObject {
    let variables: [String]?
    let results: [SparqlQueryResultsXmlResult]?
    
    init(variables: [String]? = nil, results: [SparqlQueryResultsXmlResult]? = nil) {
        self.variables = variables
        self.results = results
    }
    
    
    var count: Int {
        if let c = self.results?.count {
            return c
        }
        return 0
    }
    
    var bindingsCount: Int {
        if let results = self.results {
            var c = 0
            for result in results {
                c += result.count
            }
            return c
        }
        return 0
    }
    
    override var description: String {
        return "[SparqlQueryResultsXml] ResultsCount: \(self.count), BindingsCount: \(self.bindingsCount)"
    }
}

class SparqlQueryResultsXmlResult: NSObject {
    let bindings: [SparqlQueryResultsXmlBinding]
    
    init(bindings: [SparqlQueryResultsXmlBinding]) {
        self.bindings = bindings
    }
    
    var count: Int {
        return self.bindings.count
    }
    
    override var description: String {
        return "[SparqlQueryResultsXmlResult] Count: \(self.count)"
    }
}

class SparqlQueryResultsXmlBinding: NSObject {
    let name: String
    let type: String
    let value: String
    
    init(name: String, type: String, value: String) {
        self.name = type.name
        self.type = type.lowercaseString
        self.value = value
    }
    
    func isUri() -> Bool {
        return self.type == "uri"
    }
    
    func isLiteral() -> Bool {
        return self.type == "literal"
    }
    
    func isBnode() -> Bool {
        return self.type == "bnode"
    }
    
    var shortValue: String? {
        if !self.isUri() {
            return self.value
        }
        let c = self.value.componentsSeparatedByCharactersInSet(
            NSCharacterSet(charactersInString: "#/"))
        return c.last
    }
    
    override var description: String {
        return "[SparqlQueryResultsXmlBinding] Type: \(self.type) Value: \"\(self.value)\""
    }
}