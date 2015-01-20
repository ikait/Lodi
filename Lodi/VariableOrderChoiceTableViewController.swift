//
//  VariableOrderChoiceTableViewController.swift
//  Lodi
//
//  Created by Taishi Ikai on 2015/01/16.
//  Copyright (c) 2015年 Taishi Ikai. All rights reserved.
//

import UIKit

class VariableOrderChoiceTableViewController: UITableViewController {
    
    var conditionController: SearchConditionController!
    
    var dic: [String: SearchConditionVariableOrder] = [:]
    var keysArray: [String] = []
    
    var editingVariableLabel: String!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        self.navigationItem.title = "?" + self.editingVariableLabel
    }
    
    func set() {
        self.dic = self.conditionController.getVariableLabelsAndOrders()
        self.keysArray = dic.keys.array
    }
    
    override func viewWillAppear(animated: Bool) {
        self.set()
        self.tableView.reloadData()
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return SearchConditionVariableOrder.allValues.count
        default:
            return 0
        }
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        var reuseIdentifier = "Cell"
        
        switch indexPath.section {
        case 0:
            let cell = tableView.dequeueReusableCellWithIdentifier(reuseIdentifier, forIndexPath: indexPath) as UITableViewCell
            
            var order = SearchConditionVariableOrder.allValues[indexPath.row]
            
            if order == SearchConditionVariableOrder.Descend {
                cell.textLabel?.text = SearchConditionVariableOrder.Descend.toString()
            } else if order == SearchConditionVariableOrder.Ascend {
                cell.textLabel?.text = SearchConditionVariableOrder.Ascend.toString()
            } else if order == SearchConditionVariableOrder.None {
                cell.textLabel?.text = SearchConditionVariableOrder.None.toString()
            } else {
                cell.textLabel?.text = order.rawValue
            }
            
            if order.rawValue == self.dic[editingVariableLabel]?.rawValue {
                cell.accessoryType = UITableViewCellAccessoryType.Checkmark
            } else {
                cell.accessoryType = UITableViewCellAccessoryType.None
            }
            return cell
        default:
            break
        }
        
        let cell = tableView.dequeueReusableCellWithIdentifier(reuseIdentifier, forIndexPath: indexPath) as UITableViewCell

        return cell
    }
    
    override func tableView(tableView: UITableView, didUnhighlightRowAtIndexPath indexPath: NSIndexPath) {
        //self.tableView.reloadData()
        
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        //self.tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        self.conditionController.setVariableOrder(self.editingVariableLabel, order: SearchConditionVariableOrder.allValues[indexPath.row])
        self.set()
        
        self.tableView.reloadSections(NSIndexSet(index: indexPath.section), withRowAnimation: UITableViewRowAnimation.Automatic)
        
    }
    
    override func tableView(tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        var title = ""
        var order = self.conditionController.getVariableOrder(self.editingVariableLabel)
        
        switch section {
        case 0:
            if order != SearchConditionVariableOrder.None {
                title = NSString(format: NSLocalizedString("This search result will be shown sorted in %1$@ order based ?%2$@.", comment: "on VariableOrderChoiceTVC"),
                    order.toString(),
                    self.editingVariableLabel
                )
            }
            break
        default:
            break
        }
        return title
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
