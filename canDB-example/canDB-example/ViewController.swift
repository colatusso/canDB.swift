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
        let data: NSData?
        do {
            data = try NSData(contentsOfFile:filePath!, options:NSDataReadingOptions.DataReadingUncached)
        } catch let error as NSError {
            print("\(error.localizedDescription)")
            data = nil
        }
        let dataArray:Array = (try! NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions())) as! Array<Dictionary<String, AnyObject>>
        
        let storeInstance = canDB.sharedInstance
        
        do {
            try storeInstance.openDatabase()
                        
            // now it's possible to use keyPath indexes like "Address.Home"
            do {
                try storeInstance.saveData("Person", data: dataArray, idString: kCanDBDefaultIdString)
                try storeInstance.addIndex("Person", indexes: ["Name", "Address.Home", "Address.Work"])
                try storeInstance.reIndex("Person", idString: kCanDBDefaultIdString)
                
            } catch CanDBError.Error(let message) {
                print (message)
            } catch {
                print ("error")
            }
            
            print("loadData: ", terminator: "")
            let result = storeInstance.loadData("Person")
            for item in result {
                for (key, value) in (item as! NSDictionary) {
                    print("\(key): \(value)", terminator: "")
                    self.textView?.text = self.textView?.text.stringByAppendingString("\(key): \(value)\n")
                }
                self.textView?.text = self.textView?.text.stringByAppendingString("\n")
            }
            
            print("loadDataWithQuery: ", terminator: "")
            let resultWithQuery = storeInstance.loadDataWithQuery("SELECT * FROM Person WHERE Name='John'")
            for item in resultWithQuery {
                for (key, value) in (item as! NSDictionary) {
                    print("\(key): \(value)", terminator: "")
                }
            }
            
            do {
                try storeInstance.removeDataForId("Person", idString: kCanDBDefaultIdString, idsToDelete: ["19", "17"])
            } catch CanDBError.Error(let message) {
                print (message)
            } catch {
                print ("unknown error")
            }

        } catch {
            print("coud not open the database")
        }
        
    
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

