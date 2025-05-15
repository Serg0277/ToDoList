//
//  ToDoEditView.swift
//  ToDo List
//
//  Created by  Сергей on 12.05.2025.
//

import UIKit

final class ToDoEditView: UIView {
    
    private let titleNameLabel: UILabel = {
        let label = UILabel()
        label.text = "Номер задачи"
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 18, weight: .semibold)
        label.backgroundColor = .systemGray4
        label.layer.cornerRadius = 12
        label.layer.masksToBounds = true
        return label
    }()
    
    let titleNameTextField: UITextField = {
        let tf = UITextField()
        tf.autocorrectionType = .no
        tf.returnKeyType = .continue
        tf.layer.cornerRadius = 12
        tf.layer.borderColor = UIColor.lightGray.cgColor
        tf.layer.borderWidth = 1
        tf.font = .systemFont(ofSize: 16)
        tf.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 5, height: 0))
        tf.leftViewMode = .always
        tf.backgroundColor = .secondarySystemBackground
        return tf
    }()
    
    private let descriptionNameLabel: UILabel = {
        let label = UILabel()
        label.text = "Описание задачи"
        label.textAlignment = .center
        label.backgroundColor = .systemGray4
        label.layer.cornerRadius = 12
        label.layer.masksToBounds = true
        label.font = .systemFont(ofSize: 18, weight: .semibold)
        return label
    }()
    
    let descriptionNameTextView: UITextView = {
        let tv = UITextView()
        tv.autocorrectionType = .no
        tv.returnKeyType = .continue
        tv.layer.cornerRadius = 12
        tv.layer.borderColor = UIColor.lightGray.cgColor
        tv.layer.borderWidth = 1
        tv.backgroundColor = .secondarySystemBackground
        tv.font = .systemFont(ofSize: 16)
        return tv
    }()
    private let dateLabel: UILabel = {
        let label = UILabel()
        label.text = "Срок выполнения задачи"
        label.textAlignment = .center
        label.layer.cornerRadius = 12
        label.layer.masksToBounds = true
        label.font = .systemFont(ofSize: 18, weight: .semibold)
        label.backgroundColor = .systemGray4
        return label
    }()
    let dateTextField: UITextField = {
        let tf = UITextField()
        tf.autocorrectionType = .no
        tf.returnKeyType = .continue
        tf.layer.cornerRadius = 12
        tf.layer.borderColor = UIColor.lightGray.cgColor
        tf.layer.borderWidth = 1
        tf.font = .systemFont(ofSize: 16)
        tf.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 5, height: 0))
        tf.leftViewMode = .always
        tf.backgroundColor = .secondarySystemBackground
        return tf
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        layer.cornerRadius = 12
        backgroundColor = .systemBackground
        addSubview(titleNameLabel)
        addSubview(titleNameTextField)
        addSubview(descriptionNameLabel)
        addSubview(descriptionNameTextView)
        addSubview(dateLabel)
        addSubview(dateTextField)
    }
    
    func configureView(sourceData: NewsTableViewCellModel){
        titleNameTextField.text = sourceData.titleName
        descriptionNameTextView.text = sourceData.descriptionName
        dateTextField.text = sourceData.dateString
    }
   
    override func layoutSubviews() {
        super.layoutSubviews()
        
        titleNameLabel.frame = CGRect(
            x: 5,
            y: 5,
            width: frame.width * 0.95,
            height: frame.height * 0.1)
        
        titleNameTextField.frame = CGRect(
            x: 5,
            y: titleNameLabel.frame.maxY + 5,
            width: frame.width * 0.95,
            height: frame.height * 0.1)
        
        descriptionNameLabel.frame = CGRect(
            x: 5,
            y: titleNameTextField.frame.maxY + 5,
            width: frame.width * 0.95,
            height: frame.height * 0.1)
        
        descriptionNameTextView.frame = CGRect(
            x: 5,
            y: descriptionNameLabel.frame.maxY + 5,
            width: frame.width * 0.95,
            height: frame.height * 0.5)
        
        dateLabel.frame = CGRect(
            x: 5,
            y: descriptionNameTextView.frame.maxY + 5,
            width: frame.width * 0.95,
            height: frame.height * 0.1)
        
        dateTextField.frame = CGRect(
            x: 5,
            y: dateLabel.frame.maxY + 5,
            width: frame.width * 0.45,
            height: frame.height * 0.1)
    }
}

extension ToDoEditView: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == titleNameTextField {
            titleNameTextField.becomeFirstResponder()
        }else if textField == descriptionNameTextView {
            descriptionNameTextView.becomeFirstResponder()
        }else if textField == dateTextField {
            dateTextField.becomeFirstResponder()
        }
        return true
    }
}
