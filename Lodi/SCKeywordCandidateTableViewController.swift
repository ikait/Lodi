//
//  SCSelectTableViewController.swift
//  Lodi
//
//  Created by Taishi Ikai on 2014/11/18.
//  Copyright (c) 2014年 Taishi Ikai. All rights reserved.
//

import UIKit

class SCKeywordCandidateTableViewController: UITableViewController {
    
    
    // MARK: - Variables
    
    var editingElement: SearchConditionElement!
    
    var appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
    
    
    // MARK: - Base

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        self.tableView.rowHeight = 44
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
            return appDelegate.resources.count
        default:
            break
        }
        return 0
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var reuseIdentifier = "Cell"
        
        switch indexPath.section {
        case 0:
            switch indexPath.row {
            case 0:
                let cell = tableView.dequeueReusableCellWithIdentifier(reuseIdentifier, forIndexPath: indexPath) as UITableViewCell
                cell.textLabel.text = "Manual input..."
                return cell
            default:
                break
            }
            
        case 1:
            reuseIdentifier = "ResourceCell"
            let cell = tableView.dequeueReusableCellWithIdentifier(reuseIdentifier, forIndexPath: indexPath) as UITableViewCell
            cell.textLabel.text = self.appDelegate.getResource(indexPath.row).getLabel()
            return cell
        default:
            break
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
                self.performSegueWithIdentifier("InputKeywordManually", sender: self)
                break
            default:
                break
            }
            
        case 1:
            self.editingElement.value = self.appDelegate.getResource(indexPath.row).getValueForRdf()
            self.performSegueWithIdentifier("BackToSCInputTableView", sender: self)
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
        switch segue.identifier! {
        case "InputKeywordManually":
            var keywordInputManuallyVC = segue.destinationViewController as SCKeywordInputManuallyTableViewController
                keywordInputManuallyVC.editingElement = self.editingElement
            break
        default:
            break
        }
    }
    

}
