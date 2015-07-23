//
//  ViewController.swift
//  canDB-example
//
//  Created by Rafael on 02/07/15.
//  Copyright (c) 2015 Rafael Colatusso. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet var textView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        let filePath = NSBundle.mainBundle().pathForResource("data", ofType:"json")
        var readError:NSError?
        let data = NSData(contentsOfFile:filePath!, options:NSDataReadingOptions.DataReadingUncached, error:&readError)
        let dataArray:Array = NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.allZeros, error: nil) as! Array<Dictionary<String, AnyObject>>
        
        let storeInstance = canDB.sharedInstance
        
        var error: NSError?
        
        // now it's possible to use keyPath indexes like "Address.Home"
        storeInstance.saveData("Person", data: dataArray, idString: kCanDBDefaultIdString, error: &error)
        storeInstance.addIndex("Person", indexes: ["Name", "Address.Home", "Address.Work"], error: &error)
        storeInstance.reIndex("Person", idString: kCanDBDefaultIdString)
            
        if (error != nil) {
            println("\(error!.domain), \(error!.code), \(error!.userInfo)")
        }
        
        println("loadData: ")
        let result = storeInstance.loadData("Person")
        for item in result {
            for (key, value) in (item as! NSDictionary) {
                println("\(key): \(value)")
                self.textView?.text = self.textView?.text.stringByAppendingString("\(key): \(value)\n")
            }
            self.textView?.text = self.textView?.text.stringByAppendingString("\n")
        }
        
        println("\nloadDataWithQuery: ")
        let resultWithQuery = storeInstance.loadDataWithQuery("SELECT * FROM Person WHERE Name='John'")
        for item in resultWithQuery {
            for (key, value) in (item as! NSDictionary) {
                println("\(key): \(value)")
            }
        }
        
        storeInstance.removeDataForId("Person", idString: kCanDBDefaultIdString, idsToDelete: ["19", "17"], error: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

