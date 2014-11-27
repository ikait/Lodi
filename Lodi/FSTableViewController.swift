//
//  FSTableViewController.swift
//  Lodi
//
//  Created by Taishi Ikai on 2014/11/19.
//  Copyright (c) 2014年 Taishi Ikai. All rights reserved.
//

import UIKit

class FSTableViewController: UITableViewController, UISearchBarDelegate {
    
    // MARK: - Variables
    
    var searchBar: UISearchBar!
    var conditionController: SearchConditionController!
    
    //let uri = "http://www.wikipediaontology.org/query/"
    let uri = "http://ja.dbpedia.org/sparql"
    //let uri = "http://lod.jxj.jp/sparql"

    var connection: LDURLConnection!
    
    var searchResultController: SearchResultController!
    
    // MARK: - Base

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        self.searchBar = UISearchBar()
        self.searchBar.delegate = self
        self.searchBar.keyboardType = UIKeyboardType.Default
        self.navigationItem.titleView = searchBar
        
        self.conditionController = SearchConditionController()
        self.conditionController.addCondition(
            SearchCondition(
                subject: SearchConditionElement(show: true, value: "", variable: true, variableLabel: "Title"),
                predicate: SearchConditionElement(show: true, value: "rdf:type/rdfs:subClassOf*", variable: false, variableLabel: ""),
                object: SearchConditionElement(show: false, value: "", variable: true, variableLabel: "Type"))
        )
        self.conditionController.distinct = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    // MARK: - Searchbar <Delegate>
    
    func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(true, animated: true)
    }
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(false, animated: true)
        searchBar.resignFirstResponder()
    }
    
    func searchBarTextDidEndEditing(searchBar: UISearchBar) {
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {

        var query = self.conditionController.getQueryString(filter: searchBar.text)
        searchBar.resignFirstResponder()
        
        self.connection = LDURLConnection(url: NSURL(string: self.uri)!, completionHandler: { data in
            self.searchResultController = SearchResultController(xmlData: data)
            
            if self.searchResultController.parse() {
                self.tableView.reloadData()
            }
            return nil
        })
        self.connection.setRequestMethod("POST")
        self.connection.setRequestBodyWithPercentEscaping("query=\(query)")
        self.connection.start()
    }
    
    // MARK: - Events
    
    
    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let s = self.searchResultController {
            return s.resultItemsCount
        } else {
            return 0
        }
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {

        var reuseIdentifier = "Cell"
        
        let cell = tableView.dequeueReusableCellWithIdentifier(reuseIdentifier, forIndexPath: indexPath) as UITableViewCell

        cell.textLabel.text = self.searchResultController.resultItems[indexPath.row].bindings[0].shortValue

        return cell
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
