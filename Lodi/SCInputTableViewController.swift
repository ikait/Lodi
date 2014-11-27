//
//  SearchConditionElementChoiceTableViewController.swift
//  Lodi
//
//  Created by Taishi Ikai on 2014/11/18.
//  Copyright (c) 2014年 Taishi Ikai. All rights reserved.
//

import UIKit

class SCInputTableViewController: UITableViewController {
    
    var condition: SearchCondition!
    var conditionController: SearchConditionController!
    
    var editingElement: SearchConditionElement?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        // self.navigationController?.toolbarHidden = false
        
        self.tableView.rowHeight = 44
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.tableView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // MARK: - Unwind
    
    @IBAction func unwindToSCInputTableViewController(segue: UIStoryboardSegue) {
        
    }
    
    
    // MARK: - Events
    
    func variableSwitchDidChange(variableSwitch: UISwitch) {
        switch variableSwitch.tag {
        case 0:
            condition?.subject.variable = variableSwitch.on
        case 1:
            condition?.predicate.variable = variableSwitch.on
        case 2:
            condition?.object.variable = variableSwitch.on
        default:
            break
        }
        
        self.tableView.reloadSections(NSIndexSet(index: variableSwitch.tag),
            withRowAnimation: UITableViewRowAnimation.Automatic)
    }
    
    func showSwitchDidChange(showSwitch: UISwitch) {
        switch showSwitch.tag {
        case 0:
            condition?.subject.show = showSwitch.on
        case 1:
            condition?.predicate.show = showSwitch.on
        case 2:
            condition?.object.show = showSwitch.on
        default:
            break
        }
    }
 
    
    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 3
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        var element: SearchConditionElement!
        
        switch section {
        case 0:
            element = self.condition.subject
        case 1:
            element = self.condition.predicate
        case 2:
            element = self.condition.object
        default:
            break
        }
        
        switch element.variable {
        case true:
            return 3
        case false:
            return 2
        default:
            return 0
        }
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        var reuseIdentifier = "VariableCell"
        var element: SearchConditionElement!
        
        switch indexPath.section {
        case 0:
            element = self.condition.subject
        case 1:
            element = self.condition.predicate
        case 2:
            element = self.condition.object
        default:
            break
        }
        
        switch indexPath.row {
        case 0:
            reuseIdentifier = "VariableCell"
            let cell = tableView.dequeueReusableCellWithIdentifier(reuseIdentifier, forIndexPath: indexPath) as SCInputVariableSwitchTableViewCell
            cell.variableSwitch.on = element.variable
            cell.variableSwitch.tag = indexPath.section
            cell.variableSwitch.addTarget(self,
                action: "variableSwitchDidChange:",
                forControlEvents: UIControlEvents.ValueChanged)
            return cell
        case 1:
            if element.variable {
                reuseIdentifier = "LabelCell"
                let cell = tableView.dequeueReusableCellWithIdentifier(reuseIdentifier, forIndexPath: indexPath) as SCInputTableViewCell
                cell.labelTextField.text = element.variableLabel
                cell.labelTextField.tag = indexPath.section
                return cell
            } else {
                reuseIdentifier = "KeywordCell"
                let cell = tableView.dequeueReusableCellWithIdentifier(reuseIdentifier, forIndexPath: indexPath) as SCInputTableViewCell
                cell.keywordTextField.text = element.getVariableLabelOrShortValue(prefix: false)
                cell.keywordTextField.tag = indexPath.section
                return cell
            }
        case 2:
            if element.variable {
                reuseIdentifier = "ShowInResultCell"
                let cell = tableView.dequeueReusableCellWithIdentifier(reuseIdentifier, forIndexPath: indexPath) as SCInputShowSwitchTableViewCell
                cell.showSwitch.on = element.show
                cell.showSwitch.tag = indexPath.section
                cell.showSwitch.addTarget(self,
                    action: "showSwitchDidChange:",
                    forControlEvents: UIControlEvents.ValueChanged)
                return cell
            }
        default:
            break
        }
        
        
        let cell = tableView.dequeueReusableCellWithIdentifier(reuseIdentifier, forIndexPath: indexPath) as UITableViewCell


        return cell
    }
    
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        var title = ""
        switch section {
        case 0:
            title = "Subject"
        case 1:
            title = "Predicate"
        case 2:
            title = "Object"
        default:
            break
        }
        return title
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        switch indexPath.section {
        case 0:
            self.editingElement = self.condition?.subject
        case 1:
            self.editingElement = self.condition?.predicate
        case 2:
            self.editingElement = self.condition?.object
        default:
            break
        }
        
        switch indexPath.row {
        case 0:
            break;
        case 1:
            if self.editingElement!.variable {
                self.performSegueWithIdentifier("EditLabel", sender: self)
            } else {
                self.performSegueWithIdentifier("EditKeyword", sender: self)
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
        
        if segue.identifier == "EditLabel" {
            var labelTableVC = segue.destinationViewController as SCLabelTableViewController
            labelTableVC.editingElement = self.editingElement
            labelTableVC.conditionController = self.conditionController
        } else if segue.identifier == "EditKeyword" {
            var keywordCandidateTableVC = segue.destinationViewController as SCKeywordCandidateTableViewController
            keywordCandidateTableVC.editingElement = self.editingElement
        }
        
        // FIXME: - via switch don't run well..??
        /*
        switch segue.identifier! {
        case "EditLabel":
            var labelTableVC = segue.destinationViewController as SCLabelTableViewController
            labelTableVC.editingElement = self.editingElement
            break
        case "EditKeyword":
            var keywordCandidateTableVC = segue.destinationViewController as SCKeywordCandidateTableViewController
            keywordCandidateTableVC.editingElement = self.editingElement
            break
        default:
            break
        }
        */
    }

}
