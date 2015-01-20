//
//  AppDelegate.swift
//  Lodi
//
//  Created by Taishi Ikai on 2014/11/12.
//  Copyright (c) 2014年 Taishi Ikai. All rights reserved.
//

import UIKit
import CoreData

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, NSFetchedResultsControllerDelegate {

    var window: UIWindow?
    var app = UIApplication.sharedApplication()
    
    var screen = Screen()
    
    var resources: Dictionary<String, Resource> = [:]
    

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        
        self.addResource("http://www.wikipediaontology.org/instance/品川区", type: ResourceType.URI)
        self.addResource("http://www.wikipediaontology.org/instance/台東区", type: ResourceType.URI)
        self.addResource("http://www.wikipediaontology.org/instance/練馬区", type: ResourceType.URI)
        self.addResource("http://www.wikipediaontology.org/instance/港区", type: ResourceType.URI)
        self.addResource("http://www.wikipediaontology.org/instance/千代田区", type: ResourceType.URI)
        self.addResource("http://www.wikipediaontology.org/instance/板橋区", type: ResourceType.URI)
        self.addResource("http://www.wikipediaontology.org/instance/福澤諭吉", type: ResourceType.URI)
        self.addResource("http://www.wikipediaontology.org/class/自動車メーカー", type: ResourceType.URI)
        
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
        self.saveContext()
    }
    
    func addResource(uri: String, type: ResourceType) {
        self.resources[uri] = Resource(value: uri, type: type)
        
        /*
        let context = self.fetchedResultsController.managedObjectContext
        let entity = self.fetchedResultsController.fetchRequest.entity!
        let newManagedObject = NSEntityDescription.insertNewObjectForEntityForName(entity.name!, inManagedObjectContext: context) as NSManagedObject
        
        // If appropriate, configure the new managed object.
        // Normally you should use accessor methods, but using KVC here avoids the need to add a custom class to the template.
        newManagedObject.setValue(uri, forKey: "value")
        
        var error: NSError? = nil
        if !context.save(&error) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            // println("Unresolved error \(error), \(error.userInfo)")
            abort()
        }
        */
    }
    
    func getResource(index: Int) -> Resource {
        var keys = self.resources.keys
        return self.resources[keys.array[index]]!
    }
    
    func getResource(indexPath: NSIndexPath) -> Resource {  // FIXME:
        let object = self.fetchedResultsController.objectAtIndexPath(indexPath) as NSManagedObject
        var value: AnyObject? = object.valueForKey("value")
        return Resource(value: value! as String, type: ResourceType.URI)
    }
    
    func addResourceFromNTriples(ntriples: [NTriplesTriple]) {
        for ntriple in ntriples {
            var type = ResourceType.None, value = ""
            if ntriple.s.type == NTriplesPartType.URI {
                type = ResourceType.URI
            } else {
                type = ResourceType.Literal
            }
            self.addResource(ntriple.s.value, type: type)
            if ntriple.p.type == NTriplesPartType.URI {
                type = ResourceType.URI
            } else {
                type = ResourceType.Literal
            }
            self.addResource(ntriple.p.value, type: type)
            if ntriple.o.type == NTriplesPartType.URI {
                type = ResourceType.URI
            } else {
                type = ResourceType.Literal
            }
            self.addResource(ntriple.o.value, type: type)
        }
    }
    
    func addResourceFromTurtleTriples(triples: [TurtleTriple]) {
        for triple in triples {
            var type = ResourceType.None
            if triple.s.type == TurtleTritlePartType.uri || triple.s.type == TurtleTritlePartType.prefixValue {
                type = ResourceType.URI
                self.addResource(triple.s.valuePrefixConnected, type: type)
            }
            if triple.p.type == TurtleTritlePartType.uri || triple.p.type == TurtleTritlePartType.prefixValue {
                type = ResourceType.URI
                self.addResource(triple.p.valuePrefixConnected, type: type)
            }
            if triple.o.type == TurtleTritlePartType.uri || triple.o.type == TurtleTritlePartType.prefixValue {
                type = ResourceType.URI
                self.addResource(triple.o.valuePrefixConnected, type: type)
            }
        }
    }
    
    struct Screen {
        var rect = UIScreen.mainScreen().bounds
        var width = UIScreen.mainScreen().bounds.size.width
        var height = UIScreen.mainScreen().bounds.size.height
    }
    
    
    // MARK: - Core Data stack
    
    lazy var applicationDocumentsDirectory: NSURL = {
        // The directory the application uses to store the Core Data store file. This code uses a directory named "tokyo.ikai.Lodi" in the application's documents Application Support directory.
        let urls = NSFileManager.defaultManager().URLsForDirectory(NSSearchPathDirectory.DocumentDirectory, inDomains: NSSearchPathDomainMask.UserDomainMask)
        return urls[urls.count - 1] as NSURL
    }()

    lazy var managedObjectModel: NSManagedObjectModel = {
        let modelURL = NSBundle.mainBundle().URLForResource("Lodi", withExtension: "momd")!
        return NSManagedObjectModel(contentsOfURL: modelURL)!
    }()
    
    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator? = {
        var coordinator: NSPersistentStoreCoordinator? = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        let storeURL = self.applicationDocumentsDirectory.URLByAppendingPathComponent("Lodi.sqlite")
        
        var error: NSError? = nil
        var failureReason = "There was an error creating or loading the application's saved data."
        if coordinator!.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: storeURL, options: nil, error: &error) == nil {
            coordinator = nil
            
            // Report any error we got
            let dict = NSMutableDictionary()
            dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data"
            dict[NSLocalizedFailureReasonErrorKey] = failureReason
            dict[NSUnderlyingErrorKey] = error
            error = NSError(domain: "YOUR_ERROR_DOMAIN", code: 9999, userInfo: dict)
            // Replace this with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog("Unresolved error \(error), \(error!.userInfo)")
            abort()
        }
        return coordinator
    }()
    
    lazy var managedObjectContext: NSManagedObjectContext? = {
        // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.) This property is optional since there are legitimate error conditions that could cause the creation of the context to fail.
        let coordinator = self.persistentStoreCoordinator
        if coordinator == nil {
            return nil
        }
        var managedObjectContent = NSManagedObjectContext()
        managedObjectContent.persistentStoreCoordinator = coordinator
        return managedObjectContent
    }()
    
    
    // MARK: - Core Data Saving support
    
    func saveContext() {
        if let moc = self.managedObjectContext {
            var error: NSError? = nil
            if moc.hasChanges && !moc.save(&error) {
                // Replace this implementation with code to handle the error appropriately.
                // about() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                NSLog("Unresolved error \(error), \(error!.userInfo)")
                abort()  // FIXME:
            }
        }
    }
    
    
    // MARK: - Fetched results controller
    
    var fetchedResultsController: NSFetchedResultsController {
        if _fetchedResultController != nil {
            return _fetchedResultController!
        }
        
        let fetchRequest = NSFetchRequest()
        
        // Edit the entity name as appropriate
        let entity = NSEntityDescription.entityForName("Term", inManagedObjectContext: self.managedObjectContext!)
        fetchRequest.entity = entity
        
        // Set the batch size to suitable number
        fetchRequest.fetchBatchSize = 20
        
        // Edit the sort key as appropriate.
        let sortDescriptor = NSSortDescriptor(key: "value", ascending: false)
        let sortDiscriptors = [sortDescriptor]
        
        fetchRequest.sortDescriptors = sortDiscriptors
        
        // Edit the section name key path and cache name if appropariate.
        // nil for section name key path means "no sections".
        //let aFetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.managedObjectContext!, sectionNameKeyPath: nil, cacheName: "Master")
        let aFetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.managedObjectContext!, sectionNameKeyPath: nil, cacheName: nil)
        aFetchedResultsController.delegate = self
        _fetchedResultController = aFetchedResultsController
        
        var error: NSError? = nil
        
        if !_fetchedResultController!.performFetch(&error) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            //println("Unresolved error \(error), \(error.userInfo)")
            abort()
        }
        
        return _fetchedResultController!
    }
    var _fetchedResultController: NSFetchedResultsController? = nil

    func controllerWillChangeContent(controller: NSFetchedResultsController) {
        
    }
    
    func controller(controller: NSFetchedResultsController, didChangeSection sectionInfo: NSFetchedResultsSectionInfo, atIndex sectionIndex: Int, forChangeType type: NSFetchedResultsChangeType) {

    }
    
    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        
    }
    
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        
    }
}

