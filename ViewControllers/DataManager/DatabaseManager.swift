
//  DatabaseManager.swift
//  iMess
//  Created by  Сергей on 24.08.2023.


import Foundation
import UIKit
import FirebaseDatabase
import MessageKit
import CoreLocation

final class DatabaseManager {
    
    //MARK: - раздел объявления переменных и констант
    
    private var users = [ChatAppUser]()
    /// этот массив куда загоняют всех пользователей базы Users
    private var hasFetched = false
    ///сторожок для массива users чтобы не отправлять  лишний раз запрос к базе
    static let shared = DatabaseManager()
    private let database = Database.database().reference()
    
    //статическую функцию можно вызвать напрямую в любом контроллере
    public static func safeEmail(email: String) -> String {
        ///функция безопасный email
        let safeEmail = email.replacingOccurrences(of: ".", with: "_")
        return safeEmail
    }
    
    public static let dateFormatter: DateFormatter = { //форматирование даты и ее настройка статик так как жрет много памяти если другое сделать
        let fd = DateFormatter()
        fd.dateStyle = .medium // средний формат даты
        fd.timeStyle = .long //длинный формат времени
        fd.locale = .current // часовой пояс
        return fd
    }()
    
    deinit {
        print("Класс DatabaseManager закончил свое существование!")
    }
}

//MARK: - раздел  проверки пользователей при входе а также загрука первоначальных данных о пользователе

extension DatabaseManager {
    /// функция проверки есть такой пользователь перед добавлением нового пользователя
    public func userExists(with email: String, completion:@escaping ((Bool) -> Void)) {
        
        let sefeEmail = DatabaseManager.safeEmail(email: email)
        //Проверяем по основной базе
        database.child(sefeEmail).observeSingleEvent(of: .value, with: { snapshot in
            guard ((snapshot.value as? [String:Any]) == nil) else{ // если не пустое значит такой пользователь есть
                completion(false) // если база не пустая значит такой уже есть
                return
            }
            completion(true) // если пустой массив значить такого пользователянет и можно дальше работать
        })
    }
}

extension DatabaseManager {
    //функция вызывается в контроллере LoginViewController
    public func getDataFor(emailString:String, completion: @escaping(Result<String, Error>) -> Void){
        ///функция получения имени пользователя при загрузке приложения из базы Users
        self.database.child("users").observeSingleEvent(of: .value, with: { snapshot in
            
            guard let baseUsers = snapshot.value as? [[String:Any]] else {
                completion(.failure(DatabaseError.failedToFetch))
                return
            }
            // сдесь проработать когда в основной базе есть пользователь а в users нет
            for value in baseUsers {
                if emailString == value["email"] as! String {
                    let fullName = value["fullName"] as! String
                    completion(.success(fullName))
                    break
                }
            }
        })
    }
    ///функция поиска и сортировки пользователей для общения /observeSingleEvent  это наблюдатель получает данные из базы один раз/ пишут что вместо него чаще используют просто observe/ в нашем случае пойдет этот метод так как база users обновляется при добалении нового пользователя в основную базу данных
    public func getAllUsers(completion: @escaping (Result<[ChatAppUser]?, Error>)-> Void){
        if hasFetched == false {
            //флажок hasFetched означет что массив users еще пустой
            self.database.child("users").observeSingleEvent(of: .value, with: { [weak self] snapshot in
                guard let value = snapshot.value as? [[String:String]] else { // получаем записи из базы данных кастим их
                    completion(.failure(DatabaseError.failedToFetch)) // проверка на ошибку
                    return
                }
                let allUsers: [ChatAppUser] = value.compactMap { result in
                    guard  let email = result["email"],
                           let firstName = result["firstName"],
                           let fullName = result["fullName"],
                           let lastName = result["lastName"],
                           let url = result["urlAvatar"]
                    else {
                        return nil
                    }
                    return ChatAppUser(email: email, firstName: firstName, fullName: fullName, lastName: lastName, urlAvatar: url)
                }
                self?.users.append(contentsOf: allUsers)
                self?.hasFetched = true
                completion(.success(self?.users)) // возвращаем массив данных
            })
        }else{
            //флажок hasFetched означет что массив users не пустой
            completion(.success(self.users))
        }
    }
    
