import Foundation
import FirebaseDatabase
import MessageKit

enum DatabaseError: Error {
    case failedToFetch
}

final class DatabaseManager {
    
    private lazy var dateFormatter: DateFormatter = {
        let formattre = DateFormatter()
        formattre.dateStyle = .medium
        formattre.timeStyle = .long
        formattre.locale = .current
        return formattre
    }()
    
    static let shared = DatabaseManager()
    
    private let database = Database.database().reference()
}

// MARK: - Data
extension DatabaseManager {
    
    func getDataFor(path: String, completion: @escaping(Result<Any, Error>) -> Void) {
        database.child("\(path)").observeSingleEvent(of: .value) { snapshot in
            guard let value = snapshot.value else {
                completion(.failure(DatabaseError.failedToFetch))
                return
            }
            completion(.success(value))
        }
    }
}

// MARK: - Users
extension DatabaseManager {
    
    func checkUserExists(email: String, completion: @escaping (Bool) -> Void) {
        let safeEmail = email.safeEmail
        
        database.child(safeEmail).observeSingleEvent(of: .value) { snapshot in
            guard snapshot.value as? [String: Any] != nil else {
                completion(false)
                return
            }
            completion(true)
        }
    }
    
    func insertUser(with user: User, completion: @escaping (Bool) -> Void) {
        database.child(user.safeEmail).setValue(["first_name": user.firstName]) { error, _ in
            guard error == nil else {
                print("failed ot write to database")
                completion(false)
                return
            }
            
            self.database.child("users").observeSingleEvent(of: .value) { snapshot in
                if var userCollection = snapshot.value as? [[String: String]] {
                    let newElement = [
                        "name": user.firstName,
                        "email": user.safeEmail
                    ]
                    userCollection.append(newElement)
                    
                    self.database.child("users").setValue(userCollection) { error, _ in
                        guard error == nil else {
                            completion(false)
                            return
                        }
                        completion(true)
                    }
                } else {
                    let newCollection: [[String: String]] = [
                        [
                            "name": user.firstName,
                            "email": user.safeEmail
                        ]
                    ]
                    self.database.child("users").setValue(newCollection) { error, _ in
                        guard error == nil else {
                            completion(false)
                            return
                        }
                        completion(true)
                    }
                }
            }
        }
    }
    
    func getAllUsers(completion: @escaping (Result<[[String: String]], Error>) -> Void) {
        database.child("users").observeSingleEvent(of: .value) { snapshot in
            guard let value = snapshot.value as? [[String: String]] else {
                completion(.failure(DatabaseError.failedToFetch))
                return
            }
            completion(.success(value))
        }
    }
}

// MARK: - Conversations
extension DatabaseManager {

