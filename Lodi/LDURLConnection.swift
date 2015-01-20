//
//  LDURLConnection.swift
//  Lodi
//
//  Created by Taishi Ikai on 2014/11/25.
//  Copyright (c) 2014年 Taishi Ikai. All rights reserved.
//

import UIKit

class LDURLConnection: NSObject, NSURLConnectionDataDelegate {
    
    
    // MARK: Variables
    
    var url: NSURL
    
    var request: NSMutableURLRequest
    var connection: NSURLConnection?
    
    var completionHandler: (NSData -> AnyObject?)?
    var receivedData: NSMutableData!
    
    var queue = NSOperationQueue()
    var runloop = NSRunLoop()
    
    var finished = false
    

    
    // MARK: Initialize
    
    init(url: NSURL, completionHandler: (NSData -> AnyObject?)? = nil) {
        self.url = url
        self.completionHandler = completionHandler
        self.request = NSMutableURLRequest(URL: url)
    }
    
    
    // MARK: Connection Methods
    
    func cancel() {
        if let con = self.connection {
            con.cancel()
            self.finish()
        }
        
        self.queue.cancelAllOperations()
    }
    
    func start() {
        
        // Ready
        self.connection = NSURLConnection(request: self.request, delegate: self, startImmediately: false)
        self.receivedData = NSMutableData()
        
        
        // Go
        self.queue.addOperationWithBlock({
            if var connection = self.connection {
                connection.start()
                do {
                    NSRunLoop.currentRunLoop().runUntilDate(NSDate.distantFuture() as NSDate)
                } while (!self.finished)
            }
        })
        
//        dispatch_async(queue, {
//            if var connection = self.connection {
//                connection.start()
//                self.runloop = NSRunLoop.currentRunLoop()
//                self.runloop.runUntilDate(NSDate.distantFuture() as NSDate)
//            }
//        })
    }
    
    private func finish() {
        self.finished = true
    }
    
    
    // MARK: Setting
    
    func setRequestMethod(method: String) -> LDURLConnection {
        self.request.HTTPMethod = method
        return self
    }
    
    func setRequestBody(body: String) -> LDURLConnection {
        self.request.HTTPBody = body.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)
        return self
    }
    
    func setRequestBodyWithPercentEscaping(body: String) -> LDURLConnection {
        self.setRequestBody(body.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())!)
        return self
    }
    
    
    // MARK: Delegate Methods
    
    func connection(connection: NSURLConnection, didFailWithError error: NSError) {
        println("-------------------------------------------------------------")
        NSLog("\n%@\nError: %@", "[connection:didFailWithError]", error)
        self.finish()
    }
    
    func connection(connection: NSURLConnection, willSendRequest request: NSURLRequest, redirectResponse response: NSURLResponse?) -> NSURLRequest? {
        println("-------------------------------------------------------------")
        NSLog("\n%@\nRequest: %@", "[connection:willSendRequest]", request)
        
        return request
    }
    
    func connection(connection: NSURLConnection, didReceiveResponse response: NSURLResponse) {
        println("-------------------------------------------------------------")
        NSLog("\n%@\nResponse: %@", "[connection:didReceiveResponse]", response)
    }
    
    func connection(connection: NSURLConnection, didReceiveData data: NSData) {
        println("-------------------------------------------------------------")
        NSLog("\n%@", "[connection:didReceiveData]")
        
        self.receivedData.appendData(data)
    }
    
    func connectionDidFinishLoading(connection: NSURLConnection) {
        println("-------------------------------------------------------------")
        NSLog("\n%@\nConnection: %@", "[connectionDidFinishLoading]", connection)
        
        if let f = completionHandler {
            if !self.finished {
                f(self.receivedData)
            }
        }
        self.finish()
    }
    
    class func generateEncodedUrl(url: String) -> String? {
        return url.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())
    }
    
    class func showIndicator() {
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
    }
    
    class func hideIndicator() {
        UIApplication.sharedApplication().networkActivityIndicatorVisible = false
    }

}