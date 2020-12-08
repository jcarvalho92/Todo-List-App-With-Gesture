//
//  ViewController.swift
//  Todo List
//
//  Created by Juliana de Carvalho on 2020-11-13.
//  Copyright © 2020 Juliana de Carvalho. All rights reserved.
// Assignment 6
//  Student Id: 30113760



import UIKit

class ViewController: UIViewController , UITableViewDataSource , UITableViewDelegate {

    @IBOutlet var listName: UITextField!
    @IBOutlet var taskDescription: UITextField!
    @IBOutlet var tableView:UITableView!

    var db: DBHelper = DBHelper()
    
    var todo:[Todo] = []
    var selectedTask = Todo()

    @IBAction func addTask(_ sender: UIButton) {
        //inserting the new task in the database
        db.insert(listName: listName.text! , task: taskDescription.text!)
        
        todo = db.read()
        //displaying a new row with the new task in the tableview
        let selectedIndexPath = IndexPath(row: todo.count - 1, section: 0)
        tableView.beginUpdates()
        tableView.insertRows(at: [selectedIndexPath], with: .automatic)
        tableView.endUpdates()
        //cleaning the text field
        taskDescription.text = ""
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        
        todo = db.read()
        
        if (todo.count > 0){
          listName.text = todo[0].listName
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // MARK: Table View Data Source Methods
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return todo.count
    }

    

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
           let cell = tableView.dequeueReusableCell(withIdentifier: "DetailsTask", for: indexPath)
           
           let taskText = todo[indexPath.row].task
           cell.detailTextLabel?.textColor = UIColor.black
        
            if (todo[indexPath.row].status == "Completed"){
                cell.textLabel?.attributedText = strikeThroughText(text: taskText)
                cell.detailTextLabel?.text = "Completed"
            }
            else{
                
                cell.textLabel?.text = taskText
                cell.detailTextLabel?.text = todo[indexPath.row].due
                
                //if due date is less than today it changes the due date label to red
                let dueDateString = todo[indexPath.row].due
                if (dueDateString != ""){
                    let formatter = DateFormatter()
                    formatter.dateStyle = .long
                    let dueDate = formatter.date(from: dueDateString)
                    //getting todays date
                    let today = Date()
                    if dueDate! < today {
                       cell.detailTextLabel?.textColor = UIColor.red
                    }
                }
            }

           return cell
       }
    
     func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
           let item = todo[indexPath.row]
           print(item)
     }
    
    func tableView(_ tableView: UITableView,
                   leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration?
    {
        let goToDetailScreenAction = UIContextualAction(style: .normal, title:  "Details", handler: { (ac:UIContextualAction, view:UIView, success:(Bool) -> Void) in
                let mainStoryboard = UIStoryboard(name: "Main", bundle: Bundle.main)
                       //ref to DetailsViewController
                       guard let destinationViewController = mainStoryboard.instantiateViewController(withIdentifier: "DestinationViewController") as? DetailsViewController else {
                           print("couldn't find the view controller")
                           return
                       }
                       self.selectedTask = self.todo[indexPath.row]
                       //passing just the info from the task that is related to the button that was selected
                       destinationViewController.tasks = self.selectedTask
                       
                       destinationViewController.title = "Details"
                       self.navigationController?.pushViewController(destinationViewController, animated: true)
                success(true)
            })
            goToDetailScreenAction.backgroundColor = .blue
    
            return UISwipeActionsConfiguration(actions: [goToDetailScreenAction])
    }
    
    func tableView(_ tableView: UITableView,
                   trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration?
    {

     let deleteAction = UIContextualAction(style: .destructive, title: "Delete") {  (contextualAction, view, boolValue) in
         // Delete the row from the data source
        let taskToDelete = self.todo[indexPath.row].task
        self.db.deleteByTask(task: taskToDelete)
         
        self.todo = self.db.read()
         
         tableView.beginUpdates()
         tableView.deleteRows(at: [indexPath],with: .automatic)
         tableView.endUpdates()
     }

     let checkmarkAction = UIContextualAction(style: .normal, title: "") {  (contextualAction, view, boolValue) in

        //update
        self.db.update(task: self.todo[indexPath.row].task, notes: self.todo[indexPath.row].notes, due: self.todo[indexPath.row].due, status: "Completed")
        
        let mainStoryboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        //ref to ViewController
        guard let destinationViewController = mainStoryboard.instantiateViewController(withIdentifier: "tasksListView") as? ViewController else {
            print("couldn't find the view controller")
            return
        }
        destinationViewController.title = "Todo List"
        self.navigationController?.pushViewController(destinationViewController, animated: true)

     }

     checkmarkAction.backgroundColor = UIColor.yellow
     checkmarkAction.image = UIImage(named:"checkmark")
     let swipeActions = UISwipeActionsConfiguration(actions: [deleteAction,checkmarkAction])
     return swipeActions
    }
    
    //function to cross out the text
    func strikeThroughText(text: String) -> NSMutableAttributedString {
        let attributeString: NSMutableAttributedString =  NSMutableAttributedString(string: text)
        attributeString.addAttribute(NSAttributedString.Key.strikethroughStyle, value: 2, range: NSMakeRange(0, attributeString.length))
        
        return attributeString
    }

}