    public func insertNewUserInBaseUsers(user :ChatAppUser, completion: @escaping(Bool) -> Void){
        /// функция добавления нового пользователя в базу Users
        let emailString = DatabaseManager.safeEmail(email: user.email)
        let newUser = ["firstName": user.firstName, "lastName": user.lastName, "fullName": user.fullName, "email": emailString, "urlAvatar": user.urlAvatar]
        //Block add new User
        //add base User
        database.child(emailString).setValue(newUser) { [weak self] err, _ in
            guard err == nil else {
                completion(false)
                return
            }
            //add base allUsers
            self?.database.child("users").observeSingleEvent(of: .value) { snapshot in
                
                if var collectionUsers = snapshot.value as? [[String:String]] {
                    collectionUsers.append(newUser)
                    
                    self?.database.child("users").setValue(collectionUsers) { err, _ in
                        
                        guard err == nil else {
                            completion(false)
                            return
                        }
                        completion (true)
                    }
                }else{
                    //эта чать выполняется один раз при первом зарегистрированном пользователе
                    self?.database.child("users").setValue([newUser]) { err, _ in
                        
                        guard err == nil else {
                            completion(false)
                            return
                        }
                        completion (true)
                    }
                    
                }
                
            }
        }
    }
}

//MARK: -  раздел работы с сообщениями (добавление/удаление)
extension DatabaseManager {
    
    public func createAndNewMessageInNewChat(otherEmail: String, otherFullName: String, newMessage: Message, completion: @escaping(Result< String, Error>)-> Void){
        ///функция создания нового  сообщения в новом чате
        guard  let email = UserDefaults.standard.string(forKey: "email"),
               let userFullName = UserDefaults.standard.string(forKey: "fullName") else {
            return
        }
        let chatID = DatabaseManager.safeEmail(email: email) + "_" + otherEmail
        let userEmail = DatabaseManager.safeEmail(email: email)
        let dateString = DatabaseManager.dateFormatter.string(from: Date())
        
        var messageString = ""
        switch newMessage.kind {
        case .text(let text):
            messageString = text
        case .attributedText(_):
            break
        case  .photo( let mediaItem):
            if let targetUrlString = mediaItem.url?.absoluteString {
                messageString = targetUrlString
            }
            break
        case .video(let mediaItem):
            if let targetUrlString = mediaItem.url?.absoluteString {
                messageString = targetUrlString
            }
            break
        case .location( let locationData):
            let location = locationData.location
            messageString = "\(location.coordinate.longitude),\(location.coordinate.latitude)"
            break
            
        case .emoji(_):
            break
        case .audio(_):
            break
        case .contact(_):
            break
        case .linkPreview(_):
            break
        case .custom(_):
            break
        }
        
        let message: [String: Any] = ["messageId": newMessage.messageId,
                                      "date": dateString,
                                      "contentType": newMessage.kind.messageKindString,
                                      "contentString": messageString,
                                      "senderId":userEmail,
                                      "senderName":userFullName,
                                      "isRead": false]
        
        let newChat: [String: Any]  = ["chatId": chatID,
                                       "userFullName": userFullName,
                                       "userEmail": userEmail,
                                       "otherUserFullName": otherFullName,
                                       "otherUserEmail": otherEmail,
                                       "messages": [message]]
        
        
        
        
        database.child("Chats").child(chatID).setValue(newChat) {[weak self] err, _ in
            guard err == nil else {
                print("Ошибка записи нового сообщения в базу данных \(String(describing: err?.localizedDescription))")
                completion (.failure(DatabaseError.failedToChatMessage))
                return
            }
            
            //функция добавления последнего сообщения
            self?.createLastMessage(id: chatID,
                                    otherFullName: otherFullName,
                                    otherEmail: otherEmail,
                                    lastMessage: message) { result in
                if !result {
                    print("func createLastMessage error in str 278!")
                    completion(.failure(DatabaseError.failedToChatMessage))
                }
            }
            
            completion (.success(chatID))
        }
        
    }
    
