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
        storeInstance.saveData("tmp", data: dataArray, idString: "Id", error: &error)
            
        if (error != nil) {
            println("\(error!.domain), \(error!.code), \(error!.userInfo)")
        }
        
        else {
            var error: NSError?
            storeInstance.addIndex("tmp", indexes: ["Name"], error: &error)
            
            if (error != nil) {
                println("\(error!.domain), \(error!.code), \(error!.userInfo)")
            }
        }
        
        let result = storeInstance.loadData("tmp")
        for item in result {
            println(item.description!)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

