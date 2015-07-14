# canDB.swift
==============

It's a work in progress current in it's initial stage.

canDB.swift uses sqlite (via FMDB) but it works like a nonSQL database.
Just put the data into the can and it's done.

example:

```swift
    let filePath = NSBundle.mainBundle().pathForResource("data", ofType:"json")
 
    let data = NSData(contentsOfFile:filePath!, options:NSDataReadingOptions.DataReadingUncached, error:nil)
    let dataArray:Array = NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.allZeros, error: nil) as! Array<Dictionary<String, String>>
    
    let storeInstance = canDB.sharedInstance
    storeInstance.saveData("Person", data: dataArray, idString: "Id", error: nil)
    storeInstance.addIndex("Person", indexes: ["Name"], error: nil)

    let result = storeInstance.loadData("Person")
    for item in result {
        for (key, value) in (item as! NSDictionary) {
            println("\(key): \(value)")
        }
    }

    let resultWithQuery = storeInstance.loadDataWithQuery("SELECT * FROM Person WHERE Name='John'")
    for item in resultWithQuery {
        for (key, value) in (item as! NSDictionary) {
            println("\(key): \(value)")
        }
    }

    storeInstance.removeDataForId("tmp", idString: "Id", idsToDelete: ["17", "19"], error: nil)
```

All the data is saved into the _jsonData field, but you can create indexes to perform queries
and still access all the information using dictionaries keys instead of worrying with columns for all the fields.

For more info take a look at the example project.

If you want to share any ideas just drop me a line at @colatusso

# License
==============
Do what ever you want... at your own risk :)
