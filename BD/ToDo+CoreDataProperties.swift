//
//  ToDo+CoreDataProperties.swift
//  ToDoList
//
//  Created by  Сергей on 16.05.2025.
//
//

import Foundation
import CoreData


extension ToDo {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ToDo> {
        return NSFetchRequest<ToDo>(entityName: "ToDo")
    }

    @NSManaged public var nameTitle: String?
    @NSManaged public var descriptionName: String?
    @NSManaged public var statusSwitch: Bool
    @NSManaged public var dateString: Date?
    @NSManaged public var id: String?

}

extension ToDo : Identifiable {
    
    func updateToDoList(newList: ToDoListModel ){
        self.nameTitle = newList.nameTitle
        self.descriptionName = newList.descriptionName
        self.statusSwitch = newList.statusSwitch
        self.dateString = newList.dateString
        try? managedObjectContext?.save()
    }
    
    func deleteToDoList(){
        managedObjectContext?.delete(self)
        try? managedObjectContext?.save()
    }
}
