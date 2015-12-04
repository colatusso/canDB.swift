//
//  canDB.swift
//
//  Created by Rafael on 24/06/15.
//  Copyright (c) 2015 Rafael Colatusso. All rights reserved.
//

import Foundation

enum CanDBError: ErrorType {
    case Error(String)
}

let kCanDBDefaultIdString = "Id"

class canDB: NSObject {
    
    static let sharedInstance = canDB()
    
    var database = FMDatabase()
    
    override init() {
        super.init()
    }
    
    func execute(command: String) throws {
        if !self.database.executeUpdate(command, withArgumentsInArray: nil) {
            throw CanDBError.Error("CanDBError: \(self.database.lastErrorMessage())")
        }
    }
    
    func openDatabase() throws {
        let documentsFolder = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] 
        let path = documentsFolder + "/canDB.sqlite"
        
        self.database = FMDatabase(path: path)
        if !self.database.open() {
            throw CanDBError.Error("error opening the database")
        }
    }
    
    func createTable(tableName: String, idString: String) throws {
        do {
            try self.execute("CREATE TABLE IF NOT EXISTS " + tableName + " (_localId INTEGER PRIMARY KEY, \(idString) TEXT, _jsonData TEXT);")
        } catch CanDBError.Error(let message) {
            throw CanDBError.Error(message)
        } catch {
            throw CanDBError.Error("unknown error")
        }
        
    }
    
    func addIndex(tableName: String, indexes: NSArray) throws {
        for index in indexes {
            do {
                try self.execute("ALTER TABLE \(tableName) ADD COLUMN [\(index)] TEXT")
            } catch CanDBError.Error(let message) {
                throw CanDBError.Error(message)
            } catch {
                throw CanDBError.Error("unknown error")
            }
        }
    }
    
    // todo: improve performance on reindexing big tables
    func reIndex(tableName: String, idString: String) throws {
        let result = loadDataWithQuery("SELECT * from \(tableName)")
        
        do {
            try self.saveData(tableName, data: result, idString: idString)
        } catch CanDBError.Error(let message) {
            throw CanDBError.Error(message)
        } catch {
            throw CanDBError.Error("unknown error")
        }
    }
    
    func saveData(tableName: String, data: NSArray, idString: String) throws {
        do {
            try self.createTable(tableName, idString: idString);
        } catch CanDBError.Error(let message) {
            throw CanDBError.Error(message)
        } catch {
            throw CanDBError.Error("unknown error")
        }
        
        let indexesArray = self.getIndexesForTable(tableName)
        
        for record in data {
            
            if !NSJSONSerialization.isValidJSONObject(record) {
                throw CanDBError.Error("invalid JSON")
                return
            }
            
            let jsonData = try! NSJSONSerialization.dataWithJSONObject(record, options: NSJSONWritingOptions.PrettyPrinted)
            let rawJSONString = NSString(data: jsonData, encoding:NSUTF8StringEncoding)
            
            
            let Id: AnyObject! = record.objectForKey(idString)
            let selectQuery = "SELECT * FROM \(tableName) WHERE \(idString) = '\(Id)'"
            let result = self.loadDataWithQuery(selectQuery)
            
            if result.count > 0 {
                // custom columns
                var extraQuery = ""
                for indexName in indexesArray {
                    if (!indexName.isEqualToString("_localId") && !indexName.isEqualToString("_jsonData") && !indexName.isEqualToString(idString)) {
                        extraQuery += ", [\(indexName)] = '\(record.valueForKeyPath(indexName as! String)!)' "
                    }
                }
                
                if !self.database.executeUpdate("UPDATE \(tableName) set _jsonData = :rawJson \(extraQuery) WHERE \(idString) = '\(Id)'", withParameterDictionary: ["rawJson": "\(rawJSONString!)"]) {
                    throw CanDBError.Error(self.database.lastErrorMessage())
                }
            }
            else {
                // custom columns
                var extraIndexes = ""
                var extraValues = ""
                for indexName in indexesArray {
                    if (!indexName.isEqualToString("_localId") && !indexName.isEqualToString("_jsonData")) {
                        extraIndexes += ", [\(indexName)]"
                        extraValues  += ",'\(record.valueForKeyPath(indexName as! String)!)' "
                    }
                }
                
                if !self.database.executeUpdate("INSERT INTO \(tableName) (_jsonData \(extraIndexes)) VALUES (:rawJson \(extraValues))", withParameterDictionary: ["rawJson": "\(rawJSONString!)"]) {
                    throw CanDBError.Error(self.database.lastErrorMessage())
                }
            }
        }
    }
    
    // remove all the data from a table
    func removeData(tableName: String) throws {
        do {
            try self.execute("DELETE FROM \(tableName)")
        } catch CanDBError.Error(let message) {
            throw CanDBError.Error(message)
        } catch {
            throw CanDBError.Error("unknown error")
        }
    }
    
    // remove specific records
    func removeDataForId(tableName: String, idString: String, idsToDelete: NSArray) throws {
        var ids = ""
        
        idsToDelete.enumerateObjectsUsingBlock { (object, index, stop) -> Void in
            if index == 0 { ids = (object as! String) }
            else if index == (idsToDelete.count - 1) { ids = ids + ", " + (object as! String) }
            else { ids = ids + ", " + (object as! String)}
        }
        
        do {
            try self.execute("DELETE FROM \(tableName) where \(idString) in ( \(ids) )")
        } catch CanDBError.Error(let message) {
            throw CanDBError.Error(message)
        } catch {
            throw CanDBError.Error("unknown error")
        }
    }
    
    func loadData(tableName: String) -> NSArray {
        let query = "SELECT _jsonData from \(tableName)"
        let resultSet = self.database.executeQuery(query, withArgumentsInArray: nil)
        let result: NSMutableArray = []
        
        while resultSet.next() {
            let jsonString = resultSet.stringForColumn("_jsonData")
            let jsonData: NSData = jsonString.dataUsingEncoding(NSUTF8StringEncoding)!
            let json: AnyObject = try! NSJSONSerialization.JSONObjectWithData(jsonData, options: [])
            let jsonDictionary = json as? NSDictionary
            
            result.addObject(jsonDictionary!)
        }
        
        return result as NSArray
    }
    
    // you can specify the query, but the result will be the _jsonData parsed into NSDictionary
    func loadDataWithQuery(query: String) -> NSArray {
        let resultSet = self.database.executeQuery(query, withArgumentsInArray: nil)
        let result: NSMutableArray = []
        
        while resultSet.next() {
            let jsonString = resultSet.stringForColumn("_jsonData")
            let jsonData: NSData = jsonString.dataUsingEncoding(NSUTF8StringEncoding)!
            let json: AnyObject = try! NSJSONSerialization.JSONObjectWithData(jsonData, options: [])
            let jsonDictionary = json as? NSDictionary
            
            result.addObject(jsonDictionary!)
        }
        
        return result as NSArray
    }
    
    func loadRawDataWithQuery(query: String) -> NSArray {
        let resultSet = self.database.executeQuery(query, withArgumentsInArray: nil)
        let result: NSMutableArray = []
        
        while resultSet.next() {
            result.addObject(resultSet.resultDictionary())
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