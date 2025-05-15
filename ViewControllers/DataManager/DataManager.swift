//
//  DataManager.swift
//  ToDo List
//
//  Created by  Сергей on 14.05.2025.
//

import Foundation
import UIKit

final class DataManager{
    static let shared = DataManager()
    private var dataSourse : InfoModel?
    
    public func uploadToDOList(completion:  @escaping(Result<InfoModel, Error>) -> Void){
        
        guard  let url = URL(string: "https://dummyjson.com/todos") else {
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) {[weak self] data, _, error in
            if let error = error {
                print("Ошибка: \(error)")
                return
            }
            guard let data = data else {
                print("Нет данных")
                return
            }
            do {
                self?.dataSourse = try JSONDecoder().decode(InfoModel.self, from: data)
                guard let dataSourse = self?.dataSourse else {return}
                completion(.success(dataSourse))
            } catch {
                print("Ошибка декодирования JSON: (error)")
                completion(.failure(error))
            }
        }
        task.resume()
    }
}
