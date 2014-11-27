//
//  SSTableViewController.swift
//  Lodi
//
//  Created by Taishi Ikai on 2014/11/19.
//  Copyright (c) 2014年 Taishi Ikai. All rights reserved.
//

import UIKit

class SSTableViewController: UITableViewController {
    
    
    // MARK: - Variables
    
    var conditionController = SearchConditionController()
    var conditionControllerSet = SearchConditionControllerSet()

    var resultController: SearchResultController!
    
    var connection: LDURLConnection!
    
    var finished = false
    
    
    // MARK: - Base
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        self.tableView.rowHeight = 44
        
        /*---------------------------------------------------------------------*/
        // MARK: - DEBUG!!
        self.conditionControllerSet.appendController(
            SearchConditionController(title: "TEST", conditions: [
                SearchCondition(
                    subject: SearchConditionElement(show: false,
                        value: "<http://ja.dbpedia.org/resource/千代田区>",
                        variable: false, variableLabel: ""),
                    predicate: SearchConditionElement(show: true,
                        value: "",
                        variable: true, variableLabel: "p"),
                    object: SearchConditionElement(show: true,
                        value: "",
                        variable: true, variableLabel: "o"))
            ])
        )
        /*---------------------------------------------------------------------*/

    }
    
    override func viewDidDisappear(animated: Bool) {
        self.finish()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.tableView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    // MARK: - Events
    
    func ready() {
        self.finish()
        self.finished = false
    }
    
    func finish() {
        if let connection = self.connection {
            connection.cancel()
        }
        self.finished = true
    }
    
    @IBAction func composeConditionButtonDidTouchUpInside(sender: AnyObject) {
        
        // override, whether or not it exists
        self.conditionController = SearchConditionController()
        
        self.performSegueWithIdentifier("ComposeCondition", sender: self)
    }
    
    func validConditionCellDidTouchUpInside(scc: SearchConditionController) {
        self.ready()

        var query = scc.getQueryString() as String
        connection = LDURLConnection(url: conditionController.getEndpointUri()!, completionHandler: { data in
            self.resultController = SearchResultController(xmlData: data)
            if self.resultController.parse() {
                if !self.finished {
                    self.performSegueWithIdentifier("ShowResult", sender: self)
                }
            }
            return nil
        })
        self.connection.setRequestMethod("POST")
        self.connection.setRequestBodyWithPercentEscaping("query=\(query)")
        self.connection.start()
    }
    
    
    // MARK: - Unwind Segue
    
    @IBAction func unwindToSSTableViewController(segue: UIStoryboardSegue) {
        if segue.identifier == "BackToSSTableVCFromSCTableVC" {
            var scTableVC = segue.sourceViewController as SearchConditionTableViewController
            
            if scTableVC.conditionController.isChangedFromInitialState() {
                if !self.conditionControllerSet.hasController(scTableVC.conditionController) {
                    self.conditionControllerSet.insertController(scTableVC.conditionController, atIndex: 0)
                }
            }
        }
    }
    

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.conditionControllerSet.countControllers()
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var reuseIdentifier = "ConditionCell"
        
        let cell = tableView.dequeueReusableCellWithIdentifier(reuseIdentifier, forIndexPath: indexPath) as UITableViewCell
        
        var conditionController = self.conditionControllerSet.getControllerAtIndex(indexPath.row)

        cell.textLabel.text = conditionController.getTitle()
        cell.detailTextLabel?.text = conditionController.isValid().comment

        return cell
    }
    
    override func tableView(tableView: UITableView, accessoryButtonTappedForRowWithIndexPath indexPath: NSIndexPath) {
        
        self.conditionController = self.conditionControllerSet.getControllerAtIndex(indexPath.row)
        self.performSegueWithIdentifier("ComposeCondition", sender: self)
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        var conditionController = self.conditionControllerSet.getControllerAtIndex(indexPath.row)
        
        if conditionController.isValid().valid {
            self.validConditionCellDidTouchUpInside(conditionController)
        }
    }

    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the specified item to be editable.
        return true
    }
    

    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            self.conditionControllerSet.removeControllerAtIndex(indexPath.row)
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
            
            self.tableView.reloadSections(NSIndexSet(index: 0),
                withRowAnimation: UITableViewRowAnimation.Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }

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
        if segue.identifier == "ComposeCondition" {
            var scTableVC = segue.destinationViewController.topViewController as SearchConditionTableViewController
            scTableVC.conditionController = self.conditionController
        } else if segue.identifier == "ShowResult" {
            var srTableVC = segue.destinationViewController as SearchResultTableViewController
            srTableVC.result = self.resultController
        }
    }

}
