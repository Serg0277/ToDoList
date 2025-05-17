//
//  InfoModel.swift
//  ToDo List
//
//  Created by  Сергей on 14.05.2025.
// модель доя данных загружаемых из сети

import Foundation

struct ToDoModel: Codable {
    var id: Int
    var todo: String
    var completed: Bool
    var userId: Int
    
}
// Модель для корневого объекта JSON
struct InfoModel: Codable {
    let todos: [ToDoModel]
    let total: Int
    let skip: Int
    let limit: Int
}

