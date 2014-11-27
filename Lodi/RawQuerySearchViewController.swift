//
//  RawQuerySearchViewController.swift
//  Lodi
//
//  Created by Taishi Ikai on 2014/11/12.
//  Copyright (c) 2014年 Taishi Ikai. All rights reserved.
//

import UIKit

class RawQuerySearchViewController: UIViewController {

    // MARK: - Variables
    
    @IBOutlet weak var rawQueryTextField: UITextView!
    @IBOutlet weak var searchButton: UIBarButtonItem!
    
    var appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
    var searchResultController: SearchResultController!
    
    let uri = "http://www.wikipediaontology.org/query/"
    var connection: LDURLConnection!
    
    // MARK: - Base
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NSLog("%@", "Loaded RQS.")

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // MARK: - Event
    
    @IBAction func searchButtonDidTouchUpInside(sender: AnyObject) {
//        self.receiveResultWithPostQueryAsync(setItemsAndPerformSegue)
        
        self.connection = LDURLConnection(url: NSURL(string: self.uri)!,
            completionHandler: { data in
                self.searchResultController = SearchResultController(xmlData: data)
                if self.searchResultController.parse() {
                    self.performSegueWithIdentifier("ShowResult", sender: self)
                }
                return nil
        })
        self.connection.setRequestMethod("POST")
        self.connection.setRequestBodyWithPercentEscaping("query=\(self.rawQueryTextField.text)")
        self.connection.start()
    }
    

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        if segue.identifier == "ShowResult" {
            var searchResultVC = segue.destinationViewController as SearchResultTableViewController
            
            if let s = self.searchResultController {
                searchResultVC.result = s
            }
        }
    }
}
