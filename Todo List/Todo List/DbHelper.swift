//
//  DBHelper.swift
//  Todo List
//
//  Created by Juliana de Carvalho on 2020-11-29.
//  Copyright © 2020 Juliana de Carvalho. All rights reserved.
//  Assignment 6
//  Student Id: 30113760

import Foundation

class DBHelper{

    init()
    {
        db = openDatabase()
        createTable()
    }
     var db:OpaquePointer?
    func openDatabase() -> OpaquePointer?
    {
        var db: OpaquePointer? = nil
        if sqlite3_open(dataFilePath(), &db) != SQLITE_OK
        {
            sqlite3_close(db)
            print("error opening database")
            return nil
        }
        else
        {
            print("Successfully opened connection to database")
            return db
        }
    }

    func createTable() {
        let createTableString = "CREATE TABLE IF NOT EXISTS TODO " +
                                "(LIST_NAME CHAR(50), TASK CHAR(50), NOTES CHAR(255), DUE STRING(20), STATUS CHAR(20));"
        var createTableStatement: OpaquePointer? = nil
        if sqlite3_prepare_v2(db, createTableString, -1, &createTableStatement, nil) == SQLITE_OK
        {
            if sqlite3_step(createTableStatement) == SQLITE_DONE
            {
                print("todo table created.")
            } else {
                print("todo table could not be created.")
            }
        } else {
            print("CREATE TABLE statement could not be prepared.")
        }
        sqlite3_finalize(createTableStatement)
    }

    
    func dropTable() {
        let dropTableString = "DROP TABLE IF EXISTS TODO ;"
        var dropTableStatement: OpaquePointer? = nil
        if sqlite3_prepare_v2(db, dropTableString, -1, &dropTableStatement, nil) == SQLITE_OK
        {
            if sqlite3_step(dropTableStatement) == SQLITE_DONE
            {
                print("todo table droped.")
            } else {
                print("todo table could not be droped.")
            }
        } else {
            print("DROP TABLE statement could not be prepared.")
        }
        sqlite3_finalize(dropTableStatement)
    }
    
    

    func insert(listName:String,task:String)
    {
        let tasks = read()
        for t in tasks
        {
            if t.listName == listName && t.task == task
            {
                return 
            }
        }
        let empty = ""
        
        let insertStatementString = "INSERT INTO TODO (LIST_NAME, TASK, NOTES, DUE, STATUS) VALUES (?, ?, ?, ?, ?);"
        var insertStatement: OpaquePointer? = nil
        if sqlite3_prepare_v2(db, insertStatementString, -1, &insertStatement, nil) == SQLITE_OK {
            sqlite3_bind_text(insertStatement, 1, (listName as NSString).utf8String, -1, nil)
            sqlite3_bind_text(insertStatement, 2, (task as NSString).utf8String, -1, nil)
            sqlite3_bind_text(insertStatement, 3, (empty as NSString).utf8String, -1, nil)
            sqlite3_bind_text(insertStatement, 4, (empty as NSString).utf8String, -1, nil)
            sqlite3_bind_text(insertStatement, 5, (empty as NSString).utf8String, -1, nil)
         
            if sqlite3_step(insertStatement) == SQLITE_DONE {
  
                print("Successfully inserted row.")
            } else {
                print("Could not insert row.")
            }
        } else {
            print("INSERT statement could not be prepared.")
        }
        sqlite3_finalize(insertStatement)
    }

    func update(task:String, notes: String, due: String, status: String)
      {

          let updateStatementString = "UPDATE TODO SET NOTES = '\(notes)' , STATUS = '\(status)', DUE = '\(due)' WHERE TASK = '\(task)' ;"
          var updateStatement: OpaquePointer? = nil
          if sqlite3_prepare_v2(db, updateStatementString, -1, &updateStatement, nil) == SQLITE_OK {
              if sqlite3_step(updateStatement) == SQLITE_DONE {
    
                  print("Successfully updated row.")
              } else {
                  print("Could not update row.")
              }
          } else {
              print("Update statement could not be prepared.")
          }
          sqlite3_finalize(updateStatement)
      }

    func read() -> [Todo] {
        let queryStatementString = "SELECT TASK, NOTES, DUE, STATUS, LIST_NAME FROM TODO "
        var queryStatement: OpaquePointer? = nil
        var todotasks : [Todo] = []
        if sqlite3_prepare_v2(db, queryStatementString, -1, &queryStatement, nil) == SQLITE_OK {
            while sqlite3_step(queryStatement) == SQLITE_ROW {
              let task = String(describing: String(cString: sqlite3_column_text(queryStatement, 0)))
              let notes = String(describing: String(cString: sqlite3_column_text(queryStatement, 1)))
              let due = String(describing: String(cString: sqlite3_column_text(queryStatement, 2)))
              let status = String(describing: String(cString: sqlite3_column_text(queryStatement, 3)))
              let listName = String(describing: String(cString: sqlite3_column_text(queryStatement, 4)))
              todotasks.append(Todo(listName: listName, task: task, notes: notes, due: due, status: status))
              print("Query Result:")
              print("\(task) | \(notes) | \(status)")
            }
        } else {
            print("SELECT statement could not be prepared")
        }
        sqlite3_finalize(queryStatement)
        return todotasks
    }
    
    func readByTask(task: String) -> Todo {
        var todotasks : Todo? = nil
        let queryStatementString = "SELECT NOTES, DUE, STATUS, LIST_NAME FROM TODO WHERE TASK = '\(task)'"
        var queryStatement: OpaquePointer? = nil

        if sqlite3_prepare_v2(db, queryStatementString, -1, &queryStatement, nil) == SQLITE_OK {

               if sqlite3_step(queryStatement) == SQLITE_ROW {
                    let notes = String(describing: String(cString: sqlite3_column_text(queryStatement, 0)))
                    let due = String(describing: String(cString: sqlite3_column_text(queryStatement, 1)))
                    let status = String(describing: String(cString: sqlite3_column_text(queryStatement, 2)))
                    let listName = String(describing: String(cString: sqlite3_column_text(queryStatement, 3)))
                    todotasks = Todo(listName: listName, task: task, notes: notes, due: due, status: status)
                    print("Query Result:")
                    print("\(task) | \(notes) | \(status)")
             }
        } else {
            print("SELECT statement could not be prepared")
        }
        sqlite3_finalize(queryStatement)
        return todotasks!
    }
    
    func deleteByTask(task:String) {
        let deleteStatementStirng = "DELETE FROM TODO WHERE TASK = ?;"
        var deleteStatement: OpaquePointer? = nil
        if sqlite3_prepare_v2(db, deleteStatementStirng, -1, &deleteStatement, nil) == SQLITE_OK {
            sqlite3_bind_text(deleteStatement, 1, (task as NSString).utf8String, -1, nil)
            if sqlite3_step(deleteStatement) == SQLITE_DONE {
                print("Successfully deleted row.")
            } else {
                print("Could not delete row.")
            }
        } else {
            print("DELETE statement could not be prepared")
        }
        sqlite3_finalize(deleteStatement)
    }

    func dataFilePath() -> String {
            let urls = FileManager.default.urls(for:
                .documentDirectory, in: .userDomainMask)
            var url:String?
            url = urls.first?.appendingPathComponent("data.plist").path
            return url!
    }

}
