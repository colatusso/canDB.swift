# canDB.swift
==============

It's a work in progress in it's initial state.
canDB.swift uses sqlite (via FMDB) but it works like a nonSQL database.
Just put the data into the can and it's done.

example:

```swift
let data: NSArray = [[
        "Id": "15xpto",
        "Name": "Test canDB",
        "AnotherField": "Don't need to create a column for this"
    ]]

let storeInstance = canDB.sharedInstance
storeInstance.saveData("table", data: data, idString: "Id", error: &error)
storeInstance.addIndex("table", columns: ["Name"], error: &error)
```

All the data is saved in the _jsonData field, but you can create indexes to perform faster queries
and still access all the information using dictionaries keys instead of worrying with columns for all the fields.

If you want to share any ideas just drop me a line at @colatusso