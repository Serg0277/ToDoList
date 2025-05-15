//
//  ViewController.swift
//  ToDo List
//
//  Created by  Сергей on 12.05.2025.
//

import UIKit

class MainViewController: UIViewController {
    
    private var mytableView = UITableView()
    public var dataSourseToDoList = [NewsTableViewCellModel]()
    public var dataSourse : InfoModel?
    private var resultSearch  = [NewsTableViewCellModel]()
   
    private let searchBar: UISearchBar = {
        let search = UISearchBar()
        search.placeholder = "Поиск заметок..."
        return search
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "ToDoList"
        configuresearchBar()
        uploadDataToDOList()
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
    
       private func uploadDataToDOList(){
        dataSourseToDoList.removeAll()
        DataManager.shared.uploadToDOList { result in
            switch result {
            case .success(let value):
                for data in value.todos {
                    let id = String(data.id)
                    let todo = data.todo
                    let comleted = data.completed
                    //   let userId = String(data.userId)
                    
                    let dataSourse: NewsTableViewCellModel = NewsTableViewCellModel(titleName: id, descriptionName: todo, dateString:"", statusSwitch: comleted)
                    self.dataSourseToDoList.append(dataSourse)
                }
                
            case .failure(_): break
                
            }
            DispatchQueue.main.async {
                self.mytableView.reloadData()
            }
            
            
        }
    }
     
    private func configuresearchBar(){
        navigationController?.navigationBar.topItem?.titleView = searchBar
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "plus"),
                                                            style: .done,
                                                            target: self,
                                                            action: #selector(didTapNewToDoList))
        searchBar.delegate = self
        
    }
    
    @objc private func didTapNewToDoList(){
        searchBar.resignFirstResponder()
        navigationController?.pushViewController(ToDoEditViewController(dataEdit: nil), animated: true)
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
        dataSourseToDoList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! MainCellVC
        cell.configureCell(with: dataSourseToDoList[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let data = dataSourseToDoList[indexPath.row]
        searchBar.resignFirstResponder()
        navigationController?.pushViewController(ToDoEditViewController(dataEdit: data), animated: true)
    }
}

extension MainViewController: UISearchBarDelegate{
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let text = searchBar.text, !text.replacingOccurrences(of: " ", with: "").isEmpty else {
            return
        }
        searchBar.resignFirstResponder()
         resultSearch.removeAll()
          self.searchToDo(query: text)

    }
    func searchToDo(query: String){
        for value in dataSourseToDoList{
            if query == value.titleName{
                resultSearch.append(value)
                dataSourseToDoList = resultSearch
                self.mytableView.reloadData()
            }
        }
    }
}

//name.hasPrefix(term.lowercased())
