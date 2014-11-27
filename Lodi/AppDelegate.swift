//
//  AppDelegate.swift
//  Lodi
//
//  Created by Taishi Ikai on 2014/11/12.
//  Copyright (c) 2014年 Taishi Ikai. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var app = UIApplication.sharedApplication()
    
    var screen = Screen()
    
    var resources: Dictionary<String, Resource> = [:]
    

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        
        self.addResource("http://ja.dbpedia.org/resource/品川区", type: ResourceType.uri)
        self.addResource("http://ja.dbpedia.org/resource/台東区", type: ResourceType.uri)
        self.addResource("http://ja.dbpedia.org/resource/練馬区", type: ResourceType.uri)
        self.addResource("http://ja.dbpedia.org/resource/港区", type: ResourceType.uri)
        
        
        
        return true
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    func addResource(uri: String, type: ResourceType) {
        self.resources[uri] = Resource(value: uri, type: type)
    }
    
    func getResource(index: Int) -> Resource {
        var keys = self.resources.keys
        return self.resources[keys.array[index]]!
    }
    
    func addResourceFromNTriples(ntriples: [NTriplesTriple]) {
        for ntriple in ntriples {
            var type = ResourceType.none, value = ""
            if ntriple.s.type == NTriplesPartType.uri {
                type = ResourceType.uri
            } else {
                type = ResourceType.literal
            }
            self.addResource(ntriple.s.value, type: type)
            if ntriple.p.type == NTriplesPartType.uri {
                type = ResourceType.uri
            } else {
                type = ResourceType.literal
            }
            self.addResource(ntriple.p.value, type: type)
            if ntriple.o.type == NTriplesPartType.uri {
                type = ResourceType.uri
            } else {
                type = ResourceType.literal
            }
            self.addResource(ntriple.o.value, type: type)
        }
    }
    
    struct Screen {
        var rect = UIScreen.mainScreen().bounds
        var width = UIScreen.mainScreen().bounds.size.width
        var height = UIScreen.mainScreen().bounds.size.height
    }

}

