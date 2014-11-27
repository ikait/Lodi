//
//  NTriples.swift
//  Lodi
//
//  Created by Taishi Ikai on 2014/11/20.
//  Copyright (c) 2014年 Taishi Ikai. All rights reserved.
//

import UIKit


// MARK: - for NTriples

class NTriples: SearchResultFile {
    var triples: [NTriplesTriple]
    var data: NSData?
    
    var appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
    
    init(triples: [NTriplesTriple]) {
        self.triples = triples
    }
    
    init(data: NSData) {
        self.triples = []
        self.data = data
    }
    
    override init() {
        self.triples = []
    }
    
    func orderByPredicate(values: [String]) {
        for v in reverse(values) {
            self.triples.sort({item1, item2 -> Bool in
                if item1.p.shortValue! == v {
                    return true
                }
                return false
            })
        }
    }
    
    func orderByObject() {
        self.triples.sort({item1, item2 -> Bool in
            return item1.o.shortValue > item2.o.shortValue
        })
    }
    
    func parse() -> Bool {
        if let data = data {
            println("NTriple parsing started.")
            
            var string = NSMutableString(data: data, encoding: NSUTF8StringEncoding)!
            CFStringTransform(string as CFMutableStringRef, nil, "Hex", 1)
            
            var parts: NSArray = string.componentsSeparatedByCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
            
            var s: NTriplesPart?
            var p: NTriplesPart?
            var o: NTriplesPart?
            
            if !(parts[0] as String).hasPrefix("<") {
                println("hmm... it may not be NTriples.")
            }
            
            for str in parts {
                var str = str as String
                println("NTriple parsing! \(str)")
                
                if str.isEmpty {
                    continue
                }
                
                switch str {
                case ".":
                    s = nil
                    p = nil
                    o = nil
                    continue
                case ";":
                    p = nil
                    o = nil
                    continue
                case ",":
                    o = nil
                    continue
                default:
                    break
                }
                
                if s == nil {
                    s = NTriplesPart(value: str)
                    continue
                }
                if p == nil {
                    p = NTriplesPart(value: str)
                    continue
                }
                if o == nil {
                    o = NTriplesPart(value: str)
                    self.triples.append(NTriplesTriple(s: s!, p: p!, o: o!))
                }
            }
            self.orderByObject()
            self.orderByPredicate(["label", "abstract", "comment", "type", "class"])
            appDelegate.addResourceFromNTriples(self.triples)
            println("NTriple parsing ended.")
            return true
        }
        return false
    }
}

class NTriplesTriple {
    var s: NTriplesPart;
    var p: NTriplesPart;
    var o: NTriplesPart;
    
    init(s: NTriplesPart, p: NTriplesPart, o: NTriplesPart) {
        self.s = s
        self.p = p
        self.o = o
    }
}

class NTriplesPart {
    var type: NTriplesPartType
    var value: String
    
    init(value: String) {
        if value.hasPrefix("<") && value.hasSuffix(">") {
            self.type = NTriplesPartType.uri
        } else {
            self.type = NTriplesPartType.literal
        }
        self.value = value
    }
    
    init(type: NTriplesPartType, value: String) {
        self.type = type
        self.value = value
    }
    
    func isUri() -> Bool {
        return self.type == NTriplesPartType.uri
    }
    
    func isLiteral() -> Bool {
        return self.type == NTriplesPartType.literal
    }
    
    var shortValue: String? {
        if self.isLiteral() {
            return self.value
        }
        var c = value
            .substringWithRange(Range<String.Index>(
                start: advance(self.value.startIndex, 0),
                end: advance(self.value.endIndex, -1)))
            .componentsSeparatedByCharactersInSet(
                NSCharacterSet(charactersInString: "#/:"))
        return c.last
    }
}

enum NTriplesPartType {
    case uri, literal
}