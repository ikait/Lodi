//
//  Turtle.swift
//  Lodi
//
//  Created by Taishi Ikai on 2014/11/22.
//  Copyright (c) 2014年 Taishi Ikai. All rights reserved.
//

import UIKit

class Turtle: SearchResultFile {
    var triples: [TurtleTriple]
    var prefixes: [TurtleTriple]
    var data: NSData?
    
    var appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
    
    init(triples: [TurtleTriple], prefixes: [TurtleTriple]) {
        self.triples = triples
        self.prefixes = prefixes
    }
    
    init(data: NSData) {
        self.triples = []
        self.prefixes = []
        self.data = data
    }
    
    override init() {
        self.triples = []
        self.prefixes = []
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
    
    func parseTest(interrepter: () -> Bool) -> Bool {
        if let data = data {
            
            // MARK: この表示は多いので重い
            // println("Turtle parsing started.")
            
            var string = NSMutableString(data: data, encoding: NSUTF8StringEncoding)!
            CFStringTransform(string as CFMutableStringRef, nil, "Hex", 1)
            
            
            // FIXME: - "文字列" 内の半角スペースも分割してしまっている件
            var cs = NSMutableCharacterSet.whitespaceAndNewlineCharacterSet()
            //            cs.removeCharactersInString(" ")
            var parts: NSArray = string.componentsSeparatedByCharactersInSet(cs)
            
            var s, p, o: TurtleTriplePart?
            
            if !(parts[0] as String).hasPrefix("@prefix") {
                println("hmm... it may not be Turtle.")
            }
            
            for str in parts {
                if interrepter() {
                    return false
                }
                
                var str = str as String
                println("Turtle parsing! \(str)")
                
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
                    if o != nil {
                        o!.value += " " + str
                    }
                    break
                }
                
                if s == nil {
                    s = TurtleTriplePart(value: str)
                    continue
                }
                if p == nil {
                    p = TurtleTriplePart(value: str)
                    continue
                }
                if o == nil {
                    o = TurtleTriplePart(value: str)
                    
                    if s!.value == "@prefix" {
                        self.prefixes.append(TurtleTriple(s: s!, p: p!, o: o!, prefix: true))
                    } else {
                        for prefix in self.prefixes {
                            if s!.value.hasPrefix(prefix.p.value) {
                                s!.prefix = prefix
                            }
                            if p!.value.hasPrefix(prefix.p.value) {
                                p!.prefix = prefix
                            }
                            if o!.value.hasPrefix(prefix.p.value) {
                                o!.prefix = prefix
                            }
                        }
                        self.triples.append(TurtleTriple(s: s!, p: p!, o: o!))
                    }
                }
            }
            //            self.orderByObject()
            //            self.orderByPredicate(["label", "abstract", "comment", "type", "class"])
            // appDelegate.addResourceFromTurtle(self.triples)
            println("Turtle parsing ended.")
            return true
        }
        return false
    }
    
    func parse() -> Bool {
        return parseTest{
            return true
        }
    }
    
    var description: String {
        var result = ""
        for triple in self.triples {
            result += "\(triple.description)\n"
        }
        return result
    }
}

class TurtleTriple {
    var s: TurtleTriplePart;
    var p: TurtleTriplePart;
    var o: TurtleTriplePart;
    var prefix: Bool;
    
    init(s: TurtleTriplePart, p: TurtleTriplePart, o: TurtleTriplePart, prefix: Bool? = nil) {
        self.s = s
        self.p = p
        self.o = o
        if let prefix = prefix {
            self.prefix = prefix
        } else {
            self.prefix = false
        }
    }
    
    var description: String {
        return "s: \(s.description), p: \(p.description), o: \(o.description)"
    }
}

class TurtleTriplePart {
    var type: TurtleTritlePartType
    var value: String
    var prefix: TurtleTriple?
    
    init(value: String) {
        if value.hasPrefix("<") && value.hasSuffix(">") {
            self.type = TurtleTritlePartType.uri
        } else if value.hasPrefix("\"") {
            self.type = TurtleTritlePartType.literal
        } else if value == "@prefix" {
            self.type = TurtleTritlePartType.prefixDeclare
        } else if value.hasSuffix(":") {
            self.type = TurtleTritlePartType.prefixString
        } else {
            self.type = TurtleTritlePartType.prefixValue
        }
        self.value = value
    }
    
    init(type: TurtleTritlePartType, value: String) {
        self.type = type
        self.value = value
    }
    
    func isUri() -> Bool {
        return self.type == TurtleTritlePartType.uri
    }
    
    func isLiteral() -> Bool {
        return self.type == TurtleTritlePartType.literal
    }
    
    func isPrefixValue() -> Bool {
        return self.type == TurtleTritlePartType.prefixValue
    }
    
    var shortValue: String? {
        if self.isLiteral() {
            return self.value
        }
        if self.isPrefixValue() {
            return self.value.componentsSeparatedByCharactersInSet(
            NSCharacterSet(charactersInString: ":")).last
        }
        
        var c = value
            .substringWithRange(Range<String.Index>(
                start: advance(self.value.startIndex, 0),
                end: advance(self.value.endIndex, -1)))
            .componentsSeparatedByCharactersInSet(
                NSCharacterSet(charactersInString: "#/"))
        return c.last
    }
    
    var valueWithoutChevrons: String {  // chevrons: "<", ">"
        if self.isUri() {
            return value
                .substringWithRange(Range<String.Index>(
                    start: advance(self.value.startIndex, 1),
                    end: advance(self.value.endIndex, -1)))
        }
        return self.value
    }
    
    var valuePrefixConnected: String {
        if let prefix = self.prefix {
            return "<" + prefix.o.valueWithoutChevrons + self.shortValue! + ">"
        }
        return self.value
    }
    
    var description: String {
        return "[VALUE:] \(self.value) [TYPE:] \(self.type.rawValue)\n"
    }
}

enum TurtleTritlePartType: String {
    case uri = "URI",
    literal = "LITERAL",
    prefixDeclare = "PREFIX_DECLARE",
    prefixString = "PREFIX_STRING",
    prefixValue = "PREFIX_VALUE"
}