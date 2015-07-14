# canDB.swift
==============

It's a work in progress in it's initial state.

canDB.swift uses sqlite (via FMDB) but it works like a nonSQL database.
Just put the data into the can and it's done.

example:

```swift
    let filePath = NSBundle.mainBundle().pathForResource("data", ofType:"json")
 
    let data = NSData(contentsOfFile:filePath!, options:NSDataReadingOptions.DataReadingUncached, error:nil)
    let dataArray:Array = NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.allZeros, error: nil) as! Array<Dictionary<String, String>>
    
    let storeInstance = canDB.sharedInstance
    storeInstance.addIndex("tmp", indexes: ["Name"], error: &error)
    storeInstance.saveData("tmp", data: dataArray, idString: "Id", error: nil)

    let result = storeInstance.loadData("tmp")
    for item in result {
        println(item.description!)
    }
```

All the data is saved in the _jsonData field, but you can create indexes to perform faster queries
and still access all the information using dictionaries keys instead of worrying with columns for all the fields.

For more info take a look at the example project.

If you want to share any ideas just drop me a line at @colatusso