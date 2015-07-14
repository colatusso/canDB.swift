//
//  ViewController.swift
//  canDB-example
//
//  Created by Rafael on 02/07/15.
//  Copyright (c) 2015 Rafael Colatusso. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        let filePath = NSBundle.mainBundle().pathForResource("data", ofType:"json")
        var readError:NSError?
        let data = NSData(contentsOfFile:filePath!, options:NSDataReadingOptions.DataReadingUncached, error:&readError)
        let dataArray:Array = NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.allZeros, error: nil) as! Array<Dictionary<String, String>>
        
        let storeInstance = canDB.sharedInstance
        
        var error: NSError?
        
        storeInstance.saveData("Person", data: dataArray, idString: kCanDBDefaultIdString, error: &error)
        storeInstance.addIndex("Person", indexes: ["Name"], idString: kCanDBDefaultIdString, error: &error)
            
        if (error != nil) {
            println("\(error!.domain), \(error!.code), \(error!.userInfo)")
        }
        
        println("loadData: ")
        let result = storeInstance.loadData("Person")
        for item in result {
            for (key, value) in (item as! NSDictionary) {
                println("\(key): \(value)")
            }
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

