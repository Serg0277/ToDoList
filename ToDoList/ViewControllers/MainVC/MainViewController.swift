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
    private let searchBar: UISearchBar = {
          let search = UISearchBar()
            search.placeholder = "Поиск заметок..."
            return search
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "ToDoList"
        creadtable()
        configureSourse()
        configuresearchBar()
        view.backgroundColor = .red
        view.addSubview(mytableView)
    }
    
    private func configuresearchBar(){
        navigationController?.navigationBar.topItem?.titleView = searchBar
        searchBar.delegate = self
        searchBar.becomeFirstResponder()
    }
    
    private func configureSourse(){
        dataSourseToDoList.append(contentsOf: [NewsTableViewCellModel(titleName: "Понедельник", descriptionName: "Заварить чай сходить в зал", dateString: "12.05.2025", statusSwitch: false),
                                               NewsTableViewCellModel(titleName: "Вторник", descriptionName: "Убрать сад", dateString: "13.05.2025", statusSwitch: false),
                                               NewsTableViewCellModel(titleName: "Среда", descriptionName: "Сходить в магазин, Сходить в магазин, Сходить в магазин, Сходить в магазин, Сходить в магазин, Сходить в магазин, Сходить в магазин, Сходить в магазин, Сходить в магазин", dateString: "14.05.2025", statusSwitch: true),
                                               NewsTableViewCellModel(titleName: "Четверг", descriptionName: "Убрать сад", dateString: "15.05.2025", statusSwitch: false),
                                               NewsTableViewCellModel(titleName: "Пятница", descriptionName: "Сходить в магазин, Сходить в магазин, Сходить в магазин, Сходить в магазин, Сходить в магазин, Сходить в магазин, Сходить в магазин, Сходить в магазин, Сходить в магазин", dateString: "14.05.2025", statusSwitch: true),
                                               NewsTableViewCellModel(titleName: "Срочно", descriptionName: "Убрать гараж", dateString: "11.05.2025", statusSwitch: false)
                                               
        ])
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
        navigationController?.pushViewController(ToDoEditViewController(dataEdit: data), animated: true)
        }
    }

extension MainViewController: UISearchBarDelegate{
   
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let text = searchBar.text, !text.replacingOccurrences(of: " ", with: "").isEmpty else {
            return
        }
        searchBar.resignFirstResponder()
        //вызываем функцию поиска с параметром текст
    }
}
