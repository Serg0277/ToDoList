//
//  ToDoEditViewController.swift
//  ToDo List
//
//  Created by  Сергей on 12.05.2025.
// контроллер для редактиования

import UIKit

class ToDoEditViewController: UIViewController {

    private var dataSourse : NewsTableViewCellModel?
    private let editView = ToDoEditView()
    
    init(dataEdit : NewsTableViewCellModel){
        self.dataSourse = dataEdit
        super.init(nibName: nil, bundle: nil)
        
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(editView)
       getViewData()
    }
    
    private func getViewData(){
       if let data = dataSourse{
           editView.configureView(sourceData: data)
        }
    }
    override func viewDidLayoutSubviews() {
        editView.frame = view.bounds
    }
}
