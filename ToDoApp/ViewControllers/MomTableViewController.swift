//
//  TodoTableViewController.swift
//  ToDoApp
//
//  Created by Sushmitha Devi on 6/25/19.
//  Copyright © 2018 Sushmitha Devi. All rights reserved.
//

import UIKit
import CoreData

class MomTableViewController: UITableViewController {
    @IBOutlet var tableview: UITableView!
    
    var resultscontroller:NSFetchedResultsController<Todos>!
    
    let coreDataStack = CoreDataStack()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.setHidesBackButton(true, animated:true)
        let request: NSFetchRequest<Todos> = Todos.fetchRequest()
        let sortDescriptors=NSSortDescriptor(key: "date", ascending: true)
    
        
        request.sortDescriptors=[sortDescriptors]
        resultscontroller = NSFetchedResultsController(fetchRequest: request, managedObjectContext: coreDataStack.managedcontext, sectionNameKeyPath: nil, cacheName: nil)
       resultscontroller.delegate=self
        
        do{
       try resultscontroller.performFetch()
            self.tableview.reloadData()
        }catch{
            print("error \(error.localizedDescription)")
        }
    
}
    
    
  

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return resultscontroller.sections?[section].numberOfObjects ?? 0
        
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TodoCell", for: indexPath)
        let todo = resultscontroller.object(at: indexPath)
        cell.textLabel?.text=todo.momtitle
        
        let formatter=DateFormatter()
         formatter.dateFormat = "dd.MM.yyyy"
        cell.detailTextLabel?.text=formatter.string(from: todo.date!)
        
        // Configure the cell...

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "showAddTodo", sender: tableView.cellForRow(at: indexPath))
        
    }
    
    override func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let action=UIContextualAction(style: .destructive, title: "done") { (action, view, completion) in
          
            let todo=self.resultscontroller.object(at: indexPath)
            self.resultscontroller.managedObjectContext.delete(todo)
            do{
                try self.resultscontroller.managedObjectContext.save()
                completion(true)
            }catch{
                print("failed \(error)")
                completion(false)
            }
        }
        action.image=#imageLiteral(resourceName: "done")
        action.backgroundColor = .green
        return UISwipeActionsConfiguration(actions: [action])
    }
   
    
    
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let action=UIContextualAction(style: .destructive, title: "delete") { (action, view, completion) in
           let todo=self.resultscontroller.object(at: indexPath)
            self.resultscontroller.managedObjectContext.delete(todo)
            do{
                try self.resultscontroller.managedObjectContext.save()
                completion(true)
            }catch{
                print("delete failed \(error)")
                completion(false)
            }
            completion(true)
        }
        action.image=#imageLiteral(resourceName: "delete")
        action.backgroundColor = .red
        return UISwipeActionsConfiguration(actions: [action])
    }
    

  

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let _ = sender as? UIBarButtonItem,let vc=segue.destination as? AddMomViewController{
            vc.managedContext = resultscontroller.managedObjectContext
        }
        if let cell = sender as? UITableViewCell,let vc = segue.destination as? AddMomViewController{
            vc.managedContext=resultscontroller.managedObjectContext
            if let indexPath=tableView.indexPath(for: cell){
            let todo=resultscontroller.object(at: indexPath)
            vc.todo=todo
            }
        }
    }

}


extension MomTableViewController:NSFetchedResultsControllerDelegate{
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableview.beginUpdates()
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableview.endUpdates()
    }
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            if let indexPath = newIndexPath{
                tableview.insertRows(at: [indexPath], with: .automatic)
            }
        case .delete:
            if let indexpath=indexPath{
                tableview.deleteRows(at: [indexPath!], with: .automatic)
            }
        case .update:
            if let indexpath=indexPath,let cell = tableView.cellForRow(at: indexPath!){
                let todo=resultscontroller.object(at: indexPath!)
                cell.textLabel?.text = todo.momtitle
            }
        default:
            break
        }
    }
}
