//
//  canDB.swift
//
//  Created by Rafael on 24/06/15.
//  Copyright (c) 2015 Rafael Colatusso. All rights reserved.
//

import Foundation

class canDB: NSObject {

    let kCanDBErrorDomain = "com.candb.error"
    
    static let sharedInstance = canDB()
    
    var database = FMDatabase()
    
    override init() {
        super.init()
        
        println("iniciando")
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

    func addIndex(tableName: String, columns: NSArray, error: NSErrorPointer?) {
        for column in columns {
            self.execute("ALTER TABLE \(tableName) ADD COLUMN \(column) TEXT", error: error)
        }
        
        self.reIndex(tableName)
    }
    
    func removeIndex(tableName:String, columns: NSArray) {
        
    }
    
    // puts "" if value not found
    func reIndex(tableName: String) {
        
    }

    func saveData(tableName: String, data: NSArray, idString: String, error: NSErrorPointer?) {
        self.createTable(tableName, idString: idString, error: error);
        
        let columnsArray = self.getTableColumnsForTable(tableName)
        
        for record in data {
            
            let Id = record.objectForKey(idString) as! String
            let selectQuery = "SELECT _localId FROM \(tableName) WHERE \(idString) = '\(Id)'"
            let result = self.loadDataWithQuery(selectQuery)
            
            if result.count > 0 {
                // custom columns
                var extraQuery = ""
                for columnName in columnsArray {
                    if (!columnName.isEqualToString("_localId") && !columnName.isEqualToString("_jsonData") && !columnName.isEqualToString(idString)) {
                        extraQuery += ", \(columnName) = '\(record.objectForKey(columnName)!)' "
                    }
                }
                
                if !self.database.executeUpdate("UPDATE \(tableName) set _jsonData = '\(record)' \(extraQuery) WHERE \(idString) = '\(Id)'", withArgumentsInArray: nil) {
                    error?.memory = NSError(domain: kCanDBErrorDomain, code: -1, userInfo: ["message": self.database.lastErrorMessage()])
                }
            }
            else {
                // custom columns
                var extraColumns = ""
                var extraValues = ""
                for columnName in columnsArray {
                    if (!columnName.isEqualToString("_localId") && !columnName.isEqualToString("_jsonData")) {
                        extraColumns += ", \(columnName)"
                        extraValues += ",'\(record.objectForKey(columnName)!)' "
                    }
                }
                
                if !self.database.executeUpdate("INSERT INTO \(tableName) (_jsonData \(extraColumns)) VALUES ('\(record)' \(extraValues))", withArgumentsInArray: nil) {
                    error?.memory = NSError(domain: kCanDBErrorDomain, code: -1, userInfo: ["message": self.database.lastErrorMessage()])
                }
            }
        }
    }

    func removeData() {

    }

    func loadData() {

    }
    
    func loadDataWithQuery(query: String) -> NSArray {
        let resultSet = self.database.executeQuery(query, withArgumentsInArray: nil)
        var result: NSMutableArray = []
        
        while resultSet.next() {
            result.addObject(resultSet.resultDictionary().description)
        }
        
        return result as NSArray
    }
    
    // helper
    func getTableColumnsForTable(tableName: String) -> NSMutableArray {
        // get the extra columns
        let columns = self.database.executeQuery("PRAGMA table_info(\(tableName))", withArgumentsInArray: nil)
        let columnsArray: NSMutableArray = []
        
        while columns.next() {
            let columnName = columns.objectForColumnName("name") as! String
            columnsArray.addObject(columnName)
        }
        
        return columnsArray
        
    }
}