    public func addMessageInChat(chatId: String, otherEmail: String, otherName: String, newMessage: Message, completion:  @escaping(Bool)-> Void){
        ///функция добавления сообщения в уже имеющийся чат
        database.child("Chats").child(chatId).observeSingleEvent(of: .value) { [weak self] valueBase,_  in
            guard var allChatsUser = valueBase.value as? [String:Any] else {
                return
            }
            
            let chatID = chatId
            let dateString = DatabaseManager.dateFormatter.string(from: Date())
            var messageString = ""
            
            switch newMessage.kind {
            case .text(let text):
                messageString = text
            case .attributedText(_):
                break
            case  .photo(let mediaItem):
                if let targetUrlString = mediaItem.url?.absoluteString {
                    messageString = targetUrlString
                }
                break
            case .video(let mediaItem):
                if let targetUrlString = mediaItem.url?.absoluteString {
                    messageString = targetUrlString
                }
                break
            case .location( let locationData):
                let location = locationData.location
                messageString = "\(location.coordinate.longitude),\(location.coordinate.latitude)"
                break
            case .emoji(_):
                break
            case .audio(_):
                break
            case .contact(_):
                break
            case .linkPreview(_):
                break
            case .custom(_):
                break
            }
            
            let newMessage: [String: Any] = ["messageId": newMessage.messageId,
                                             "date": dateString,
                                             "contentType": newMessage.kind.messageKindString,
                                             "contentString": messageString,
                                             "senderId":newMessage.sender.senderId,
                                             "senderName":newMessage.sender.displayName,
                                             "isRead": false]
            
            guard  var message = allChatsUser["messages"] as? [[String: Any]] else {
                return
            }
            
            message.append(newMessage)
            allChatsUser["messages"] = message
            
            self?.database.child("Chats").child(chatID).setValue(allChatsUser) { [weak self] err, _ in
                guard err == nil else {
                    print("Ошибка записи нового сообщения в базу данных \(String(describing: err?.localizedDescription))")
                    completion(false)
                    return
                }
                //функция добавления последнего сообщения
                self?.createLastMessage(id: chatID, otherFullName: otherName, otherEmail: otherEmail, lastMessage: newMessage) { result in
                    if !result {
                        print("func createLastMessage error in str 278!")
                        completion(false)
                    }
                }
                completion(true)
            }
        }
    }
    
    private func createLastMessage(id: String ,otherFullName: String, otherEmail: String, lastMessage: [String: Any], completion:  @escaping(Bool)-> Void) {
        ///функция добавления последнего сообщения самого свежего в базу пользователя и базу аппонента чтоб потом у них отображалось последенен сообшение в основном эране сообщений
        guard let email = UserDefaults.standard.string(forKey: "email") ,
              let userFullName = UserDefaults.standard.string(forKey: "fullName") else {
            return
        }
        let userEmail = DatabaseManager.safeEmail(email: email)
        //записываем себе
        let ourLastMessage: [String: Any] = [ "otherFullName" : otherFullName,
                                              "otherUserEmail" : otherEmail,
                                              "idConversation" : id,
                                              "lastMessage":  lastMessage]
        
        database.child(userEmail).child("Conversations").child(id).setValue(ourLastMessage) { error, _ in
            if error != nil {
                print("In func createLastMessage Error str 319!")
                completion (false)
            }
            completion (true)
        }
        
        //тоже самое сохраняем второму пользователю только переворачиваем имена наоборот
        
        let otherLastMessage: [String: Any] = [ "otherFullName" : userFullName,
                                                "otherUserEmail" : userEmail,
                                                "idConversation" : id,
                                                "lastMessage": lastMessage
        ]
        database.child(otherEmail).child("Conversations").child(id).setValue(otherLastMessage) { error, _ in
            if error != nil {
                print("In func createLastMessage Error str 336!")
                completion (false)
            }
            completion (true)
        }
    }
    
