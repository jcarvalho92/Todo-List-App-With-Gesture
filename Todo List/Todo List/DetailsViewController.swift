//
//  DetailsViewController.swift
//  Todo List
//
//  Created by Juliana de Carvalho on 2020-11-14.
//  Copyright © 2020 Juliana de Carvalho. All rights reserved.
//  Assignment 6
//  Student Id: 30113760


import UIKit

class DetailsViewController: UIViewController {

    @IBOutlet var desc: UITextField!
    @IBOutlet var notesDetails: UITextView!
    @IBOutlet var hasDue: UISwitch!
    @IBOutlet var choosenDate: UIDatePicker!
    @IBOutlet var hasCompletedTask: UISwitch!
    public var tasks:Todo? = nil
    
    var status = ""
    var dueDate = ""
    
    var db: DBHelper = DBHelper()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        desc.text = tasks!.task
        //getting the info from the database related to the selected task
         let todo: Todo = db.readByTask(task: tasks!.task)
        
        notesDetails.text = todo.notes
        
        if(todo.status == "Completed"){
            hasCompletedTask.isOn = true
        }
        if (todo.due != ""){
            hasDue.isOn = true
            
            let formatter = DateFormatter()
            formatter.dateStyle = .long
            let date = formatter.date(from: todo.due)
            choosenDate.date = date!
        }

    }
    
    @IBAction func hasDueDateChanged(_ sender: UISwitch) {
        //enabling or disabling the picker as the has due date switch changes
        choosenDate.isUserInteractionEnabled = (!choosenDate.isUserInteractionEnabled)
    }
    //cancel button action
    @IBAction func cancelGoBack(_ sender: UIButton) {
        
        let alert = UIAlertController(title: "Are you sure you want to discard the changes?", message: nil, preferredStyle: UIAlertController.Style.alert)

        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (action: UIAlertAction!) in
            //going back to main screen
            self.goToMainScreen()
        }))
        //if the user doesn't want to discard, no action are necessary. Just keep on the same screen
        alert.addAction(UIAlertAction(title: "No", style: .cancel))

        present(alert, animated: true, completion: nil)
        
    }
    //delete button action
    @IBAction func deleteTask(_ sender: UIButton) {
        
        let alert = UIAlertController(title: "Are you sure you want to delete?", message: nil, preferredStyle: UIAlertController.Style.alert)

        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (action: UIAlertAction!) in
            //deleting the information from the database and going back to main screen
            self.db.deleteByTask(task: self.tasks!.task)
            self.goToMainScreen()
        }))
        //if the user doesn't want to delete, no action are necessary. Just keep on the same screen
        alert.addAction(UIAlertAction(title: "No", style: .cancel))

        present(alert, animated: true, completion: nil)
        
    }
    //update button action
    @IBAction func updateTask(_ sender: UIButton) {
        
        if hasCompletedTask.isOn{
            status = "Completed"
        }else{
            status = "In Progress"
        }
        
        if hasDue.isOn{
            let formatter = DateFormatter()
            formatter.dateStyle = .long
            dueDate  = formatter.string(from: choosenDate.date)
        }
        
        let alert = UIAlertController(title: "Are you sure you want to update?", message: nil, preferredStyle: UIAlertController.Style.alert)

        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (action: UIAlertAction!) in
            //updating the information in the database and going back to main screen
            self.db.update(task: self.tasks!.task, notes: self.notesDetails.text, due: self.dueDate, status: self.status)
            self.goToMainScreen()
        }))
        //if the user doesn't want to update, no action are necessary. Just keep on the same screen
        alert.addAction(UIAlertAction(title: "No", style: .cancel))

        present(alert, animated: true, completion: nil)

    }
    
    func goToMainScreen(){
        let mainStoryboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        
        guard let destinationViewController = mainStoryboard.instantiateViewController(withIdentifier: "tasksListView") as? ViewController else {
            print("couldn't find the view controller")
            return
        }
        navigationController?.pushViewController(destinationViewController, animated: true)
    }
}
