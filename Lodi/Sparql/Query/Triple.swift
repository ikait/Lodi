//
//  Triple.swift
//  SparqlSwift
//
//  Created by Taishi Ikai on 2014/10/02.
//  Copyright (c) 2014年 ikai. All rights reserved.
//

import UIKit

class Triple {
    var _subject: Token, _predicate: Token, _object: Token
    
    init(subject: Token, predicate: Token, object: Token) {
        _subject = subject
        _predicate = predicate
        _object = object
    }
    
    func toString() -> String {
        return "(triple \(_subject.toString()) \(_predicate.toString()) \(_object.toString()))"
    }
}