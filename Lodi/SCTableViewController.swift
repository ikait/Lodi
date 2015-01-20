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
    
    func titleTextFieldEditingChanged(sender: UITextField) {
        self.conditionController.title = sender.text
    }
    
    // MARK: - Connection
    
    func readyForReceiving() {
        self.cancelReceiving()
    }
    
    func cancelReceiving() {
        if var dataReceiver = self.dataReceiver {
            dataReceiver.cancel()
        }
    }
    
    func searchExecute() {
        var query = self.conditionController.getQueryString() as String
        connection = LDURLConnection(url: conditionController.getEndpointUri()!)
        self.connection.setRequestMethod("POST")
        self.connection.setRequestBodyWithPercentEscaping("q=\(query)&type=json&limit=\(self.conditionController.limit)")
        
        self.dataReceiver = LDDataReceiver(connection: self.connection, getJsonHandler: { resultController in
            self.resultController = resultController
            self.performSegueWithIdentifier("ShowResult", sender: self)
        }).start()
    }
    
    
    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // Return the number of sections.
        return SectionNumber.count
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Return the number of rows in the section.
        
        switch section {
        case SectionNumber.SearchExecute.rawValue:
            return 1  // search execute
        case SectionNumber.ConditionList.rawValue:
            return self.conditionController.countContidions() + 1  // for a cell to add a new condition
        case SectionNumber.Options.rawValue:
            return 2
        case SectionNumber.Preferences.rawValue:
            return 1
        default:
            return 0
        }
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        var title = ""
        
        switch section {
        case SectionNumber.SearchExecute.rawValue:
            title = ""
        case SectionNumber.ConditionList.rawValue:
            title = NSLocalizedString("Conditions", comment: "")
        case SectionNumber.Options.rawValue:
            title = NSLocalizedString("Options", comment: "")
        case SectionNumber.Preferences.rawValue:
            title = NSLocalizedString("Preferences", comment: "")
        default:
            title = ""
        }
        return title
    }
    
    override func tableView(tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        var title = ""
        
        switch section {
        case SectionNumber.SearchExecute.rawValue:
            
            title = self.conditionController.isValid().comment
            
            if self.conditionController.isValid().valid {
                
                let includeText = NSLocalizedString("includes: ", comment: "on SCTVC")
                let orderText = NSLocalizedString("order", comment: "on SCTVC")
                title += "  "
                title += NSLocalizedString("Condition you wrote is below:\n", comment: "on SCTVC")
                
                title += "👉 " + self.conditionController.getUnderstandable()
                
                title += "\n\n"
                
                title += NSLocalizedString("In this, the following words will be searched:\n", comment: "on SCTVC")
                for l in self.conditionController.getVariableLabels() {
                    if self.conditionController.isVariableShown(l) {
                        var fs = self.conditionController.getVariableFilterString(l)
                        var o = self.conditionController.getVariableOrder(l)
                        if fs.isEmpty {
                            title += "👉 ?\(l)"
                        } else {
                            title += "👉 ?\(l) (\(includeText) \"\(fs)\")"
                        }
                        
                        if o != SearchConditionVariableOrder.None {
                            title += " (\(o.toString()) \(orderText))"
                        }
                        
                        if l != self.conditionController.getVariableLabels().last! {
                            title += "\n"
                        }
                    }
                }
            }
        case SectionNumber.Options.rawValue:
            title = NSLocalizedString("To be fast to show results, Limit is preferred to low. It's recommended to set less than about 200.", comment: "on SCTableVC")
        case SectionNumber.Preferences.rawValue:
            title = NSLocalizedString("Input a title that express this search. It's just displayed on the search list and no influence on search results.", comment: "on SCTableVC")
        default:
            break
        }
        return title
    }
    

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        var reuseIdentifier = "Cell"
        
        switch indexPath.section {
        case SectionNumber.SearchExecute.rawValue:  // search execute
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
        case SectionNumber.ConditionList.rawValue:  // conditions
            switch indexPath.row {
            case 0..<self.conditionController.countContidions():
                reuseIdentifier = "ElementsCell"
                let cell = tableView.dequeueReusableCellWithIdentifier(reuseIdentifier, forIndexPath: indexPath) as SCElementsTableViewCell

                let condition = self.conditionController.getCondition(indexPath.row)
                
                let s = condition.subject
                let p = condition.predicate
                let o = condition.object
                
                let str_s = s.getVariableLabelOrShortValue(prefix: true)
                let str_p = p.getVariableLabelOrShortValue(prefix: true)
                let str_o = o.getVariableLabelOrShortValue(prefix: true)
                
                let label_s = cell.labelSubject
                let label_p = cell.labelPredicate
                let label_o = cell.labelObject
                
                
                label_s.textColor = UIColor.blackColor()
                label_p.textColor = UIColor.blackColor()
                label_o.textColor = UIColor.blackColor()
                
                let warningEmptyText: String = NSLocalizedString("<Empty>", comment: "warningEmptyText in SCTableVC")
                let warningVariableLabelEmptyText: String = NSLocalizedString("<Label??>", comment: "warningVariableLabelEmptyText in SCTableVC")
                let includeText = NSLocalizedString("Incl.", comment: "includeText in SCTableVC")

                if str_s.isEmpty {
                    label_s.text = warningEmptyText
                    label_s.textColor = UIColor.darkGrayColor()
                } else {
                    label_s.text = str_s
                    
                    if s.variable && s.show && !s.filterString.isEmpty {
                        label_s.text = "\(label_s.text!) (\(includeText) \"\(s.filterString)\")"
                    }
                }
                
                if str_p.isEmpty {
                    label_p.text = warningEmptyText
                    label_p.textColor = UIColor.darkGrayColor()
                } else {
                    label_p.text = str_p
                    
                    if p.variable && p.show && !p.filterString.isEmpty {
                        label_p.text = "\(label_p.text!) (\(includeText) \"\(p.filterString)\")"
                    }
                }
                
                if str_o.isEmpty {
                    label_o.text = warningEmptyText
                    label_o.textColor = UIColor.darkGrayColor()
                } else {
                    label_o.text = str_o
                    
                    if o.variable && o.show && !o.filterString.isEmpty {
                        label_o.text = "\(label_o.text!) (\(includeText) \"\(o.filterString)\")"
                    }
                }
                
                if condition.subject.isHidden() {
                    label_s.textColor = UIColor.lightGrayColor()
                }
                if condition.predicate.isHidden() {
                    label_p.textColor = UIColor.lightGrayColor()
                }
                if condition.object.isHidden() {
                    label_o.textColor = UIColor.lightGrayColor()
                }
                
                
                if cell.labelSubject.text == "?" && s.variable {
                    label_s.text = warningVariableLabelEmptyText
                    label_s.textColor = UIColor.redColor()
                }
                if cell.labelPredicate.text == "?" && p.variable {
                    label_p.text = warningVariableLabelEmptyText
                    label_p.textColor = UIColor.redColor()
                }
                if cell.labelObject.text == "?" && o.variable {
                    label_o.text = warningVariableLabelEmptyText
                    label_o.textColor = UIColor.redColor()
                }
                
                
                return cell
                
            default:
                reuseIdentifier = "AddConditionCell"
            }
            
        case SectionNumber.Options.rawValue:  // options
            
            switch indexPath.row {
            case 0:
                reuseIdentifier = "OrderCell"
                let cell = tableView.dequeueReusableCellWithIdentifier(reuseIdentifier, forIndexPath: indexPath) as UITableViewCell
                cell.textLabel?.text = NSLocalizedString("Order by", comment: "on SCTableVC")
                cell.detailTextLabel?.text = ""
                return cell
            case 1:
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
        
        case SectionNumber.Preferences.rawValue: // preferences
            
            switch indexPath.row {
            case 0:
                reuseIdentifier = "TitleCell"
                let cell = tableView.dequeueReusableCellWithIdentifier(reuseIdentifier, forIndexPath: indexPath) as SCTitleTableViewCell
                cell.titleTextField.text = self.conditionController.title
                cell.titleTextField.addTarget(self, action: "titleTextFieldEditingChanged:", forControlEvents: UIControlEvents.EditingChanged)
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
        case SectionNumber.SearchExecute.rawValue:
            switch indexPath.row {
            case 0:
                self.searchButtonDidTouchUpInside()
                break
            default:
                break
            }
            
            break;
        case SectionNumber.ConditionList.rawValue:
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
        case SectionNumber.Options.rawValue:
            switch indexPath.row {
            case 0:
                println("Selection order by!")
                self.performSegueWithIdentifier("ShowSettingVariableOrder", sender: self)
                break
            default:
                break
            }
            break
        default:
            break;
        }
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        var height: CGFloat = self.tableView.rowHeight
        
        switch indexPath.section {
        case SectionNumber.ConditionList.rawValue:
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
        case SectionNumber.ConditionList.rawValue:
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
        } else if segue.identifier == "ShowSettingVariableOrder" {
            var voTVC = segue.destinationViewController as VariableOrderTableViewController
            voTVC.conditionController = self.conditionController
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

private enum SectionNumber: Int {
    case SearchExecute,
    ConditionList,
    Options,
    Preferences,
    
    _count  // dummy
    static let count = _count.rawValue
}
