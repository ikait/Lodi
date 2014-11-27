//
//  Resouce.swift
//  Lodi
//
//  Created by Taishi Ikai on 2014/11/20.
//  Copyright (c) 2014年 Taishi Ikai. All rights reserved.
//

import UIKit


// MARK:
class Resource {
    var value: String
    var label: String?
    var type: ResourceType
    var prefix: ResourcePrefix?
    
    init(value: String, label: String, type: ResourceType, prefix: ResourcePrefix) {
        self.value = value
        self.label = label
        self.type = type
        self.prefix = prefix
    }
    
    init(value: String, type: ResourceType) {
        self.value = value
        self.type = type
        
        if value.hasPrefix("<") && value.hasSuffix(">") {
            self.value = value.substringWithRange(Range<String.Index>(
                start: advance(self.value.startIndex, 1),
                end: advance(self.value.endIndex, -1)))
        } else {
            self.value = value
        }
    }
    
    func isUri() -> Bool {
        return self.type == ResourceType.uri
    }
    
    func isLiteral() -> Bool {
        return self.type == ResourceType.literal
    }
    
    func isWithPrefix() -> Bool {
        if let prefix = self.prefix {
            if !prefix.value.isEmpty {
                return true
            }
        }
        return false
    }
    
    func getLabel() -> String {
        if let label = self.label {
            return label
        } else {
            if let v = self.shortValue {
                return v
            } else {
                return self.value
            }
        }
    }
    
    func getValueForRdf() -> String {
        if self.isWithPrefix() {
            return "\(self.prefix!.prefix):\(self.value)"
        }
        if self.isUri() {
            return "<\(self.value)>"
        }
        return "\"\(self.value)\""
    }
    
    var shortValue: String? {
        if !self.isUri() {
            return self.value
        }
        let c = value
            .componentsSeparatedByCharactersInSet(
            NSCharacterSet(charactersInString: "#/"))
        return c.last
    }
}

class ResourcePrefix {
    var prefix: String
    var value: String
    
    init(prefix: String, value: String) {
        self.prefix = prefix
        self.value = value
    }
}

enum ResourceType {
    case uri, literal, none
}
