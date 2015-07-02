//
//  ViewController.swift
//  canDB-example
//
//  Created by Rafael on 02/07/15.
//  Copyright (c) 2015 Rafael Colatusso. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    let data: NSArray = [[
        "Id": "15",
        "Name": "Test canDB99"
    ]]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        let storeInstance = canDB.sharedInstance
        
        var error: NSError?
        storeInstance.saveData("tmp", data: self.data, idString: "Id", error: &error)
            
        if (error != nil) {
            println("\(error!.domain), \(error!.code), \(error!.userInfo)")
        }
        
        else {
            var error: NSError?
            storeInstance.addIndex("tmp", columns: ["Name"], error: &error)
            
            if (error != nil) {
                println("\(error!.domain), \(error!.code), \(error!.userInfo)")
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

