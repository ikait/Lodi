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
    var resultController: SearchResultController!
    var finished = false
    
    var connection: LDURLConnection!
    var editingElement: SearchConditionElement?
    var editingLabel: String!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        // self.navigationController?.toolbarHidden = false
        
        self.tableView.rowHeight = 44
        
        // to fix issue tabbar covers tableview
        // * there is no self.tabbarController when it presents modally
        self.edgesForExtendedLayout = UIRectEdge.All
        self.tableView.contentInset.bottom = 49  // XXX
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
    
    func validConditionCellDidTouchUpInside(scc: SearchConditionController) {
        self.ready()
        
        var query = scc.getQueryString() as String
        connection = LDURLConnection(url: conditionController.getEndpointUri()!, completionHandler: { data in
            
            self.resultController = SearchResultController(jsonData: data)
            if self.resultController.parseJson() && !self.finished {
                self.performSegueWithIdentifier("EditKeywordExample", sender: self)
            }
            
            return nil
        })
        self.connection.setRequestMethod("POST")
        self.connection.setRequestBodyWithPercentEscaping("q=\(query)&type=json")
        self.connection.start()
    }
    
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
            self.conditionController.setVariableShown(condition.subject.variableLabel, show: showSwitch.on)
//            condition?.subject.show = showSwitch.on
        case 1:
            self.conditionController.setVariableShown(condition.predicate.variableLabel, show: showSwitch.on)
//            condition?.predicate.show = showSwitch.on
        case 2:
            self.conditionController.setVariableShown(condition.object.variableLabel, show: showSwitch.on)
//            condition?.object.show = showSwitch.on
        default:
            break
        }
    }
    
    func inputFilterTextFieldDidEditingChanged(textField: UITextField) {
        switch textField.tag {
        case 0:
            self.conditionController.setVariableFilterString(condition.subject.variableLabel, filterString: textField.text.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet()))
        case 1:
            self.conditionController.setVariableFilterString(condition.predicate.variableLabel, filterString: textField.text.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet()))
        case 2:
            self.conditionController.setVariableFilterString(condition.object.variableLabel, filterString: textField.text.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet()))
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
            return 4
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
        case 3:
            if element.variable {
                reuseIdentifier = "FilterCell"
                let cell = tableView.dequeueReusableCellWithIdentifier(reuseIdentifier, forIndexPath: indexPath) as SCInputFilterTableViewCell
                cell.inputFilterTextField.text = element.filterString
                cell.inputFilterTextField.tag = indexPath.section
                cell.inputFilterTextField.addTarget(self,
                    action: "inputFilterTextFieldDidEditingChanged:", forControlEvents: UIControlEvents.EditingChanged)
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
            title = NSLocalizedString("Subject", comment: "section title in SCInputTableVC")
        case 1:
            title = NSLocalizedString("Predicate", comment: "section title in SCInputTableVC")
        case 2:
            title = NSLocalizedString("Object", comment: "section title in SCInputTableVC")
        default:
            break
        }
        return title
    }
    
    override func tableView(tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        var title = ""
        switch section {
        case 0:
            var (valid, comment) = self.condition.subject.isValid()
            title = valid ? "" : comment
        case 1:
            var (valid, comment) = self.condition.predicate.isValid()
            title = valid ? "" : comment
        case 2:
            var (valid, comment) = self.condition.object.isValid()
            title = valid ? "" : comment
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
                self.editingLabel = "xxxx"
                
                if self.conditionController.isEmpty() {
                    self.performSegueWithIdentifier("EditKeyword", sender: self)
                    break
                }
                
                switch indexPath.section {
                case 0: // when subject
                    
                    if !(self.condition.predicate.variable && self.condition.object.variable) &&
                    !(self.condition.predicate.isEmpty() && self.condition.object.isEmpty()) {
                        
                        var predicate = (self.condition.predicate.isValid().valid) ?
                            self.condition.predicate :
                            SearchConditionElement(show: true, value: "",
                                variable: true, variableLabel: "yyyy", filterString: "")
                        var object = (self.condition.object.isValid().valid) ?
                            self.condition.object :
                            SearchConditionElement(show: true, value: "",
                                variable: true, variableLabel: "zzzz", filterString: "")

                        self.validConditionCellDidTouchUpInside(
                            SearchConditionController(title: "",
                                conditions: [
                                    SearchCondition(
                                        subject: SearchConditionElement(show: true,
                                            value: "",
                                            variable: true,
                                            variableLabel: self.editingLabel,
                                            filterString: ""),
                                        predicate: predicate,
                                        object: object)]))
                    } else {
                        // show items already cached
                        self.performSegueWithIdentifier("EditKeyword", sender: self)
                    }
                case 1:
                    if !(self.condition.subject.variable && self.condition.object.variable) &&
                        !(self.condition.subject.isEmpty() && self.condition.object.isEmpty()) {
                        
                        var subject = (self.condition.subject.isValid().valid) ?
                            self.condition.subject :
                            SearchConditionElement(show: true, value: "",
                                variable: true, variableLabel: "yyyy", filterString: "")
                        var object = (self.condition.object.isValid().valid) ?
                            self.condition.object :
                            SearchConditionElement(show: true, value: "",
                                variable: true, variableLabel: "zzzz", filterString: "")
                        
                        self.validConditionCellDidTouchUpInside(
                            SearchConditionController(title: "",
                                conditions: [
                                    SearchCondition(
                                        subject: subject,
                                        predicate: SearchConditionElement(show: true,
                                            value: "",
                                            variable: true,
                                            variableLabel: self.editingLabel,
                                            filterString: ""),
                                        object: object)]))
                    } else {
                        // show items already cached
                        self.performSegueWithIdentifier("EditKeyword", sender: self)
                    }
                case 2:
                    if !(self.condition.subject.variable && self.condition.predicate.variable) &&
                        !(self.condition.subject.isEmpty() && self.condition.predicate.isEmpty()) {
                        
                        var subject = (self.condition.subject.isValid().valid) ?
                            self.condition.subject :
                            SearchConditionElement(show: true, value: "",
                                variable: true, variableLabel: "yyyy", filterString: "")
                        var predicate = (self.condition.predicate.isValid().valid) ?
                            self.condition.predicate :
                            SearchConditionElement(show: true, value: "",
                                variable: true, variableLabel: "zzzz", filterString: "")
                        
                        self.validConditionCellDidTouchUpInside(
                            SearchConditionController(title: "",
                                conditions: [
                                    SearchCondition(
                                        subject: subject,
                                        predicate: predicate,
                                        object: SearchConditionElement(show: true,
                                            value: "",
                                            variable: true,
                                            variableLabel: self.editingLabel,
                                            filterString: ""))]))
                    } else {
                        // show items already cached
                        self.performSegueWithIdentifier("EditKeyword", sender: self)
                    }
                default:
                    break
                }
                
                
            }
        default:
            break
        }
    }

    // MARK: - Connection
    
    
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
            keywordCandidateTableVC.conditionController = self.conditionController
        } else if segue.identifier == "EditKeywordExample" {
            var keywordExamplesTableVC = segue.destinationViewController as KeywordExamplesTableViewController
            keywordExamplesTableVC.resultController = self.resultController
            keywordExamplesTableVC.editingElement = self.editingElement
            keywordExamplesTableVC.editingLabel = self.editingLabel
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
