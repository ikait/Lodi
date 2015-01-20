//
//  VariableOrderTableViewController.swift
//  Lodi
//
//  Created by Taishi Ikai on 2015/01/15.
//  Copyright (c) 2015年 Taishi Ikai. All rights reserved.
//

import UIKit

class VariableOrderTableViewController: UITableViewController {
    
    var conditionController: SearchConditionController!
    
    var dic: [String: SearchConditionVariableOrder] = [:]
    var keysArray: [String] = []
    
    var editingVariableLabel = ""

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()

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
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return NSLocalizedString("Variables", comment: "in SettingVariableOrderTVC")
        default:
            return ""
        }
    }
    
    override func tableView(tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        switch section {
        case 0:
            return NSLocalizedString("", comment: "in SettingVariableOrderTVC")
        default:
            return ""
        }
    }

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.conditionController.getVariableLabelsAndOrders().count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var reuseIdentifier = "VariableCell"
        
        let cell = tableView.dequeueReusableCellWithIdentifier(reuseIdentifier, forIndexPath: indexPath) as UITableViewCell
        
        cell.textLabel?.text = "?" + self.keysArray[indexPath.row]  // MARK: need a prefix?
        cell.detailTextLabel?.text = self.dic[keysArray[indexPath.row]]?.toString()

        // Configure the cell...
    

        return cell
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        switch indexPath.section {
        case 0:
            self.editingVariableLabel = self.keysArray[indexPath.row]
            self.performSegueWithIdentifier("SettingOrder", sender: self)
            break
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
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
        
        if segue.identifier == "SettingOrder" {
            var vocTVC = segue.destinationViewController as VariableOrderChoiceTableViewController
            vocTVC.conditionController = self.conditionController
            vocTVC.editingVariableLabel = self.editingVariableLabel
        }
    }
    

}
