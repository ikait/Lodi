//
//  ResourceDetailTableViewController.swift
//  Lodi
//
//  Created by Taishi Ikai on 2014/11/20.
//  Copyright (c) 2014年 Taishi Ikai. All rights reserved.
//

import UIKit

class ResourceDetailTableViewController: UITableViewController {
    
    // MARK: - Variables
    
    var result: Turtle!
    var resultController: SearchResultController!
    var nextResult: Turtle!
    var nextResultController: SearchResultController!
    
    var dataReceiver: LDDataReceiver!
    var connection: LDURLConnection!
    
    let endpointUrl = "http://www.wikipediaontology.org/query/"
    
    var cancelButton: UIBarButtonItem!
    var alterButton: UIBarButtonItem!
    
    var baseType = RDFNodeType.Subject  // Default
    var nextBaseType = RDFNodeType.Subject  // Default
    
    var baseUrl = ""  // url
    
    //
    let labelIRI = "<http://www.w3.org/2000/01/rdf-schema#label>"
    let commentIRI = "<http://www.w3.org/2000/01/rdf-schema#comment>"
    let typeIRI = "<http://www.w3.org/1999/02/22-rdf-syntax-ns#type>"
    let hyperIRI = "<http://www.wikipediaontology.org/vocabulary#hyper>"
    
    /// app
    var appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
    
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
        
        
        /// cancel button
        self.cancelButton = UIBarButtonItem(
            barButtonSystemItem: UIBarButtonSystemItem.Stop,
            target: self, action: "cancelButtonDidTouchUpInside:") as UIBarButtonItem
        self.cancelButton.enabled = false
        
