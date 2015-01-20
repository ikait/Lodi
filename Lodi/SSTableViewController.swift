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
    var dataReceiver: LDDataReceiver!
    
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
            SearchConditionController(title: "東京都を検索", conditions: [
                SearchCondition(
                    subject: SearchConditionElement(show: false,
                        value: "<http://www.wikipediaontology.org/instance/東京都>",
                        variable: false, variableLabel: "", filterString: ""),
                    predicate: SearchConditionElement(show: true,
                        value: "",
                        variable: true, variableLabel: "p", filterString: ""),
                    object: SearchConditionElement(show: true,
                        value: "",
                        variable: true, variableLabel: "o", filterString: ""))
            ])
        )
        
        
        self.conditionControllerSet.appendController(
            SearchConditionController(title: "オのつく自動車メーカー", conditions: [
                SearchCondition(
                    subject: SearchConditionElement(show: true,
                        value: "",
                        variable: true, variableLabel: "maker", filterString: "オ"),
                    predicate: SearchConditionElement(show: true,
                        value: "<http://www.w3.org/1999/02/22-rdf-syntax-ns#type>",
                        variable: false, variableLabel: "", filterString: ""),
                    object: SearchConditionElement(show: true,
                        value: "<http://www.wikipediaontology.org/class/自動車メーカー>",
                        variable: false, variableLabel: "", filterString: ""))
                ])
        )
        /*---------------------------------------------------------------------*/

        // to fix issue tabbar covers tableview
        // * there is no self.tabbarController when it presents modally
        self.edgesForExtendedLayout = UIRectEdge.All
        self.tableView.contentInset.bottom = 49  // XXX
    }
    
    override func viewDidDisappear(animated: Bool) {
        if let dataReceiver = self.dataReceiver {
            dataReceiver.cancel()
        }
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
    
    func readyForReceiving() {
        self.cancelReceiving()
    }
    
    func cancelReceiving() {
        if var dataReceiver = self.dataReceiver {
            dataReceiver.cancel()
        }
    }
    
    func validConditionCellDidTouchUpInside(scc: SearchConditionController) {
        var query = scc.getQueryString() as String
        connection = LDURLConnection(url: conditionController.getEndpointUri()!)
        self.connection.setRequestMethod("POST")
        self.connection.setRequestBodyWithPercentEscaping("q=\(query)&type=json&limit=\(self.conditionController.limit)")
        
        self.dataReceiver = LDDataReceiver(connection: self.connection, getJsonHandler: { resultController in
            self.resultController = resultController
            self.performSegueWithIdentifier("ShowResult", sender: self)
        }).start()
    }
    
    @IBAction func composeConditionButtonDidTouchUpInside(sender: AnyObject) {
        
        // override, whether or not it exists
        self.conditionController = SearchConditionController()
        
        self.performSegueWithIdentifier("ComposeCondition", sender: self)
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

        cell.textLabel?.text = conditionController.getTitle()
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
