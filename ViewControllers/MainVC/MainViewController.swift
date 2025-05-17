//
//  ViewController.swift
//  ToDo List
//
//  Created by  Сергей on 12.05.2025.
// Основной контроллер

import UIKit

class MainViewController: UIViewController {
    
    private let manager = CoreManager.shared
    private  var toDoBase :ToDo?
    private var mytableView = UITableView()
    private let userDefaults = UserDefaults.standard
    private var isLoadUrl = false
    public var dataSourse : InfoModel?
    
    
    private let searchBar: UISearchBar = {
        let search = UISearchBar()
        search.placeholder = "Поиск заметок..."
        
        return search
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        isLoadUrl = userDefaults.bool(forKey: "isLoadUrl")
        title = "ToDoList"
        configureSearchBar()
        uploadDataToDOListUrl()
        manager.getAllToDoList()
        view.backgroundColor = .systemBackground
        view.addSubview(mytableView)
        creadtable()
        searchBar.delegate = self
        searchBar.becomeFirstResponder()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        DispatchQueue.main.async {
            self.mytableView.reloadData()
        }
    }
    
    private func uploadDataToDOListUrl(){
        if !isLoadUrl{
            DataManager.shared.uploadToDOList { [weak self] result in
                switch result {
                case .success(let value):
                    for data in value.todos {
                        let id = String(data.id)
                        let todo = data.todo
                        let comleted = data.completed
                        let dataSourse: ToDoListModel = ToDoListModel(id: id, nameTitle: id, descriptionName: todo, dateString:Date(), statusSwitch: comleted)
                        self?.manager.addToDoList(list: dataSourse)
                    }
                    
                case .failure(_):
                    let alert = Alert.shared.alertUserError()
                    self?.present(alert, animated: true)
                    break
                }
            }
            userDefaults.set(true, forKey: "isLoadUrl")
        }
    }
    
    
    private func configureSearchBar(){
        navigationController?.navigationBar.topItem?.titleView = searchBar
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "plus"),
                                                            style: .done,
                                                            target: self,
                                                            action: #selector(didTapNewToDoList))
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "list.bullet"),
                                                           style: .done,
                                                           target: self,
                                                           action: #selector(didTapAllToDoList))
        
        searchBar.delegate = self
    }
    
    @objc private func didTapNewToDoList(){
        searchBar.resignFirstResponder()
        navigationController?.pushViewController(ToDoEditViewController(dataEdit: nil), animated: true)
    }
    
    @objc private func didTapAllToDoList(){
        manager.getAllToDoList()
        DispatchQueue.main.async {
            self.mytableView.reloadData()
        }
    }
    
    private func creadtable(){
        mytableView.register(MainCellVC.self, forCellReuseIdentifier: "cell")
        mytableView.bounces = false
        mytableView.dataSource = self
        mytableView.delegate = self
        mytableView.frame = view.bounds
    }
}

extension MainViewController: UITableViewDelegate, UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        manager.todoList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! MainCellVC
        cell.configureCell(with: manager.todoList[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let data = manager.todoList[indexPath.row]
        searchBar.resignFirstResponder()
        navigationController?.pushViewController(ToDoEditViewController(dataEdit: data), animated: true)
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool{
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath){
        
        if editingStyle == .delete{
            let toDoList =  manager.todoList[indexPath.row]
            toDoList.deleteToDoList()
            manager.todoList.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
    }
}

extension MainViewController: UISearchBarDelegate{
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let text = searchBar.text, !text.replacingOccurrences(of: " ", with: "").isEmpty else {
            return
        }
        searchBar.resignFirstResponder()
        searchBar.text = nil
        self.searchToDo(query: text)
        
    }
    
    func searchToDo(query: String){
        var resultSearch = [ToDo]()
        for value in manager.todoList{
            guard let searchString = value.nameTitle?.lowercased() else{return}
            if query == searchString{
                resultSearch.append(value)
                break
            }else{
                if  searchString.hasPrefix(query.lowercased()) {
                    resultSearch.append(value)
                }
            }
            
        }
        upDataUi(result: resultSearch)
    }
    
    func upDataUi(result : [ToDo]){
        if !result.isEmpty {
            manager.todoList = result
            DispatchQueue.main.async {
                self.mytableView.reloadData()
            }
        }
    }
}

