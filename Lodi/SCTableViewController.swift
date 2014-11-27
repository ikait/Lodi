//
//  SearchConditionTableViewController.swift
//  Lodi
//
//  Created by Taishi Ikai on 2014/11/15.
//  Copyright (c) 2014年 Taishi Ikai. All rights reserved.
//

import UIKit

class SearchConditionTableViewController:
UITableViewController, UISearchBarDelegate, UITextFieldDelegate {
    
    // MARK: - Variables    
    var condition: SearchCondition?
    var conditionController: SearchConditionController!
    
    var resultController: SearchResultController!
    
    var connection: LDURLConnection!
    var dataReceiver: LDDataReceiver!
    
    // MARK: - Variables related to Storyboard
    var inputKeywordTextField: UITextField!
    var inputElementButton: UIButton!
    
    var finished = false
    
    
    // MARK: - Base

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()

        // MARK: - searchBar
        
        /*
        searchBar.showsSearchResultsButton = false
        searchBar.showsBookmarkButton = false
        searchBar.showsScopeBar = false
        searchBar.delegate = self

        self.navigationItem.titleView = searchBar
        */

        // MARK: - tableView
        self.tableView.rowHeight = 44
    }
    
    override func viewDidDisappear(animated: Bool) {
        self.finish()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if self.conditionController.isEmpty() && self.conditionController.countContidions() == 0 {
            self.conditionController.addEmptyCondition()
        }
        
        self.tableView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // MARK: - Unwind Segue
    
    @IBAction func unwindToSearchConditionTableViewController(segue: UIStoryboardSegue) {
        
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
    
    func inputKeywordTextFieldDidEndEditing() {
        NSLog("%@", "changed!")
        
        self.conditionController.keyword = self.inputKeywordTextField.text
    }
    
    func elementButtonDidTouchUpInside(sender: AnyObject) {
        NSLog("%@", sender.description)
    }

    func searchButtonDidTouchUpInside() {
        println("Pushed search button!")
        
        if self.conditionController.isValid().valid {
            self.searchExecute()
        } else {
            println("Search did not execute because of detective condition setting.")
        }
    }
    
    func limitTextFieldEditingChanged(sender: UITextField) {
        if let limit = sender.text.toInt() {
            if limit > 10000 {
                self.conditionController.limit = 10000
            } else {
                self.conditionController.limit = limit
            }
        } else {
            sender.text = String(self.conditionController.limit)
        }
    }
    
    // MARK: - Connection
    
    func searchExecute() {
        self.ready()
        
        var query = self.conditionController.getQueryString() as String
        
        // TODO: これをうまくやるラッパークラスを用意したい?
        // 現状XMLを読んでいるので、NTriplesを読みに行くことにする？？
//        self.dataReceiver = LDDataReceiver(connection: <#LDURLConnection#>, getTurtleHandler: <#(Turtle -> ())##Turtle -> ()#>)
        
        self.connection = LDURLConnection(url: conditionController.getEndpointUri()!, completionHandler: { data in
            self.resultController = SearchResultController(xmlData: data)
            if self.resultController.parse() && !self.finished {
                self.performSegueWithIdentifier("ShowResult", sender: self)
            }
            return nil
        })
        self.connection.setRequestMethod("POST")
        self.connection.setRequestBodyWithPercentEscaping("query=\(query)")
        self.connection.start()
    }
    
    
    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // Return the number of sections.
        return 4
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Return the number of rows in the section.
        
        switch section {
        case 0:
            return 1  // search execute
        case 1:
            return self.conditionController.countContidions() + 1  // for a cell to add a new condition
        case 2:
            return 1
        case 3:
            return 1
        default:
            return 0
        }
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        var title = ""
        
        switch section {
        case 0:
            title = ""
        case 1:
            title = "Conditions"
        case 2:
            title = "Options"
        case 3:
            title = "Preferences"
        default:
            title = ""
        }
        return title
    }
    
    override func tableView(tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        var title = ""
        
        switch section {
        case 0:
            title = self.conditionController.isValid().comment
        default:
            break
        }
        return title
    }
    

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        var reuseIdentifier = "Cell"
        
        switch indexPath.section {
        case 0:  // search execute
            switch indexPath.row {
            case 0:
                if self.conditionController.isValid().valid {
                    reuseIdentifier = "SearchExecuteCell"
                } else {
                    reuseIdentifier = "SearchWaitCell"
                }
            default:
                break;
            }
        case 1:  // conditions
            switch indexPath.row {
            case 0..<self.conditionController.countContidions():
                reuseIdentifier = "ElementsCell"
                let cell = tableView.dequeueReusableCellWithIdentifier(reuseIdentifier, forIndexPath: indexPath) as SCElementsTableViewCell
                
                var condition = self.conditionController.getCondition(indexPath.row)
                
                var str_s = condition.subject.getVariableLabelOrShortValue(prefix: true)
                var str_p = condition.predicate.getVariableLabelOrShortValue(prefix: true)
                var str_o = condition.object.getVariableLabelOrShortValue(prefix: true)
                
                
                cell.labelSubject.textColor = UIColor.blackColor()
                cell.labelPredicate.textColor = UIColor.blackColor()
                cell.labelObject.textColor = UIColor.blackColor()

                
                if str_s.isEmpty {
                    cell.labelSubject.text = "<Empty>"
                    cell.labelSubject.textColor = UIColor.darkGrayColor()
                } else {
                    cell.labelSubject.text = str_s
                }
                
                if str_p.isEmpty {
                    cell.labelPredicate.text = "<Empty>"
                    cell.labelPredicate.textColor = UIColor.darkGrayColor()
                } else {
                    cell.labelPredicate.text = str_p
                }
                
                if str_o.isEmpty {
                    cell.labelObject.text = "<Empty>"
                    cell.labelObject.textColor = UIColor.darkGrayColor()
                } else {
                    cell.labelObject.text = str_o
                }
                
                if condition.subject.isHidden() {
                    cell.labelSubject.textColor = UIColor.lightGrayColor()
                }
                if condition.predicate.isHidden() {
                    cell.labelPredicate.textColor = UIColor.lightGrayColor()
                }
                if condition.object.isHidden() {
                    cell.labelObject.textColor = UIColor.lightGrayColor()
                }
                
                return cell
                
            default:
                reuseIdentifier = "AddConditionCell"
            }
        case 2:  // options
            
            switch indexPath.row {
            case 0:
                reuseIdentifier = "LimitCell"
                let cell = tableView.dequeueReusableCellWithIdentifier(reuseIdentifier, forIndexPath: indexPath) as SCLimitTableViewCell
                cell.limitTextField.text = String(self.conditionController.limit)
                cell.limitTextField.addTarget(self, action: "limitTextFieldEditingChanged:",
                    forControlEvents: UIControlEvents.EditingChanged)
                return cell
            default:
                break
            }
            
            break
            
        default:
            break;
        }
        
        let cell = tableView.dequeueReusableCellWithIdentifier(reuseIdentifier, forIndexPath: indexPath) as UITableViewCell
        
        // Configure the cell...
        
        return cell
        
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        
        switch indexPath.section {
        case 0:
            switch indexPath.row {
            case 0:
                self.searchButtonDidTouchUpInside()
                break
            default:
                break
            }
            
            break;
        case 1:
            var count = self.conditionController.countContidions()
            
            switch indexPath.row {
            case 0..<count:
                NSLog("%@", "condition!")
                self.condition = self.conditionController.getCondition(indexPath.row)
                self.performSegueWithIdentifier("InputElements", sender: self)
            default:
                NSLog("%@", "add!")
                self.conditionController.addEmptyCondition()
                self.tableView.insertRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Bottom)
                self.tableView.reloadSections(NSIndexSet(index: 0),
                    withRowAnimation: UITableViewRowAnimation.Automatic)
            }
        default:
            break;
        }
        
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        var height: CGFloat = self.tableView.rowHeight
        
        switch indexPath.section {
        case 1:
            var count = self.conditionController.countContidions()
            
            switch indexPath.row {
            case 0..<count:
                height = 50
            default:
                break
            }
        default:
            break;
        }
        return height
    }
    
    override func tableView(tableView: UITableView, accessoryButtonTappedForRowWithIndexPath indexPath: NSIndexPath) {

    }

    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        
        var count = self.conditionController.countContidions()
        
        switch indexPath.section {
        case 1:
            switch indexPath.row {
            case 0..<count:
                if count == 1 {
                    return false
                }
                return true
                default:
                break
            }
        default:
            break
        }
        return false
    }

    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            self.conditionController.removeCondition(indexPath.row)
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
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.

        if segue.identifier == "InputElements" {
            var inputTableVC = segue.destinationViewController as SCInputTableViewController
            inputTableVC.condition = self.condition
            inputTableVC.conditionController = self.conditionController
        } else if segue.identifier == "ShowResult" {
            var srTableVC = segue.destinationViewController as SearchResultTableViewController
            srTableVC.result = self.resultController
        }
        
        // FIXME: - via switch do not run well??
        /*
        switch segue.identifier! {
        case "InputElements":
            var inputTableVC = segue.destinationViewController as SCInputTableViewController
            inputTableVC.condition = self.condition
            break
        default:
            break
        }
        */
    }

}
