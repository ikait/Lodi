//
//  LDDataReceiver.swift
//  Lodi
//
//  Created by Taishi Ikai on 2014/11/26.
//  Copyright (c) 2014年 Taishi Ikai. All rights reserved.
//

import UIKit

class LDDataReceiver {
    
    var appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
    var connection: LDURLConnection?
    
    var queue = NSOperationQueue()
    
    init(connection: LDURLConnection, getTurtleHandler successHandler: (Turtle -> ())) {
        self.connection = connection
        self.connection?.completionHandler = { data in
            var turtle = Turtle(data: data)
            var parseOperation = NSBlockOperation()
            parseOperation.addExecutionBlock({
                if turtle.parseTest({
                    if parseOperation.cancelled {
                        LDURLConnection.hideIndicator()
                        return true
                    }
                    return false
                }) {
                    NSOperationQueue.mainQueue().addOperationWithBlock({
                        successHandler(turtle)
                        LDURLConnection.hideIndicator()
                    })
                }
            })
            self.queue.addOperation(parseOperation)
            return nil
        }
    }
    
    func cancel() {
        if var connection = self.connection {
            connection.cancel()
        }
        self.queue.cancelAllOperations()
        LDURLConnection.hideIndicator()
    }
    
    func start() -> LDDataReceiver {
        self.cancel()
        LDURLConnection.showIndicator()
        if let connection = self.connection {
            connection.start()
        }
        return self
    }
    
    func receive() {
        self.start()
    }
}