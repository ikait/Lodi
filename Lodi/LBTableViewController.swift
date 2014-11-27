//
//  LBTableViewController.swift
//  Lodi
//
//  Created by Taishi Ikai on 2014/11/20.
//  Copyright (c) 2014年 Taishi Ikai. All rights reserved.
//

import UIKit

class LBTableViewController: UITableViewController {
    
    // MARK: - Variables
    
    var result: Turtle!
    var nextResult: Turtle!
        
    let endpointUri = "http://ja.dbpedia.org/sparql"
    
    var dataReceiver: LDDataReceiver!
    
    var cancelButton: UIBarButtonItem!
    var alterButton: UIBarButtonItem!
    
    var baseType = RDFNodeType.Subject
    var nextBaseType = RDFNodeType.Subject
    
    var baseUrl = ""  // url
    
    
    // MARK: - Base
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        self.tableView.estimatedRowHeight = 44
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.reloadData()
        
        self.cancelButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Stop, target: self, action: "cancelButtonDidTouchUpInside:")
        self.cancelButton.enabled = false
        
        
        self.alterButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Organize, target: self, action: "alterButtonDidTouchUpInside:")
        self.navigationItem.rightBarButtonItems = [self.cancelButton, self.alterButton]
//        self.navigationItem.rightBarButtonItem = self.cancelButton
        
        
        // 現在のタイプ、タイトルは?
        switch self.baseType {
        case RDFNodeType.Subject:
            self.navigationItem.title = self.result.triples[0].s.shortValue
            self.baseUrl = self.result.triples[0].s.valuePrefixConnected
        case RDFNodeType.Predicate:
            self.navigationItem.title = self.result.triples[0].p.shortValue
            self.baseUrl = self.result.triples[0].p.valuePrefixConnected
        case RDFNodeType.Object:
            self.navigationItem.title = self.result.triples[0].o.shortValue
            self.baseUrl = self.result.triples[0].o.valuePrefixConnected
        default:
            break
        }
        self.navigationItem.prompt = self.baseType.rawValue + " is"
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidDisappear(animated: Bool) {
        self.cancelButton.enabled = false
    }
    

    // MARK: - Events
    
    func readyForReceiving() {
        self.cancelReceiving()
        self.cancelButton.enabled = true
    }
    
    func cancelReceiving() {
        if var dataReceiver = self.dataReceiver {
            dataReceiver.cancel()
        }
        self.cancelButton.enabled = false
    }
    
    func cancelButtonDidTouchUpInside(sender: AnyObject) {
        self.cancelReceiving()
    }
    
    func cellHasUriDidTouchUpInside(uri: String) {  // FIXME: uri/クエリ決めうち
        self.performSegueAfterReceiveData(uri)
    }
    
    func performSegueAfterReceiveData(uri: String) {
        self.readyForReceiving()
        
        var query = "construct where { \(uri) ?p ?o } "
        
        switch self.nextBaseType {
        case .Subject :
            break
        case .Predicate:
            query = "construct where { ?s \(uri) ?o } "
            break
        case .Object:
            query = "construct where { ?s ?p \(uri) } "
            break
        default:
            break
        }
        var connection = LDURLConnection(url: NSURL(string: endpointUri)!)
        connection.setRequestMethod("POST")
        connection.setRequestBodyWithPercentEscaping("query=\(query)&format=text/turtle")
        
        self.dataReceiver = LDDataReceiver(connection: connection, getTurtleHandler: { turtle in
            self.nextResult = turtle
            self.performSegueWithIdentifier("ShowDetail", sender: self)
        }).start()

    }
    
    func alterButtonDidTouchUpInside(sender: AnyObject) {
        println("Pushed alter button!")
        
        var alertController = UIAlertController(title: "", message: self.navigationItem.title! + " as...", preferredStyle: UIAlertControllerStyle.ActionSheet)
        
        alertController.addAction(UIAlertAction(title: "Subject", style: .Default, handler: { action in
            self.nextBaseType = RDFNodeType.Subject
            self.performSegueAfterReceiveData(self.baseUrl)
        }))
        alertController.addAction(UIAlertAction(title: "Predicate", style: .Default, handler: { action in
            self.nextBaseType = RDFNodeType.Predicate
            self.performSegueAfterReceiveData(self.baseUrl)
        }))
        alertController.addAction(UIAlertAction(title: "Object", style: .Default, handler: { action in
            self.nextBaseType = RDFNodeType.Object
            self.performSegueAfterReceiveData(self.baseUrl)
        }))
        alertController.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: { action in
        }))
        
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return result.triples.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var reuseIdentifier = "Cell"
        let cell = tableView.dequeueReusableCellWithIdentifier(reuseIdentifier, forIndexPath: indexPath) as LBTableViewCell
        
        var triple = self.result.triples[indexPath.row]
        
        switch self.baseType {
        case .Subject:
            cell.secondLabel.text = triple.p.value
            cell.firstLabel.text = triple.o.shortValue
            
            if triple.o.isUri() || triple.o.prefix != nil {
                cell.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
            } else {
                cell.accessoryType = UITableViewCellAccessoryType.None
            }
        case .Predicate:
            cell.secondLabel.text = triple.o.value
            cell.firstLabel.text = triple.s.shortValue
            
            if triple.s.isUri() || triple.s.prefix != nil {
                cell.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
            } else {
                cell.accessoryType = UITableViewCellAccessoryType.None
            }
        case .Object:
            cell.secondLabel.text = triple.p.value
            cell.firstLabel.text = triple.s.shortValue
            
            if triple.s.isUri() || triple.s.prefix != nil {
                cell.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
            } else {
                cell.accessoryType = UITableViewCellAccessoryType.None
            }
        default:
            break
        }

        

        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        var triple = self.result.triples[indexPath.row]
        
        switch self.baseType {
        case .Subject:
            var object = self.result.triples[indexPath.row].o
            if object.isUri() {
                self.cellHasUriDidTouchUpInside(object.value)
            }
            if let p = object.prefix {
                self.cellHasUriDidTouchUpInside(object.valuePrefixConnected)
            }
        case .Predicate:
            var s = self.result.triples[indexPath.row].s
            if s.isUri() {
                self.cellHasUriDidTouchUpInside(s.value)
            }
            if let p = s.prefix {
                self.cellHasUriDidTouchUpInside(s.valuePrefixConnected)
            }
        case .Object:
            var s = self.result.triples[indexPath.row].s
            if s.isUri() {
                self.cellHasUriDidTouchUpInside(s.value)
            }
            if let p = s.prefix {
                self.cellHasUriDidTouchUpInside(s.valuePrefixConnected)
            }
        default:
            break
        }
    }
    
    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the item to be re-orderable.
        return true
    }
    */

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "ShowDetail" {
            var lbTableVC = segue.destinationViewController as LBTableViewController
            lbTableVC.result = self.nextResult
            lbTableVC.baseType = self.nextBaseType
        }
    }
    

}