    func createNewConversation(
        with otherUserEmail: String,
        name: String,
        firstMessage: Message,
        completion: @escaping (Bool) -> Void
    ) {
        guard let currentEmail = UserDefaults.standard.value(forKey: "email") as? String,
              let currentName = UserDefaults.standard.value(forKey: "name") as? String
        else {
            return
        }
         
        let safeEmail = currentEmail.safeEmail
        let reference = database.child("\(safeEmail)")
        
        reference.observeSingleEvent(of: .value) { [weak self] snapshot in
            guard let self = self else { return }
            
            guard var userNode = snapshot.value as? [String: Any] else {
                completion(false)
                print("user not found")
                return
            }
            
            let messageDate = firstMessage.sentDate
            let dateString = self.dateFormatter.string(from: messageDate)
            
            var message = ""
            
            switch firstMessage.kind {
            case .text(let messageText):
                message = messageText
            default:
                break
            }
            
            let conversationId = "conversation_\(firstMessage.messageId)"
            
            let newConversationData: [String: Any] = [
                "id": conversationId,
                "other_user_email": otherUserEmail,
                "name": name,
                "latest_message": [
                    "date": dateString,
                    "message": message,
                    "is_read": false
                ]
            ]
            
            let recipient_newConversationData: [String: Any] = [
                "id": conversationId,
                "other_user_email": safeEmail,
                "name": currentName,
                "latest_message": [
                    "date": dateString,
                    "message": message,
                    "is_read": false
                ]
            ]
            
            self.database.child("\(otherUserEmail)/conversations").observeSingleEvent(of: .value) { snapshot in
                if var conversations = snapshot.value as? [[String: Any]] {
                    conversations.append(recipient_newConversationData)
                    self.database.child("\(otherUserEmail)/conversations").setValue(conversations)
                } else {
                    self.database.child("\(otherUserEmail)/conversations").setValue([recipient_newConversationData])
                }
                
            }
            
            if var conversations = userNode["conversations"] as? [[String: Any]] {
                conversations.append(newConversationData)
                userNode["conversations"] = conversations
                reference.setValue(userNode) { error, _ in
                    guard error == nil else {
                        completion(false)
                        return
                    }
                    self.finishCreatingConversation(
                        name: name,
                        conversationID: conversationId,
                        firstMessage: firstMessage,
                        completion: completion
                    )
                }
            } else {
                userNode["conversations"] = [
                    newConversationData
                ]

                reference.setValue(userNode, withCompletionBlock: { [weak self] error, _ in
                    guard error == nil else {
                        completion(false)
                        return
                    }

                    self?.finishCreatingConversation(
                        name: name,
                        conversationID: conversationId,
                        firstMessage: firstMessage,
                        completion: completion
                    )
                })
            }
        }
    }
    
    private func finishCreatingConversation(
        name: String,
        conversationID: String,
        firstMessage: Message,
        completion: @escaping (Bool) -> Void
    ) {
        let messageDate = firstMessage.sentDate
        let dateString = dateFormatter.string(from: messageDate)
        
        var message = ""
        
        switch firstMessage.kind {
        case .text(let messageText):
            message = messageText
        default:
            break
        }
        
        guard let myEmail = UserDefaults.standard.value(forKey: "email") as? String else  {
            completion(false)
            return
        }
        
        let currentUserEmail = myEmail.safeEmail
        
        let collectionMessage: [String: Any] = [
            "id": firstMessage.messageId,
            "type": firstMessage.kind.messageKindString,
            "content": message,
            "date": dateString,
            "sender_email": currentUserEmail,
            "is_read": false,
            "name": name
        ]
        
        let value: [String: Any] = [
            "messages": [
                collectionMessage
            ]
        ]
        
        database.child("\(conversationID)").setValue(value, withCompletionBlock: { error, _ in
            guard error == nil else {
                completion(false)
                return
            }
            completion(true)
        })
    }
    
    func getAllConversations(for email: String, completion: @escaping(Result<[Conversation], Error>) -> Void) {
        database.child("\(email)/conversations").observe(.value, with: { snapshot in
            guard let value = snapshot.value as? [[String: Any]] else {
                completion(.failure(DatabaseError.failedToFetch))
                return
            }
            
            let conversation: [Conversation] = value.compactMap({ dictionary in
                guard let conversationId = dictionary["id"] as? String,
                      let name = dictionary["name"] as? String,
                      let otherUserEmail = dictionary["other_user_email"] as? String,
                      let latestMessage = dictionary["latest_message"] as? [String: Any],
                      let date = latestMessage["date"] as? String,
                      let message = latestMessage["message"] as? String,
                      let isRead = latestMessage["is_read"] as? Bool
                else {
                    return nil
                }
                
                let latestMessageObject = LatestMessage(date: date, text: message, isRead: isRead)
                
                return Conversation(id: conversationId,
                                    name: name,
                                    otherUserEmail: otherUserEmail,
                                    latestMessage: latestMessageObject)
            })
            
            completion(.success(conversation))
        })
    }
    
    func getAllMessagesForConversation(
        with id: String,
        completion: @escaping(Result<[Message], Error>) -> Void
    ) {
        database.child("\(id)/messages").observe(.value) { [weak self] snapshot in
            guard let self = self else { return }
            
            guard let value = snapshot.value as? [[String: Any]] else {
                completion(.failure(DatabaseError.failedToFetch))
                return
            }
            
            let messages = MessageConverter.messages(from: value, dateFormatter: self.dateFormatter)

            completion(.success(messages))
        }
    }
    
