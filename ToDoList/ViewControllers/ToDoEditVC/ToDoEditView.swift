//
//  ToDoEditView.swift
//  ToDo List
//
//  Created by  Сергей on 12.05.2025.
//

import UIKit

final class ToDoEditView: UIView {
    
    private let titleNameLabel: UITextView = {
        let textView = UITextView()
        textView.font = .systemFont(ofSize: 16, weight: .semibold)
        //lable.numberOfLines = 0
        return textView
    }()
    
    private let descriptionNameLabel: UITextView = {
        let textView = UITextView()
    
        //  label.adjustsFontSizeToFitWidth = true
        textView.sizeToFit()
        textView.font = .systemFont(ofSize: 14, weight: .ultraLight)
        return textView
    }()
    
    private let dateLabel: UITextView = {
        let textView = UITextView()
        //lable.numberOfLines = 1
        textView.font = .systemFont(ofSize: 12, weight: .ultraLight)
        textView.textAlignment = .right
        return textView
    }()
    
    private let statusSwitch: UISwitch = {
        let mySwitch = UISwitch()
        mySwitch.isOn = false
        return mySwitch
    }()
    
    private let saveButton: UIButton = {
            let bt = UIButton()
            bt.setTitle("Сохранить", for: .normal)
            bt.titleLabel?.font = .systemFont(ofSize: 12.0, weight: .light)
            bt.layer.masksToBounds = true
            bt.layer.cornerRadius = 12
            bt.layer.borderWidth = 2.0
            bt.backgroundColor = .secondarySystemBackground
            bt.setTitleColor(.label, for: .normal)
            return bt
        }()


        override init(frame: CGRect) {
            super.init(frame: frame)
            setupView()
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        private func setupView() {
            backgroundColor = .systemBackground
            addSubview(titleNameLabel)
            addSubview(descriptionNameLabel)
            addSubview(dateLabel)
            addSubview(statusSwitch)
            addSubview(saveButton)
        }
        
        func configureView(sourceData: NewsTableViewCellModel){
            titleNameLabel.text = sourceData.titleName
            descriptionNameLabel.text = sourceData.descriptionName
            dateLabel.text = sourceData.dateString
            statusSwitch.isOn = sourceData.statusSwitch
        }
        
        override func layoutSubviews() {
            super.layoutSubviews()
           
            titleNameLabel.frame = CGRect(
                x: 5,
                y: 0,
                width: frame.width * 0.5,
                height: frame.height * 0.3)
            
            descriptionNameLabel.frame = CGRect(
                x: 5,
                y: titleNameLabel.frame.maxY,
                width: frame.width * 0.8,
                height: frame.height * 0.7)
            
            dateLabel.frame = CGRect(
                x: titleNameLabel.frame.maxX + 5,
                y: 0,
                width: frame.width * 0.5 - 10,
                height: frame.height * 0.3)
            
            statusSwitch.frame = CGRect(origin: CGPoint(x: frame.width * 0.85, y: titleNameLabel.frame.maxY), size: .zero)
           
            dateLabel.frame = CGRect(
                x:  5,
                y: frame.width * 0.80,
                width: 34,
                height: 34)
        
    }
}
