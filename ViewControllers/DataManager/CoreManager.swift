//
//  CoreManager.swift
//  ToDoList
//
//  Created by  Сергей on 16.05.2025.
// менеджер работы с базой данных 

import Foundation
import CoreData

class CoreManager {
    
    static let shared = CoreManager()
    public var todoList = [ToDo]()
    
    private init(){
        getAllToDoList()
    }
    
    public func getAllToDoList(){
        let req = ToDo.fetchRequest()
        if let result = try? persistentContainer.viewContext.fetch(req){
            self.todoList = result
        }
    }
    public func addToDoList(list: ToDoListModel){
        let data = ToDo(context: persistentContainer.viewContext)
        data.id = UUID().uuidString
        data.nameTitle = list.nameTitle
        data.descriptionName = list.descriptionName
        data.dateString =  list.dateString 
        data.statusSwitch = list.statusSwitch
        saveContext()
        getAllToDoList()
    }
    
    // MARK: - Core Data stack
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "ToDoList")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    // MARK: - Core Data Saving support
    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
}
