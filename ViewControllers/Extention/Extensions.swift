//
//  Extensions.swift
//  ToDoList
//
//  Created by  Сергей on 15.05.2025.
//

import Foundation
import UIKit

class Alert {
    
    static let shared = Alert()
    
    static let dayFormatter: DateFormatter = {
            let formatter = DateFormatter ()
      //  formatter.dateFormat = "YYYY-MM-dd"
        formatter.dateStyle = .medium
            formatter.timeZone = .current
            formatter.locale = .current
           return formatter
        }()

    // функция срабатывает когда возникает ошибка
    public func alertUserError () -> UIAlertController {
        /// функция срабатывает когда возникает ошибка регистрации
        let alert = UIAlertController(title: "Woops",
                                      message: "Что то пошло не так! ",
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Отменить",
                                      style: .cancel,
                                      handler: nil))
        return alert
  
    }
    /// функция срабатывает когда возникает ошибка заполнения полей
    public func alertUserFieldsError () -> UIAlertController{
        let alert = UIAlertController(title: "Woops",
                                      message: "Введите корректную информацию! ", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Отменить", style: .cancel, handler: nil))
        return alert
    }
}

extension UIView {
    
    public var width: CGFloat {
        return self.frame.size.width
    }
    public var height: CGFloat {
        return frame.size.height
    }
    public var top: CGFloat {
        return frame.origin.y
    }
    public var bottom: CGFloat {
        return frame.size.height + frame.origin.y
    }
    public var left: CGFloat {
        return frame.origin.x
    }
    public var right: CGFloat {
        return frame.maxX //height + frame.origin.x
    }
    public func centerX(sizeWidthItem: CGFloat) -> CGFloat {
        ///sizeWidthItem это ширина элемента
        return (frame.size.width - sizeWidthItem) / 2
    }
    public func centerY(sizeHeightItem: CGFloat) -> CGFloat {
        ///sizeWidthItem это ширина элемента
        return (frame.size.height - sizeHeightItem) / 2
    }
}

