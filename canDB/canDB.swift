//
//  canDB.swift
//
//  Created by Rafael on 24/06/15.
//  Copyright (c) 2015 Rafael Colatusso. All rights reserved.
//

import Foundation

let kCanDBDefaultIdString = "Id"

class canDB: NSObject {

    let kCanDBErrorDomain = "com.candb.error"
    
    
    static let sharedInstance = canDB()
    
    var database = FMDatabase()
    
    override init() {
        super.init()
        
        self.openDatabase()
    }

    func execute(command: String, error: NSErrorPointer?){
        if !self.database.executeUpdate(command, withArgumentsInArray: nil) {
            error?.memory = NSError(domain: kCanDBErrorDomain, code: -1, userInfo: ["message": self.database.lastErrorMessage()])
        }
    }
    
    func openDatabase() {
        let documentsFolder = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as! String
        let path = documentsFolder + "/canDB.sqlite"
        
        self.database = FMDatabase(path: path)
        self.database.open()
    }
    
    func createTable(tableName: String, idString: String, error: NSErrorPointer?) {
        self.execute("CREATE TABLE IF NOT EXISTS " + tableName + " (_localId INTEGER PRIMARY KEY, \(idString) TEXT, _jsonData TEXT);", error: error)
    }

    func addIndex(tableName: String, indexes: NSArray, error: NSErrorPointer?) {
        for index in indexes {
            self.execute("ALTER TABLE \(tableName) ADD COLUMN \(index) TEXT", error: error)
        }
    }
    
    // todo: improve performance on reindexing big tables
    func reIndex(tableName: String, idString: String) {
        let result = loadDataWithQuery("SELECT * from \(tableName)")
        
        saveData(tableName, data: result, idString: idString, error: nil)
    }

    func saveData(tableName: String, data: NSArray, idString: String, error: NSErrorPointer?) {
        self.createTable(tableName, idString: idString, error: error);
        
        let indexesArray = self.getIndexesForTable(tableName)
        
        for record in data {
            
            if !NSJSONSerialization.isValidJSONObject(record) {
                error?.memory = NSError(domain: kCanDBErrorDomain, code: -1, userInfo: ["message": "invalid JSON"])
                return
            }
            
            let jsonData = NSJSONSerialization.dataWithJSONObject(record, options: NSJSONWritingOptions.PrettyPrinted, error: nil)!
            let rawJSONString = NSString(data: jsonData, encoding:NSUTF8StringEncoding)
            
            let Id = record.objectForKey(idString) as! String
            let selectQuery = "SELECT * FROM \(tableName) WHERE \(idString) = '\(Id)'"
            let result = self.loadDataWithQuery(selectQuery)
            
            if result.count > 0 {
                // custom columns
                var extraQuery = ""
                for indexName in indexesArray {
                    if (!indexName.isEqualToString("_localId") && !indexName.isEqualToString("_jsonData") && !indexName.isEqualToString(idString)) {
                        extraQuery += ", \(indexName) = '\(record.objectForKey(indexName)!)' "
                    }
                }
                
                if !self.database.executeUpdate("UPDATE \(tableName) set _jsonData = '\(rawJSONString!)' \(extraQuery) WHERE \(idString) = '\(Id)'", withArgumentsInArray: nil) {
                    error?.memory = NSError(domain: kCanDBErrorDomain, code: -1, userInfo: ["message": self.database.lastErrorMessage()])
                }
            }
            else {
                // custom columns
                var extraIndexes = ""
                var extraValues = ""
                for indexName in indexesArray {
                    if (!indexName.isEqualToString("_localId") && !indexName.isEqualToString("_jsonData")) {
                        extraIndexes += ", \(indexName)"
                        extraValues  += ",'\(record.objectForKey(indexName)!)' "
                    }
                }
                
                if !self.database.executeUpdate("INSERT INTO \(tableName) (_jsonData \(extraIndexes)) VALUES ('\(rawJSONString!)' \(extraValues))", withArgumentsInArray: nil) {
                    error?.memory = NSError(domain: kCanDBErrorDomain, code: -1, userInfo: ["message": self.database.lastErrorMessage()])
                }
            }
        }
    }

    // remove all the data from a table
    func removeData(tableName: String, error: NSErrorPointer?) {
        self.execute("DELETE FROM \(tableName)", error: error)
    }
    
    // remove specific records
    func removeDataForId(tableName: String, idString: String, idsToDelete: NSArray, error: NSErrorPointer?) {
        var ids = ""
        
        idsToDelete.enumerateObjectsUsingBlock { (object, index, stop) -> Void in
            if index == 0 { ids = (object as! String) }
            else if index == (idsToDelete.count - 1) { ids = ids + ", " + (object as! String) }
            else { ids = ids + ", " + (object as! String)}
        }
        
        self.execute("DELETE FROM \(tableName) where \(idString) in ( \(ids) )", error: error)
    }

    func loadData(tableName: String) -> NSArray {
        let query = "SELECT _jsonData from \(tableName)"
        let resultSet = self.database.executeQuery(query, withArgumentsInArray: nil)
        var result: NSMutableArray = []
        
        while resultSet.next() {
            let jsonString = resultSet.stringForColumn("_jsonData")
            let jsonData: NSData = jsonString.dataUsingEncoding(NSUTF8StringEncoding)!
            let json: AnyObject = NSJSONSerialization.JSONObjectWithData(jsonData, options: nil, error: nil)!
            let jsonDictionary = json as? NSDictionary
                
            result.addObject(jsonDictionary!)
        }
        
        return result as NSArray
    }
    
    func loadDataWithQuery(query: String) -> NSArray {
        let resultSet = self.database.executeQuery(query, withArgumentsInArray: nil)
        var result: NSMutableArray = []
        
        while resultSet.next() {
            let jsonString = resultSet.stringForColumn("_jsonData")
            let jsonData: NSData = jsonString.dataUsingEncoding(NSUTF8StringEncoding)!
            let json: AnyObject = NSJSONSerialization.JSONObjectWithData(jsonData, options: nil, error: nil)!
            let jsonDictionary = json as? NSDictionary
            
            result.addObject(jsonDictionary!)
        }
        
        return result as NSArray
    }
    
    // helper
    func getIndexesForTable(tableName: String) -> NSMutableArray {
        // get the extra indexes
        let indexes = self.database.executeQuery("PRAGMA table_info(\(tableName))", withArgumentsInArray: nil)
        let indexesArray: NSMutableArray = []
        
        while indexes.next() {
            let indexName = indexes.objectForColumnName("name") as! String
            indexesArray.addObject(indexName)
        }
        
        return indexesArray
        
    }
}