        var space = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace, target: nil, action: nil)
        self.navigationItem.rightBarButtonItems = [space, self.cancelButton]
        
        // current title?

        if self.result.triples.count > 0 {
            
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
        } else {
            self.navigationItem.title = "None"
        }
        
        /// title view
        var navigationBarTitleView = NavigationBarTitleWithSubtitleView(frame:
            CGRect(x: 0, y: 0,
                width: appDelegate.screen.width,
                height: 44))
        self.navigationItem.titleView = navigationBarTitleView
        
        navigationBarTitleView.titleText = self.navigationItem.title!
        navigationBarTitleView.detailText = self.baseType.rawValue
        navigationBarTitleView.addGestureRecognizer(UITapGestureRecognizer(target: self,
            action: "navigationBarTitleViewDidTouchUpInside"))
        
        // to fix issue tabbar covers tableview
        // * there is no self.tabbarController when it presents modally
        self.edgesForExtendedLayout = UIRectEdge.All
        self.tableView.contentInset.bottom = 49  // XXX
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
    
    func cellHasUriDidTouchUpInside(uri: String) {
        self.performSegueAfterReceiveData(uri)
    }
    
    func performSegueAfterReceiveData(uri: String) {
        self.readyForReceiving()
        
        var query = "CONSTRUCT {"  // TODO: make uri/query dynamically
        
        switch self.nextBaseType {
        case .Subject :
            query += "\(uri) ?p ?o"
            break
        case .Predicate:
            query += "?s \(uri) ?o"
            break
        case .Object:
            query += "?s ?p \(uri)"
            break
        default:
            break
        }
        query += "}"
        
        query += "\nWHERE {"
        switch self.nextBaseType {
        case .Subject :
            query += "\(uri) ?p ?o"
            break
        case .Predicate:
            query += "?s \(uri) ?o"
            break
        case .Object:
            query += "?s ?p \(uri)"
            break
        default:
            break
        }
        query += "}"
        
        println(query)
        
        var connection = LDURLConnection(url: NSURL(string: endpointUrl)!)
        connection.setRequestMethod("POST")
        connection.setRequestBodyWithPercentEscaping("q=\(query)&type=turtle")
        
        self.dataReceiver = LDDataReceiver(connection: connection, getTurtleHandler: { turtle in
            self.nextResult = turtle
            self.performSegueWithIdentifier("ShowDetail", sender: self)
        }).start()
    }
    
    
    func navigationBarTitleViewDidTouchUpInside() {
        println("Pushed navigationBarTitleView!")
        
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
        
        if result.triples.count == 0 {
            return 0
        }
        
        return 2
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var count = 0
        
        if section == 0 {
            count += 1
        } else {
            count += result.triples.count
        }
        return count
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return NSLocalizedString("Overview", comment: "on ResourceDetailTableViewController")
        case 1:
            return NSLocalizedString("Detail", comment: "on ResourceDetailTableViewController")
        default:
            return ""
        }
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        var reuseIdentifier = "Cell"
        if self.result.triples.count == 0 {
            return tableView.dequeueReusableCellWithIdentifier(reuseIdentifier) as ResourceDetailOverviewTableViewCell
        }
        
        var triple = self.result.triples[indexPath.row]
        
        if indexPath.section == 0 {
            reuseIdentifier = "OverviewCell"
            
            let cell = tableView.dequeueReusableCellWithIdentifier(reuseIdentifier, forIndexPath: indexPath) as ResourceDetailOverviewTableViewCell
            
            cell.labelLabel.text = ""
            cell.commentLabel.text = ""
            
            if let triple = self.result.getTriple(predicate: self.labelIRI) {
                cell.labelLabel.text = triple.o.shortValue
            }
            
            if let triple = self.result.getTriple(predicate: self.commentIRI) {
                cell.commentLabel.text = triple.o.shortValue
            }
            
            cell.iriLabel.text = self.result.triples[0].s.value
            
            return cell
            
        } else {
            
            let cell = tableView.dequeueReusableCellWithIdentifier(reuseIdentifier, forIndexPath: indexPath) as ResourceDetailTableViewCell
            
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
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        var triple = self.result.triples[indexPath.row]
        
        if indexPath.section == 0 {
            
            var url = ""
            switch self.baseType {
            case RDFNodeType.Subject:
                url = self.result.triples[0].s.valuePrefixConnected
                break
            case RDFNodeType.Predicate:
                url = self.result.triples[0].p.valuePrefixConnected
                break
            case RDFNodeType.Object:
                url = self.result.triples[0].o.valuePrefixConnected
                break
            default:
                url = ""
                break
            }
            url = TurtleTripleTerm.removeChevrons(url)
            
            var alertController = UIAlertController(
                title: url,
                message: "",
                preferredStyle: UIAlertControllerStyle.ActionSheet)
            
            alertController.addAction(UIAlertAction(
                title: NSLocalizedString("Open in Safari",
                    comment: "on ResourceDetailTableViewController") ,
                style: UIAlertActionStyle.Default,
                handler: { action in
                //
                    println("Open in Safari! \(url)")
                    if let eurl = LDURLConnection.generateEncodedUrl(url) {
                        if let url = NSURL(string: eurl) {
                            UIApplication.sharedApplication().openURL(url)
                        }
                    }
            }))
            
            alertController.addAction(UIAlertAction(
            title: NSLocalizedString("Copy this URL",
                    comment: "on ResourceDetailTableViewController") ,
                style: UIAlertActionStyle.Default,
                handler: { action in
                    println("Copy!! \(url)")
                    
                    UIPasteboard.generalPasteboard().string = "url"
                    
            }))
            
            alertController.addAction(UIAlertAction(
                title: NSLocalizedString("Cancel", comment: "Cancel in UIAlertAction"),
                style: UIAlertActionStyle.Cancel,
                handler: { action in
                    
                    // 選択解除
                    self.tableView.deselectRowAtIndexPath(indexPath, animated: true)
            }))
            self.presentViewController(alertController, animated: true, completion: nil)
            
        } else {
            
            // if type or hyper or a, be searching object 
            // except current type is object
            if (self.result.triples[indexPath.row].p.value == "a" ||
                self.result.triples[indexPath.row].p.value == self.typeIRI ||
                self.result.triples[indexPath.row].p.value == self.hyperIRI) && self.baseType != RDFNodeType.Object
            {
                var object = self.result.triples[indexPath.row].o
                self.nextBaseType = RDFNodeType.Object
                self.cellHasUriDidTouchUpInside(object.valuePrefixConnected)
            } else {
                
                self.nextBaseType = RDFNodeType.Subject
                
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
            var lbTableVC = segue.destinationViewController as ResourceDetailTableViewController
            lbTableVC.result = self.nextResult
            lbTableVC.resultController = self.nextResultController
            lbTableVC.baseType = self.nextBaseType
        }
    }
    

}