    func sendMessage(
        to conversation: String,
        otherUserEmail: String,
        name: String,
        newMessage: Message,
        completion: @escaping (Bool) -> Void
    ) {
        guard let myEmail = UserDefaults.standard.value(forKey: "email") as? String else {
            completion(false)
            return
        }
        
        let currentEmail = myEmail.safeEmail

        database.child("\(conversation)/messages").observeSingleEvent(of: .value) { [weak self] snapshot, _ in
            guard let self = self else { return }
            
            guard var currentMessages = snapshot.value as? [[String: Any]] else {
                completion(false)
                return
            }
            
            let messageDate = newMessage.sentDate
            let dateString = self.dateFormatter.string(from: messageDate)
            
            var message = ""
            
            switch newMessage.kind {
            case .text(let messageText):
                message = messageText
            case .photo(let mediaItem):
                if let targerUrlString = mediaItem.url?.absoluteString {
                    message = targerUrlString
                }
            case .video(let mediaItem):
                if let targerUrlString = mediaItem.url?.absoluteString {
                    message = targerUrlString
                }
            default:
                break
            }
            
            guard let myEmail = UserDefaults.standard.value(forKey: "email") as? String else  {
                completion(false)
                return
            }
            
            let currentUserEmail = myEmail.safeEmail
            
            let newMessageEnrty: [String: Any] = [
                "id": newMessage.messageId,
                "type": newMessage.kind.messageKindString,
                "content": message,
                "date": dateString,
                "sender_email": currentUserEmail,
                "is_read": false,
                "name": name
            ]
            
            currentMessages.append(newMessageEnrty)
            
            self.database.child("\(conversation)/messages").setValue(currentMessages) { error, _ in
                guard error == nil else {
                    completion(false)
                    return
                }
                
                self.database.child("\(currentEmail)/conversations").observeSingleEvent(of: .value) { snapshot, _ in
                    guard var currentUserConversations = snapshot.value as? [[String: Any]] else {
                        completion(false)
                        return
                    }
                    
                    let updateValue: [String: Any] = [
                        "date": dateString,
                        "is_read": false,
                        "message": message
                    ]
                    
                    var targetConversation: [String: Any]?
                    var position = 0
                    
                    for conversationItem in currentUserConversations {
                        if let currentId = conversationItem["id"] as? String, currentId == conversation {
                            targetConversation = conversationItem
                            break
                        }
                        position += 1
                    }
                    targetConversation?["latest_message"] = updateValue
                    guard let finalConversation = targetConversation else {
                        completion(false)
                        return
                    }
                    currentUserConversations[position] = finalConversation
                    self.database.child("\(currentEmail)/conversations").setValue(currentUserConversations) { error, _ in
                        guard error == nil else {
                            completion(false)
                            return
                        }
                        
                        self.database.child("\(otherUserEmail)/conversations").observeSingleEvent(of: .value) { snapshot, _  in
                            guard var otherUserConversations = snapshot.value as? [[String: Any]] else {
                                completion(false)
                                return
                            }
                            
                            let updateValue: [String: Any] = [
                                "date": dateString,
                                "is_read": false,
                                "message": message
                            ]
                            
                            var targetConversation: [String: Any]?
                            var position = 0
                            
                            for conversationItem in otherUserConversations {
                                if let currentId = conversationItem["id"] as? String, currentId == conversation {
                                    targetConversation = conversationItem
                                    break
                                }
                                position += 1
                            }
                            targetConversation?["latest_message"] = updateValue
                            guard let finalConversation = targetConversation else {
                                completion(false)
                                return
                            }
                            otherUserConversations[position] = finalConversation
                            self.database.child("\(otherUserEmail)/conversations").setValue(otherUserConversations) { error, _ in
                                guard error == nil else {
                                    completion(false)
                                    return
                                }
                                
                                completion(true)
                            }
                        }
                    }
                }
            }
        }
    }
}
