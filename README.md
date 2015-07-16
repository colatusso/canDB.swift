## canDB.swift

canDB.swift uses sqlite (via FMDB) but it works like a nonSQL database.
Just put the json into the can and retrieve it as a dictionary.
Easy as pie.

example:

```swift
    // loading the json
    let filePath = NSBundle.mainBundle().pathForResource("data", ofType:"json")
    let data = NSData(contentsOfFile:filePath!, options:NSDataReadingOptions.DataReadingUncached, error:nil)
    let dataArray:Array = NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.allZeros, error: nil) as! Array<Dictionary<String, String>>
    
    // singleton instance
    let storeInstance = canDB.sharedInstance

    // saving the data, the can is automatically created if not exists
    storeInstance.saveData("Person", data: dataArray, idString: kCanDBDefaultIdString, error: nil)

    // adding the index for future queries and reindexing the table
    storeInstance.addIndex("Person", indexes: ["Name"], error: nil)
    storeInstance.reIndex("Person", idString: kCanDBDefaultIdString)

    let result = storeInstance.loadData("Person")
    for item in result {
        for (key, value) in (item as! NSDictionary) {
            println("\(key): \(value)")
        }
    }

    // custom query using the previous created index "Name"
    let resultWithQuery = storeInstance.loadDataWithQuery("SELECT * FROM Person WHERE Name='John'")
    for item in resultWithQuery {
        for (key, value) in (item as! NSDictionary) {
            println("\(key): \(value)")
        }
    }

    storeInstance.removeDataForId("Person", idString: kCanDBDefaultIdString, idsToDelete: ["17", "19"], error: nil)
```

All the data is saved into the _jsonData field, but you can create indexes to perform queries
and still access all the information using dictionaries keys instead of worrying with table columns.

For more info take a look at the example project.

If you want to share any ideas just drop me a line at @colatusso.


## License

The template is released under the MIT license.
