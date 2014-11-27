//
//  GraphPattern.swift
//  SparqlSwift
//
//  Created by Taishi Ikai on 2014/10/02.
//  Copyright (c) 2014年 ikai. All rights reserved.
//

import UIKit

class GraphPattern {
    var _graphs: [AnyObject]?
    
    init(tokens: [Token]) {
        self._graphs = self.extractGraphs(tokens, list: nil)
    }
    
    func toString() -> String {
        return "(" +  NSArray(array: _graphs!).componentsJoinedByString(",") + ")"
    }
    
    func hasNext(tokens: [Token]) -> Bool {
        return false;  // XXX
    }
    
    func extractGraphs(tokens: [Token], list: [AnyObject]?) -> [AnyObject]? {
        var _list = (list != nil) ? list! : []
        _list.append(BasicGraphPattern(tokens: tokens))
        if (self.hasNext(tokens)) {
            self.extractGraphs(tokens, list: _list)
        }
        return _list
    }
}