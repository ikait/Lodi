//
//  KeywordExamplesTableViewController.swift
//  Lodi
//
//  Created by Taishi Ikai on 2015/01/17.
//  Copyright (c) 2015年 Taishi Ikai. All rights reserved.
//

import UIKit

class KeywordExamplesTableViewController: UITableViewController {
    
    var resultController: SearchResultController!
    var editingElement: SearchConditionElement!
    var editingLabel: String!

    override func viewDidLoad() {
        super.viewDidLoad()

        self.clearsSelectionOnViewWillAppear = true
        
        self.tableView.reloadData()
        self.tableView.estimatedRowHeight = 44
        self.tableView.rowHeight = UITableViewAutomaticDimension
        
        // to fix issue tabbar covers tableview
        // * there is no self.tabbarController when it presents modally
        self.edgesForExtendedLayout = UIRectEdge.All
        self.tableView.contentInset.bottom = 49  // XXX
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 1
        case 1:
            return self.resultController.resultItemsCount
        default:
            return 0
        }
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as UITableViewCell
        
        switch indexPath.section {
        case 0:
            cell.textLabel?.textColor = UIColor.redColor()
            cell.textLabel?.text = NSLocalizedString("Delete a keyword", comment: "on KeywordExamplesTVC")
            cell.detailTextLabel?.text = ""
        case 1:
            cell.textLabel?.textColor = UIColor.darkTextColor()
            var result = self.resultController.resultItems[indexPath.row]
            for (index, binding) in enumerate(result.bindings) {
                if binding.name == self.editingLabel {
                    cell.textLabel?.text = binding.shortValue
                } else {
                    cell.detailTextLabel?.text = binding.shortValue
                }
            }
        default:
            break
        }
        
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        switch indexPath.section {
        case 0:
            self.editingElement.value = ""
            self.navigationController?.popViewControllerAnimated(true)
        case 1:
            var result = self.resultController.resultItems[indexPath.row]
            for (index, binding) in enumerate(result.bindings) {
                if binding.name == self.editingLabel {
                    if binding.type == SearchResultItemType.URI {
                        self.editingElement.value = "<\(binding.value)>"
                    } else {
                        self.editingElement.value = "\"\(binding.value)\""
                    }
                }
            }
            self.navigationController?.popViewControllerAnimated(true)

            // check!
            self.tableView.cellForRowAtIndexPath(indexPath)?.accessoryType = UITableViewCellAccessoryType.Checkmark
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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

}
