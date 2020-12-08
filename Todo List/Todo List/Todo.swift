//
//  Todo.swift
//  Todo List
//
//  Created by Juliana de Carvalho on 2020-11-29.
//  Copyright © 2020 Juliana de Carvalho. All rights reserved.
//  Assignment 6
//  Student Id: 30113760

import Foundation

class Todo
{
    
    var listName: String = ""
    var task: String = ""
    var notes: String = ""
    var due: String = ""
    var status: String = ""
    
    init()
    {

    }
    
    init(listName:String, task:String, notes:String, due:String, status:String)
    {
        self.listName = listName
        self.task = task
        self.notes = notes
        self.due = due
        self.status = status
    }
    
    
}
