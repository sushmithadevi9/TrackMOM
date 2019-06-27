//
//  CoreDataStack.swift
//  ToDoApp
//
//  Created by Sushmitha Devi on 6/25/19.
//  Copyright © 2018 Sushmitha Devi. All rights reserved.
//

import Foundation
import CoreData

class CoreDataStack{
    var container:NSPersistentContainer{
        let container = NSPersistentContainer(name: "Todos")
        container.loadPersistentStores { (description, error) in
            guard error == nil else{ return }
            
        }
        return container
    }
    
    var managedcontext:NSManagedObjectContext{
        return container.viewContext
    }
}
