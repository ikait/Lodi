//
//  ResourceSearchResultViewController.swift
//  Lodi
//
//  Created by Taishi Ikai on 2014/11/19.
//  Copyright (c) 2014年 Taishi Ikai. All rights reserved.
//

import UIKit

class ResourceSearchResultViewController: UITableViewController, UISearchBarDelegate {
    
    // MARK: - Variables
    
    var searchBar: UISearchBar!
    var conditionController: SearchConditionController!
    
    let endpointUrl = "http://www.wikipediaontology.org/query/"
    //let uri = "http://ja.dbpedia.org/sparql"
    //let uri = "http://lod.jxj.jp/sparql"

    var connection: LDURLConnection!
    var dataReceiver: LDDataReceiver!
    
    var nextResult: Turtle!
    
    var searchResultController: SearchResultController!
    
    var cancelButton: UIBarButtonItem!
    
    // MARK: - Base

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        self.tableView.estimatedRowHeight = 44
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.reloadData()
                
        self.searchBar = UISearchBar()
        self.searchBar.delegate = self
        self.searchBar.keyboardType = UIKeyboardType.Default
        self.navigationItem.titleView = searchBar
        
        
        self.conditionController = SearchConditionController()
        self.conditionController.addCondition(
            SearchCondition(
                subject: SearchConditionElement(show: true, value: "", variable: true, variableLabel: "Title", filterString: ""),
                predicate: SearchConditionElement(show: true, value: "rdf:type/rdfs:subClassOf*", variable: false, variableLabel: "", filterString: ""),
                object: SearchConditionElement(show: false, value: "", variable: true, variableLabel: "Type", filterString: ""))
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

        // var query = self.conditionController.getQueryString(filter: searchBar.text)
        
        var query = join("\n", [
            "select distinct ?s ?l ?c where {",
            "   {",
            "       ?s rdfs:label ?l .",
            "       ?s rdfs:comment ?c .",
            "       FILTER regex(?l, \"\(searchBar.text)\")",
            "   } UNION {",
            "       ?s rdfs:label ?l .",
            "       ?s rdfs:comment ?c .",
            "       FILTER regex(?c, \"\(searchBar.text)\")",
            "   }",
            "}"
            ])
        println(query)
        
        searchBar.resignFirstResponder()
        
        LDURLConnection.showIndicator()
        self.connection = LDURLConnection(url: NSURL(string: self.endpointUrl)!, completionHandler: { data in
            self.searchResultController = SearchResultController(jsonData: data)
            
            if self.searchResultController.parseJson() {
                LDURLConnection.hideIndicator()
                self.tableView.reloadSections(NSIndexSet(index: 0), withRowAnimation: UITableViewRowAnimation.Automatic)
            }
            return nil
        })
        self.connection.setRequestMethod("POST")
        self.connection.setRequestBodyWithPercentEscaping("q=\(query)&type=json&limit=\(self.conditionController.limit)")
        self.connection.start()
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
    
    func cancelButtonDidTouchUpInside(sender: AnyObject) {
        self.cancelReceiving()
    }
    
    func cellHasUriDidTouchUpInside(uri: String) {  // FIXME: uri/クエリ決めうち
        self.readyForReceiving()
        
        var query = "CONSTRUCT {\n"  // TODO: make uri/query dynamically
        query += "<\(uri)> ?p ?o\n"
        //query += "MINUS { <\(uri)> owl:sameAs ?o }\n"
        query += "\n}"
        
        query += "\n"
        query += "WHERE {\n"
        query += "<\(uri)> ?p ?o\n"
        query += "\n}"
        
        println(query)
        
        var connection = LDURLConnection(url: NSURL(string: self.endpointUrl)!)
        connection.setRequestMethod("POST")
        connection.setRequestBodyWithPercentEscaping("q=\(query)&type=turtle")
        
        self.dataReceiver = LDDataReceiver(connection: connection, getTurtleHandler: { turtle in
            self.nextResult = turtle
            self.performSegueWithIdentifier("ShowDetail", sender: self)
        }).start()
    }
    
    
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
        
        let cell = tableView.dequeueReusableCellWithIdentifier(reuseIdentifier, forIndexPath: indexPath) as ResourceSearchResultTableViewCell
        
        cell.labelLabel.text = self.searchResultController.resultItems[indexPath.row].getBinding("l")!.value
        cell.commentLabel.text = self.searchResultController.resultItems[indexPath.row].getBinding("c")!.value
        cell.iriLabel.text = self.searchResultController.resultItems[indexPath.row].getBinding("s")!.value

        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.cellHasUriDidTouchUpInside(self.searchResultController.resultItems[indexPath.row].getBinding("s")!.value)
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
        if segue.identifier == "ShowDetail" {
            var rdtvc = segue.destinationViewController as ResourceDetailTableViewController
            rdtvc.result = self.nextResult
        }
    }

}
