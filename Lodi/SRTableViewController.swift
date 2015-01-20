//
//  SearchResultTableViewController.swift
//  Lodi
//
//  Created by Taishi Ikai on 2014/11/12.
//  Copyright (c) 2014年 Taishi Ikai. All rights reserved.
//

import UIKit

class SearchResultTableViewController: UITableViewController {
    
    // MARK: - Variables

    var result: SearchResultController!
    var nextResult: Turtle!
    
    //let endpointUri = "http://dbpedia.org/sparql"
    let endpointUri = "http://www.wikipediaontology.org/query/"
    var dataReceiver: LDDataReceiver!
    
    var cancelButton: UIBarButtonItem!
    
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
            
        self.cancelButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Cancel, target: self, action: "cancelButtonDidTouchUpInside:")
        self.cancelButton.enabled = false
        self.navigationItem.rightBarButtonItem = self.cancelButton
        self.navigationItem.title = NSLocalizedString("Search Results", comment: "")
        
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
    
    func cellHasUriDidTouchUpInside(uri: String) {  // FIXME: uri/クエリ決めうち
        self.readyForReceiving()
        
        var query = "CONSTRUCT {\n"  // TODO: make uri/query dynamically
        query += "<\(uri)> ?p ?o\n"
        //query += "MINUS { <\(uri)> owl:sameAs ?o }\n"
        query += "\n}"
        
        query += "\n"
        query += "WHERE {\n"
        query += "<\(uri)> ?p ?o\n"
        query += "\n}"
        
        println(query)
        
        var connection = LDURLConnection(url: NSURL(string: endpointUri)!)
        connection.setRequestMethod("POST")
        connection.setRequestBodyWithPercentEscaping("q=\(query)&type=turtle")
        
        self.dataReceiver = LDDataReceiver(connection: connection, getTurtleHandler: { turtle in
            self.nextResult = turtle
            self.performSegueWithIdentifier("ShowDetail", sender: self)
        }).start()
    }

    
    // MARK: - Table view data source
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.result.resultItemsCount == 0 {
            return 1
        }
        return self.result.resultItemsCount
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("SearchResultItemCell", forIndexPath: indexPath) as SRTableViewCell
        
        if self.result.resultItemsCount == 0 {
            cell.firstTextLabel.text = NSLocalizedString("No results were found.", comment: "SRTableVC")
            return cell
        }
        
        var result = self.result.resultItems[indexPath.row]
        var str = ""
        for (index, binding) in enumerate(result.bindings) {
            str += "\(binding.name): \(binding.shortValue!)"
            if index != result.bindings.count - 1 {
                str += "\n"
            }
        }
        cell.firstTextLabel.text = str
        
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        if self.result.resultItemsCount == 0 {
            return
        }
        
        var bindings = self.result.resultItems[indexPath.row].bindings
        var object = bindings[bindings.count - 1]  // FIXME: かなりテキトー
            
        var urlcount = 0
        for binding in bindings {
            urlcount += (binding.isUri()) ? 1 : 0;
        }
        
        if urlcount == 1 {
            self.cellHasUriDidTouchUpInside(bindings[0].value)
        } else {
            
            var alertController = UIAlertController(
                title: NSLocalizedString("Which do you choose?", comment: "SRTableVCで選択された際"),
                message: "",
                preferredStyle: UIAlertControllerStyle.ActionSheet)
            
            for binding in bindings {
                if binding.isUri() {
                    alertController.addAction(UIAlertAction(title: binding.shortValue! , style: UIAlertActionStyle.Default, handler: { action in
                        self.cellHasUriDidTouchUpInside(binding.value)
                    }))
                }
            }
            
            alertController.addAction(UIAlertAction(
                title: NSLocalizedString("Cancel", comment: "Cancel in UIAlertAction"),
                style: UIAlertActionStyle.Cancel,
                handler: { action in
                    
                    // 選択解除
                    self.tableView.deselectRowAtIndexPath(indexPath, animated: true)
            }))
            self.presentViewController(alertController, animated: true, completion: nil)
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
        }
    }
    
}
