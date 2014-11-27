//
//  TestViewController.swift
//  Lodi
//
//  Created by Taishi Ikai on 2014/11/20.
//  Copyright (c) 2014年 Taishi Ikai. All rights reserved.
//

import UIKit

class TestViewController: UIViewController {
    
    var appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
    
    // var connection: LDURLConnection!
    var dataReceiver: LDDataReceiver!
    
    @IBOutlet weak var urlTextField: UITextField!
    
    @IBOutlet weak var resultTextField: UITextView!
    
    @IBOutlet weak var finishedLabel: UILabel!
    
    
    var queue = NSOperationQueue()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func cancel() {
        if var dataReceiver = self.dataReceiver {
            dataReceiver.cancel()
        }
    }
    
    func reset() {
        self.resultTextField.text = ""
    }
    
    @IBAction func reset(sender: AnyObject) {
        self.reset()
    }
    
    @IBAction func cancel(sender: AnyObject) {
        println("Cancel button did touch up!")
        self.cancel()
    }
    
    @IBAction func start(sender: AnyObject) {
        self.reset()
        self.cancel()
        println("Start button did touch up!")
        
        self.dataReceiver = LDDataReceiver(connection: LDURLConnection(url: NSURL(string: self.urlTextField.text)!), getTurtleHandler: { turtle in
            
            self.resultTextField.text = String(NSDate().description) + "\n"
            self.resultTextField.text! += turtle.description
        })
        
        self.dataReceiver.start()
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
