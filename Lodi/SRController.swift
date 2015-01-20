//
//  SearchResultItem.swift
//  Lodi
//
//  Created by Taishi Ikai on 2014/11/14.
//  Copyright (c) 2014年 Taishi Ikai. All rights reserved.
//

import Foundation

class SearchResultController {
    var resultItems: [SearchResultItem] = []
    let xmlData: NSData?
    let jsonData: NSData!
    
    init(xmlData: NSData) {
        self.xmlData = xmlData
    }
    
    init(jsonData: NSData) {
        self.jsonData = jsonData
    }
    
    func parseJson(interrepter: (() -> Bool)? = nil) -> Bool {
        var resultItems = []

        let json = JSON(data: self.jsonData)
        
        self.resultItems = []
        for (index: String, subJson1: JSON) in json["results"]["bindings"] {
            if let abort = interrepter {
                if abort() {
                    return false
                }
            }
            
            var bindings: [SearchResultItemBinding] = []
            for (name: String, subJson2: JSON) in subJson1 {
                let value = subJson2["value"].string!
                let type = subJson2["type"].string!
                
                let child = SearchResultItemBinding(name: name, typeWithString: type, value: value)
                bindings.insert(child, atIndex: 0)
            }
            self.resultItems.append(SearchResultItem(bindings: bindings))
        }
        return true
    }
    
    func parse() -> Bool {
        var resultItems = []
        var error: NSError?
        let xmldoc = AEXMLDocument(xmlData: self.xmlData!, error: &error)
        
        if xmldoc != nil {
            let xml = xmldoc!
            self.resultItems = []
            println("Parse success!")
            
            for result in xml.rootElement["results"].children {
                var bindings: [SearchResultItemBinding] = []
                for binding in result.children {
                    let e = binding.children[0]
                    let name = binding.attributes["name"] as String
                    let child = SearchResultItemBinding(
                        name: name, typeWithString: e.name, value: e.value)
                    bindings.append(child)
                }
                self.resultItems.append(SearchResultItem(bindings: bindings))
            }
            return true
        } else {
            println("Parse failure...")
            return false
        }
    }
    
    func sort() {
        self.orderBy(["label", "comment", "hyper"])
    }
    
    func orderBy(values: [String]) {
        for v in reverse(values) {
            self.resultItems.sort({item1, item2 -> Bool in
                for binding in item1.bindings {
                    if binding.shortValue == v {
                        return true
                    }
                }
                return false
            })
        }
    }
    
    var resultItemsCount: Int {
        return self.resultItems.count
    }
    
    var countBindings: Int {
        var count = 0
        for item in self.resultItems {
            count += item.count
        }
        return count
    }
}

class SearchResultItem: NSObject {
    var bindings: [SearchResultItemBinding] = []
    
    init(bindings: [SearchResultItemBinding]) {
        self.bindings = bindings
    }

    func getBinding(variable: String) -> SearchResultItemBinding? {
        for binding in self.bindings {
            if binding.name == variable {
                return binding
            }
        }
        return nil
    }
    
    var count: Int {
        return self.bindings.count
    }
    
    override var description: String {
        var string = ""
        for binding in self.bindings {
            string += binding.description
        }
        return string
    }
}

/**
http://www.w3.org/TR/rdf-sparql-XMLres/#examples
*/
class SearchResultItemBinding: NSObject {
    var name: String, type: SearchResultItemType, value: String
    
    init(name: String, type: SearchResultItemType, value: String) {
        self.name = name  // variable name
        self.type = type
        self.value = value
    }
    
    init(name: String, var typeWithString: String, value: String) {
        self.name = name
        self.value = value
        
        switch typeWithString.lowercaseString {
        case "uri":
            self.type = SearchResultItemType.URI
        case "literal":
            self.type = SearchResultItemType.Literal
        case "bnode":
            self.type = SearchResultItemType.Bnode
        default:
            self.type = SearchResultItemType.Literal  // FIXME:
        }
    }
    
    func isUri() -> Bool {
        return self.type == SearchResultItemType.URI
    }
    
    func isLiteral() -> Bool {
        return self.type == SearchResultItemType.Literal
    }
    
    func isBnode() -> Bool {
        return self.type == SearchResultItemType.Bnode
    }
    
    var shortValue: String? {
        if !self.isUri() {
            return self.value
        }
        let c = value.componentsSeparatedByCharactersInSet(
            NSCharacterSet(charactersInString: "#/"))
        return c.last
    }
    
    override var description: String {
        return "name: \(self.name), type: \(self.type), value: \(self.value)"
    }
}

enum SearchResultItemType {
    case URI, Literal, Bnode
}

enum SearchResultType {
    case XML, NTriples, Turtle
}


class SearchResultFile {
    
}