    public func isThereChat(ourEmail: String , otherEmail: String, completion:  @escaping(Result<String, Error>)-> Void) {
        ///функция проверки имеются ли у пользователя чаты с выбранным пользоавтелем при положительном ответе возвращаем id чата и дальше контроллер уже передает этот id чтобы понимать создавать новый чат или загружать имеющийся и добавлять в него
        
        database.child(ourEmail).child("Conversations").observeSingleEvent(of: .value, with: { snapshot  in
            
            guard let allConversations = snapshot.value as? NSDictionary  else {
                print("У  пользователя \(ourEmail) вообще нет разговоров!")
                completion(.failure(DatabaseError.failedToChatMessage))
                return
            }
            
            for value in allConversations.allValues {
                guard let dic = value as? NSDictionary,
                      let name = dic.value(forKey: "otherUserEmail") as? String else {
                    return
                }
                //условие совпадение выбраного пользователя с наличием в базе разговоров
                if otherEmail == name {
                    guard  let id = dic.value(forKey: "idConversation") as? String else {
                        return
                    }
                    completion(.success(id))
                    return
                }
            }
            print("У  пользователя \(ourEmail)  нет разговоров c пользователем \(otherEmail) !")
            completion(.failure(DatabaseError.failedToChatMessage))
        })
    }
    //удаление разговора из базы данных
    public func deleteConversation(chatId:String,completion: @escaping (Bool)-> Void){
        guard let email = UserDefaults.standard.string(forKey: "email") else {
            return
        }
        let userEmail = DatabaseManager.safeEmail(email: email)
        
        database.child(userEmail).child("Conversations").child(chatId).child("lastMessage").removeValue(completionBlock: { error, _ in
            if error != nil{
                print("Ошибка удаления данных из базы! - \(String(describing: error))")
                completion(false)
            }else{
                completion(true)
            }
        })
    }
    //MARK: - раздел работы с загрузкой из базы сообщений и чатов
    public func getAllMessageFromChat(chatId: String, completion: @escaping (Result<[Message], Error>)-> Void){
        ///func загрузка всех сообщений из выбранного чата
        database.child("Chats").child(chatId).observe( .value, with: { valueBase in
            print("\(chatId)")
            guard let valueString = valueBase.value as? NSDictionary else {
                print("Загрузка имеющихся разговоров невозможна! ")
                completion(.failure(DatabaseError.failedToLoadMessage))
                return
            }
            var valueData =  [Message]()
            //так не пойдет надо переделать убрать все отсюда в отдельную модель
            for result in [valueString] {
                guard  let messag = result["messages"] as? [[String: Any]] else {
                    return
                }
                for messages in messag {
                    guard
                        let senderId = messages["senderId"] as? String,
                        let displayName = messages["senderName"] as? String,
                        let messageId = messages["messageId"] as? String,
                        let dateString = messages["date"] as? String,
                        let correctDate = DatabaseManager.dateFormatter.date(from: dateString),
                        let kindType = messages["contentType"] as? String,
                        let kindString = messages["contentString"] as? String else {
                        return
                    }
                    var kind : MessageKind
                    if kindType == "photo" {
                        guard let imageurl = URL(string: kindString),
                              let placeholder = UIImage(systemName: "plus") else {
                            return
                        }
                        // photo
                        let media = Media(url: imageurl, image: nil, placeholderImage: placeholder, size: CGSize(width: 200, height: 200))
                        kind = .photo(media)
                        //location coordonates
                    }
                    else if kindType == "location" {
                        let locationComponents = kindString.components(separatedBy: ",") //како то разделитель
                        // короче так кастить не стоит guard  let longitude = locationComponents[0] as? Double, let latitude = locationComponents[1] as? Double else {
                        guard let longitude = Double(locationComponents[0]),
                              let latitude = Double(locationComponents[1]) else {
                            return
                        }
                        print ("Широта=\(latitude)| Долгота=\(longitude) ")
                        let location = Location(location: CLLocation(latitude: latitude, longitude: longitude), size: CGSize(width: 200, height: 200))
                        kind = .location(location)
                        //video
                    }else if kindType == "video" {
                        guard let videoUrl = URL(string: kindString),
                              let placeholder = UIImage(systemName: "plus") else { // заполнитель показывает чтото вместо контента
                            return
                        }
                        let media = Media(url: videoUrl, image: nil, placeholderImage: placeholder, size: CGSize(width: 200, height: 200))
                        kind = .video(media)
                        //текст
                    }else{
                        kind = .text(kindString)
                    }
                    valueData.append(Message(sender: Sender(senderId: senderId, displayName: displayName), messageId: messageId, sentDate: correctDate, kind: kind))
                    
                }
            }
            completion(.success(valueData))
        })
        
    }
    
    ///загрузка всех  чатов для вошедшего пользователя
    public func getAllChatsForUser(userEmail: String, completion: @escaping (Result<[infoModel], Error>)-> Void){
        database.child(userEmail).child("Conversations").observe( .value) {snapshot  in
            print("\(userEmail)")
            guard let conversations = snapshot.value as? NSDictionary else{
                completion(.failure(DatabaseError.failedToChatMessage))
                return
            }
            var infoArrey = [infoModel]()
            
            for value in conversations.allValues {
                guard let valueDict = value as? NSDictionary else {
                    return
                }
                if let infoItem  = infoModel(dict: valueDict) {
                    infoArrey.append(infoItem)
                }
            }
            completion(.success(infoArrey))
        }
    }
    
    
}//это последняя скобка расширения
