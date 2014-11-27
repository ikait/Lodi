//
//  Connection.swift
//  Lodi
//
//  Created by Taishi Ikai on 2014/11/19.
//  Copyright (c) 2014年 Taishi Ikai. All rights reserved.
//

import UIKit

class ConnectionToEndpoint {
    
    // MARK: - Variables
    
    var url: NSURL
    var query: String
    var request: NSMutableURLRequest
    
    var appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
    var connection = NSURLConnection()
    
    var queryBodyKey = ["query", "q"]
    var retryCount = 0
    let retryLimit = 2
    var parsed = false
    
    init(url: NSURL, query: String) {
        self.url = url
        self.query = query
        self.request = NSMutableURLRequest(URL: self.url)
    }
    
    func execute(completionHandler: SearchResultController -> ()) {
        
        //
        NSLog("\n%@\n%@ - %@(%d)",
            self.query, self.url, self.queryBodyKey[self.retryCount], self.retryCount)
        
        //
        self.appDelegate.app.networkActivityIndicatorVisible = true
        
        // Set the header(s).
        // request.setValue(<#value: String?#>, forHTTPHeaderField: <#String#>)
        
        // Set the method(HTTP-POST)
        request.HTTPMethod = "POST"
        
        // Set the request-body
        var body = "\(self.queryBodyKey[self.retryCount])=\(self.query)"
        body = body.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!
        request.HTTPBody = body.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)
        
        // Send the url-request.
        NSURLConnection.sendAsynchronousRequest(request,
            queue: NSOperationQueue.mainQueue(),
            completionHandler: {
                (response: NSURLResponse?, data: NSData?, error: NSError?) in
                
                // FIXME: - data なし, 通信失敗時の処理
                
                if let data = data {
                    println("Received data!")
                    
                    if let response = response {
                        NSLog("%@", response)
                    }
                    
                    self.appDelegate.app.networkActivityIndicatorVisible = false
                    
                    var searchResultController = SearchResultController(xmlData: data)
                    
                    if searchResultController.parse() {
                        completionHandler(searchResultController)
                        return
                    }
                }
                
                if let error = error {
                    NSLog("%@", error)
                    
                    if error.code == -1001 {
                        println("[ConnnectionToEndpoint.execute()] Timed out. Retry...")
                        self.execute(completionHandler)
                    }
                    
                    if let response = response {
                        NSLog("%@", response)
                    }
                }

                self.retryCount = self.retryCount + 1
                if self.retryCount == self.retryLimit {
                    NSLog("%@", "Retry ended. ")
                    return
                } else {
                    self.execute(completionHandler)
                }

        })
    }
    
    //
    // type はファイルタイプ, 
    // SearchResultFile は NTriplesクラスなどの継承元
    //
    // func execute(type: SearchResultType, completionHandler: SearchResultFile -> ()) {
    func executeWithNTriples(completionHandler: NTriples -> ()) {
        //
        NSLog("\n%@\n%@ - %@(%d)",
            self.query, self.url, self.queryBodyKey[self.retryCount], self.retryCount)
        
        //
        self.appDelegate.app.networkActivityIndicatorVisible = true
        
        // Set the header(s).
        // request.setValue(<#value: String?#>, forHTTPHeaderField: <#String#>)
        
        // Set the method(HTTP-POST)
        request.HTTPMethod = "POST"
        
        // Set the request-body
        var body = "\(self.queryBodyKey[self.retryCount])=\(self.query)&format=text/plain"
        body = body.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!
        request.HTTPBody = body.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)
        
        // Send the url-request.
        NSURLConnection.sendAsynchronousRequest(request,
            queue: NSOperationQueue.mainQueue(),
            completionHandler: {
                (response: NSURLResponse?, data: NSData?, error: NSError?) in
                
                // FIXME: - data なし, 通信失敗時の処理
                
                if let data = data {
                    println("Received data!")
                    if let response = response {
                        NSLog("%@", response)
                    }
                    self.appDelegate.app.networkActivityIndicatorVisible = false
                    
                    var ntriples = NTriples(data: data)
                    if ntriples.parse() {
                        completionHandler(ntriples)
                        return
                    }
                }
                
                if let error = error {
                    NSLog("%@", error)
                    
                    if error.code == -1001 {
                        println("[ConnnectionToEndpoint.executeWithNTriples()] Timed out. Retry...")
                        self.executeWithNTriples(completionHandler)
                    }
                    
                    if let response = response {
                        NSLog("%@", response)
                    }
                }
        })
        
    }
    
    
    //
    // type はファイルタイプ,
    // SearchResultFile は NTriplesクラスなどの継承元
    //
    // func execute(type: SearchResultType, completionHandler: SearchResultFile -> ()) {
    func executeWithTurtle(completionHandler: Turtle -> ()) {
        //
        NSLog("\n%@\n%@ - %@(%d)",
            self.query, self.url, self.queryBodyKey[self.retryCount], self.retryCount)
        
        //
        self.appDelegate.app.networkActivityIndicatorVisible = true
        
        // Set the header(s).
        // request.setValue(<#value: String?#>, forHTTPHeaderField: <#String#>)
        
        // Set the method(HTTP-POST)
        request.HTTPMethod = "POST"
        
        // Set the request-body
        var body = "\(self.queryBodyKey[self.retryCount])=\(self.query)"
        body = body.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!
        request.HTTPBody = body.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)
        
        // Send the url-request.
        NSURLConnection.sendAsynchronousRequest(request,
            queue: NSOperationQueue.mainQueue(),
            completionHandler: {
                (response: NSURLResponse?, data: NSData?, error: NSError?) in
                
                // FIXME: - data なし, 通信失敗時の処理
                
                if let data = data {
                    println("Received data!")
                    if let response = response {
                        NSLog("%@", response)
                    }
                    self.appDelegate.app.networkActivityIndicatorVisible = false
                    
                    var turtle = Turtle(data: data)
                    if turtle.parse() {
                        completionHandler(turtle)
                        return
                    }
                }
                
                if let error = error {
                    NSLog("%@", error)
                    
                    if error.code == -1001 {
                        println("[ConnnectionToEndpoint.executeWithNTriples()] Timed out. Retry...")
                        self.executeWithTurtle(completionHandler)
                    }
                    
                    if let response = response {
                        NSLog("%@", response)
                    }
                }
        })
        
    }

    

    
}