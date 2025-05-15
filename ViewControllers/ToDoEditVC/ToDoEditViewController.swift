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
    
    private let saveButton: UIButton = {
        let bt = UIButton(type: .system)
        bt.setTitle("Save", for: .normal)
        bt.titleLabel?.font = .systemFont(ofSize: 12.0, weight: .light)
        bt.layer.masksToBounds = true
        bt.layer.cornerRadius = 12
        bt.layer.borderWidth = 2.0
        bt.backgroundColor = .green
        bt.setTitleColor(.label, for: .normal)
        return bt
    }()
    
    init(dataEdit : NewsTableViewCellModel?){
        self.dataSourse = dataEdit
        super.init(nibName: nil, bundle: nil)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        view.addSubview(editView)
        getViewData()
        view.addSubview(saveButton)
        saveButton.addTarget(self, action: #selector(didTapSaveButton), for: .touchUpInside)
        setupTapGesture()
        setupKeyBoard ()
    }
    
    @objc func didTapSaveButton(){
        editView.titleNameTextField.resignFirstResponder()
        editView.descriptionNameTextView.resignFirstResponder()
        editView.dateTextField.resignFirstResponder()
        //проврка на корректность
        guard let titleName = editView.titleNameTextField.text, let descriptionName = editView.descriptionNameTextView.text, let dateString = editView.dateTextField.text, !titleName.isEmpty, !descriptionName.isEmpty, !dateString.isEmpty
        else{
            //сделать сообщением
            print ("Заполните все поля")
            return
        }
        
        //собираем данные и записыаем их в базу
        if (dataSourse != nil) {
            print("Edit")
            var _ = NewsTableViewCellModel(titleName: editView.titleNameTextField.text ?? "", descriptionName: editView.descriptionNameTextView.text, dateString: editView.dateTextField.text ?? "", statusSwitch: dataSourse?.statusSwitch ?? false)
        }else{
            print("New add")
        }
        
        //переходим на главный экран
        navigationController?.popViewController(animated: false)
    }
    private func getViewData(){
        if let data = dataSourse{
            editView.configureView(sourceData: data)
        }
    }
   
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewDidLayoutSubviews() {
        editView.frame = CGRect(
            x:  0,
            y: view.safeAreaInsets.top,
            width: view.frame.width ,
            height: view.frame.height * 0.5 )
        
        saveButton.frame = CGRect(
            x: view.frame.width * 0.65,
            y: view.frame.maxY - (view.frame.height * 0.1),
            width: view.frame.width * 0.3,
            height: view.frame.height * 0.06)
    }
    //  MARK: - Keyboard
    
    private func   setupTapGesture() {
        view.addGestureRecognizer(UITapGestureRecognizer(target: self,
                                                         action: #selector(handleTapDismis)))
        
    }
    @objc private func handleTapDismis () {
        view.endEditing(true)
    }
    private func setupKeyBoard (){
        
        NotificationCenter.default.addObserver(self, selector: #selector(handlKeyboardShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(handlKeyboardHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc private func handlKeyboardShow (notification: Notification){
        guard let value = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else {return}
      
        let keybordHeight = value.cgRectValue.height
        let editViewHeight = editView.frame.height
        let difference = editViewHeight - keybordHeight
        
        self.view.transform = CGAffineTransform(translationX: 0, y: CGFloat(-difference) - 10)
    }
    
    
    @objc private func handlKeyboardHide (){
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            self.view.transform = .identity
        }, completion: nil )
        
    }
    
}

