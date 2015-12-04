## canDB.swift

canDB.swift uses sqlite (via FMDB) but it works like a nonSQL database.
Just put the json into the can and retrieve it as a dictionary.
Easy as pie.

main methods:

```swift
        // singleton
        let storeInstance = canDB.sharedInstance
                
        // saving, indexing, reindexing new data        
        storeInstance.saveData("Person", data: dataArray, idString: kCanDBDefaultIdString)
        storeInstance.addIndex("Person", indexes: ["Name", "Address.Home", "Address.Work"])
        storeInstance.reIndex("Person", idString: kCanDBDefaultIdString)
                
        // loading all data
        let result = storeInstance.loadData("Person")
        for item in result {
            for (key, value) in (item as! NSDictionary) {
                print("\(key): \(value)", terminator: "")
                self.textView?.text = self.textView?.text.stringByAppendingString("\(key): \(value)\n")
            }
            self.textView?.text = self.textView?.text.stringByAppendingString("\n")
        }

        // loading data with custom query            
        let resultWithQuery = storeInstance.loadDataWithQuery("SELECT * FROM Person WHERE Name='John'")
        for item in resultWithQuery {
            for (key, value) in (item as! NSDictionary) {
                print("\(key): \(value)", terminator: "")
            }
        }
            
        // remove methods
        storeInstance.removeData("Person")
        storeInstance.removeDataForId("Person", idString: kCanDBDefaultIdString, idsToDelete: ["19", "17"])

```

All the data is saved into the _jsonData field, but you can create indexes to perform queries
and still access all the information using dictionaries keys instead of worrying with table columns.

For more info take a look at the example project.

If you want to share any ideas just drop me a line at @colatusso.


## License

All this code is released under the MIT license.
