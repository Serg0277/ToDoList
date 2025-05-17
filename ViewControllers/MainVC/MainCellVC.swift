//
//  MainCellVC.swift
//  ToDo List
//
//  Created by  Сергей on 12.05.2025.
// Ячейка для таблицы отображает все задачи 

import UIKit

struct ToDoListModel {
    var id : String
    var nameTitle: String
    var descriptionName: String
    var dateString : Date
    var statusSwitch : Bool
}

final class MainCellVC: UITableViewCell {
    
    private let manager = CoreManager.shared
    
    static let identifier = "cell"
    
    private let titleNameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .semibold)
        return label
    }()
    
    private let descriptionNameLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.sizeToFit()
        label.font = .systemFont(ofSize: 14, weight: .ultraLight)
        return label
    }()
    
    private let dateLabel: UILabel = {
        let label = UILabel()
        //lable.numberOfLines = 1
        label.font = .systemFont(ofSize: 12, weight: .ultraLight)
        label.textAlignment = .right
        return label
    }()
    
    private let statusSwitch: UISwitch = {
        let mySwitch = UISwitch()
        mySwitch.isOn = false
        mySwitch.isEnabled = false
        return mySwitch
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        contentView.addSubview(titleNameLabel)
        contentView.addSubview(descriptionNameLabel)
        contentView.addSubview(dateLabel)
        contentView.addSubview(statusSwitch)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //это обновление ячейки
    override func prepareForReuse() {
        super.prepareForReuse()
        titleNameLabel.text = nil
        descriptionNameLabel.text = nil
        dateLabel.text = nil
    }
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        titleNameLabel.frame = CGRect(
            x: 5,
            y: 0,
            width: contentView.frame.width * 0.5,
            height: contentView.frame.height * 0.3)
        
        descriptionNameLabel.frame = CGRect(
            x: 5,
            y: titleNameLabel.frame.maxY,
            width: contentView.frame.width * 0.8,
            height: contentView.frame.height * 0.7)
        
        dateLabel.frame = CGRect(
            x: titleNameLabel.frame.maxX + 5,
            y: 0,
            width: contentView.frame.width * 0.5 - 10,
            height: contentView.frame.height * 0.3)
        
        statusSwitch.frame = CGRect(origin: CGPoint(x: contentView.frame.width * 0.85, y: titleNameLabel.frame.maxY), size: .zero)
    }
    
    // MARK: - configure cell
    public func configureCell(with model: ToDo){
        
        self.titleNameLabel.text = model.nameTitle
        self.descriptionNameLabel.text = model.descriptionName
        if let date = model.dateString {
            self.dateLabel.text =  DateFormatter.dayFormatter.string(from: date)
        }
        self.statusSwitch.isOn = model.statusSwitch
    }
    
    
}
