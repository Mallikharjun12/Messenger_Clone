//
//  DatabaseManager.swift
//  Messenger
//
//  Created by Mallikharjun kakarla on 25/06/23.
//

import Foundation
import FirebaseDatabase

enum DatabaseError:Error {
    case failedToFetch
}


final class DatabaseManager {
    
    static let shared = DatabaseManager()
    
    private let database = Database.database().reference()
    
    static func safeEmail(emailAddress:String) -> String {
        let safeEmail = emailAddress.replacingOccurrences(of: ".", with: "_")
        return safeEmail.replacingOccurrences(of: "@", with: "_")
    }
}

extension DatabaseManager {
    
    public func getDataFor( path:String, completion: @escaping (Result<Any,Error>)->Void) {
        database.child(path).observeSingleEvent(of: .value) { snapShot in
            guard let value = snapShot.value else {
                completion(.failure(DatabaseError.failedToFetch))
                return
            }
            completion(.success(value))
        }
    }
}

//MARK: Account Managemnt
extension DatabaseManager {
    
    public func userexists(with email:String,completion:@escaping ((Bool)->Void)) {
        var safeEmail = email.replacingOccurrences(of: ".", with: "_")
        safeEmail = safeEmail.replacingOccurrences(of: "@", with: "_")
        database.child(safeEmail).observeSingleEvent(of: .value) { snapShot in
            if snapShot.exists() {
                print("User exists with email:\(safeEmail)")
                completion(true)
            } else {
                completion(false)
            }
        }
    }

    /// - inserts new user to database
    public func insertUser(with user:ChatAppUser,completion:@escaping (Bool)->Void) {
        database.child(user.safeEmail).setValue([
            "first_name":user.firstName,
            "last_name":user.lastName
        ]) { error, _ in
            guard error == nil else {
                print("Failed to write to database")
                completion(false)
                return
            }
            
            self.database.child("users").observeSingleEvent(of: .value) { snapShot in
                
                if var usersCollection = snapShot.value as? [[String:String]] {
                    //append to the usersCollection
                    usersCollection.append([
                        "name":user.firstName + " " + user.lastName,
                        "email":user.safeEmail
                       ])
                    self.database.child("users").setValue(usersCollection) { error, _ in
                        guard error == nil else {
                            completion(false)
                            return
                        }
                        completion(true)
                    }
                    
                } else {
                    // create the users collection and then append
                    
                    let newCollection:[[String:String]] = [
                       [
                        "name":user.firstName + " " + user.lastName,
                        "email":user.safeEmail
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
    
    public func getAllUsers(completion:@escaping (Result<[[String:String]],Error>)->Void) {
        database.child("users").observeSingleEvent(of: .value) { snapShot in
            guard let users = snapShot.value as? [[String:String]] else {
                completion(.failure(DatabaseError.failedToFetch))
                return
            }
            completion(.success(users))
        }
    }
}



/*
 
 users schema
   users => [
 
                 {
                 "name":
                 "safe_email"
                 },
                 
                 {
                 "name":
                 "safe_email"
                 }
 
            ]
 
 */

//MARK: Sending messages/conversations

extension DatabaseManager {
    
    /*
      
     conversations and messages schema
     
       "asdfg(conversation_id)":=> {
       
       "messages": [
            {
               "id":string,
                "type":text,photo.video,
                "content":string,
                "date":Date(),
                "sender_email":string,
                 "isRead":true/false
           }
        ]
     }
     
     
     
       conversations => [
     
                     {
                         "conversation_id": "asdfg"
                         "other_user_email":
                         "latest_message": => {
                                "date":Date(),
                                "latest_message":"message",
                                "is_read":true/false
                            }
                     }
     
                ]
     
     */
    
    
    
    
    /// Creates a new conversation with the target user and firstMessage sent
    public func createNewConversation(with otherUserEmail:String,
                                      name:String,
                                      firstMessage:Message,
                                      completion:@escaping (Bool)->Void) {
        guard let currentUserEmail = UserDefaults.standard.value(forKey: "email") as? String,
              let currentName = UserDefaults.standard.value(forKey: "name") as? String else {
            return
        }
        
        let safeEmail = DatabaseManager.safeEmail(emailAddress: currentUserEmail)
        let ref = database.child(safeEmail)
        
        ref.observeSingleEvent(of: .value) {[weak self] snapShot in
            guard var userNode = snapShot.value as? [String:Any] else {
                completion(false)
                print("user not found")
                return
            }
            
            let messageDate = firstMessage.sentDate
            let dateString = ChatViewController.dateFormatter.string(from: messageDate)
            
            var message = ""
            switch firstMessage.kind {
            case .text(let messageText):
                message = messageText
            case .attributedText(_):
                break
            case .photo(_):
                break
            case .video(_):
                break
            case .location(_):
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
            
            let conversationId = "conversation_\(firstMessage.messageId)"
            let newConversationData:[String:Any] = [
                "id":conversationId,
                "other_user_email": otherUserEmail,
                "name":name,
                "latest_message": [
                    "date":dateString,
                    "message":message,
                    "is_read":false
                ]
            ]
            
            // upadte recepients conversations list
            let recepient_newConversationData:[String:Any] = [
                "id":conversationId,
                "other_user_email": safeEmail,
                "name":currentName,
                "latest_message": [
                    "date":dateString,
                    "message":message,
                    "is_read":false
                ]
            ]
            
            self?.database.child("\(otherUserEmail)/conversations").observeSingleEvent(of: .value) {[weak self] snapShot in
                if var conversations = snapShot.value as? [[String:Any]] {
                    // conversation array exist for recepient
                    conversations.append(recepient_newConversationData)
                    self?.database.child("\(otherUserEmail)/conversations").setValue(conversations)
                } else {
                    //conversations array doesn't exist for recepient
                    self?.database.child("\(otherUserEmail)/conversations").setValue([recepient_newConversationData])
                }
            }
            
            //Update current user conversations list
            if var conversations = userNode["conversations"] as? [[String:Any]] {
                // conversations array exists for current user
                // should append newConversation
                
                conversations.append(newConversationData)
                userNode["conversations"] = conversations
                ref.setValue(userNode) { [weak self]error, _ in
                    guard error == nil else {
                        completion(false)
                        return
                    }
                    self?.finishCreatingConversation(name: name,
                                                     conversationId: conversationId,
                                                     firstMessage: firstMessage,
                                                     completion: completion)
                    
                }
                
            } else {
                // conversations array doesn't exist for current user
                //create a conversations array and them append newConversation
                userNode["conversations"] = [
                      newConversationData
                   ]
                ref.setValue(userNode) {[weak self] error, _ in
                    guard error == nil else {
                        completion(false)
                        return
                    }
                    self?.finishCreatingConversation(name: name,
                                                     conversationId: conversationId,
                                                     firstMessage: firstMessage,
                                                     completion: completion)
                }
            }
        }
    }
    
    private func finishCreatingConversation(name:String ,conversationId:String, firstMessage:Message, completion:@escaping (Bool)->Void) {
        
        let messageDate = firstMessage.sentDate
        let dateString = ChatViewController.dateFormatter.string(from: messageDate)
        
        var message = ""
        switch firstMessage.kind {
        case .text(let messageText):
            message = messageText
        case .attributedText(_):
            break
        case .photo(_):
            break
        case .video(_):
            break
        case .location(_):
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
        
        guard let myEmail = UserDefaults.standard.value(forKey: "email") as? String else {
            completion(false)
            return
        }
        
        let currentUserEmail = DatabaseManager.safeEmail(emailAddress: myEmail)
        
        let collectionMessage:[String:Any] = [
            "id":firstMessage.messageId,
            "type":firstMessage.kind.messageKindString,
            "content":message,
            "date":dateString,
            "sender_email":currentUserEmail,
            "is_read":false,
            "name":name
        ]
        
        let value:[String:Any] = [
            "messages":[
                collectionMessage
            ]
        ]
        
        database.child(conversationId).setValue(value) { error, _ in
            guard error == nil else {
                completion(false)
                return
            }
            completion(true)
        }
    }
    
    ///Fetches and returns all conversations for the user with passed email
    public func getAllConversations(for email:String,completion:@escaping (Result<[Conversation],Error>) -> Void) {
       
        database.child("\(email)").observe(.value) { snapShot in
            guard let userNode = snapShot.value as? [String:Any],
                  let value = userNode["conversations"] as? [[String:Any]] else {
                completion(.failure(DatabaseError.failedToFetch))
                return
            }
            
            let conversations:[Conversation] = value.compactMap({ dict in
                guard let conversationId = dict["id"] as? String,
                      let name = dict["name"] as? String,
                      let otherUserEmail = dict["other_user_email"] as? String,
                      let latestMessage = dict["latest_message"] as? [String:Any],
                      let date = latestMessage["date"] as? String,
                      let message = latestMessage["message"] as? String,
                      let isRead = latestMessage["is_read"] as? Bool else {
                    return nil
                }
                
                let latestMessageObject = LatestMessage(date: date, text: message, isRead: isRead)
                return Conversation(id: conversationId,
                                    name: name,
                                    otherUserEmail: otherUserEmail,
                                    latestMessage: latestMessageObject)
            })
            
            completion(.success(conversations))
        }
        
        
    }
    
    ///Fetches all messages for a given conversation
    public func getAllMessagesForConversation(with id:String,completion:@escaping (Result<[Message],Error>) -> Void) {
        
        database.child("\(id)/messages").observe(.value) { snapShot in
            guard let value = snapShot.value as? [[String:Any]] else {
                completion(.failure(DatabaseError.failedToFetch))
                return
            }
            let messages:[Message] = value.compactMap({ dict in
                guard let content = dict["content"] as? String,
                      let dateString = dict["date"] as? String,
                      let id = dict["id"] as? String,
                      let isRead = dict["is_read"] as? Bool,
                      let name = dict["name"] as? String,
                      let senderEmail = dict["sender_email"] as? String,
                      let type = dict["type"] as? String,
                      let date = ChatViewController.dateFormatter.date(from: dateString)  else {
                    return nil
                }
                
                let sender = Sender(photo: "",
                                    senderId: senderEmail,
                                    displayName: name)
                
                return Message(sender: sender,
                               messageId: id,
                               sentDate: date,
                               kind: .text(content))
            })
            
            completion(.success(messages))
        }
    }
    
    /// sends a message to an existing conversation
    public func sendMesage(to conversation:String, otherUserEmail:String, name:String, newMessage:Message, completion:@escaping (Bool)->Void) {
        
        guard let myEmail = UserDefaults.standard.value(forKey: "email") as? String else {
            completion(false)
            return
        }
        
        let currentUserEmail = DatabaseManager.safeEmail(emailAddress: myEmail)
        
        // update new message to messages
        database.child("\(conversation)/messages").observeSingleEvent(of: .value) {[weak self] snapShot in
            guard let self else {
                return
            }
            
            guard var currentMessages = snapShot.value as? [[String:Any]] else {
                completion(false)
                return
            }
            
            let messageDate = newMessage.sentDate
            let dateString = ChatViewController.dateFormatter.string(from: messageDate)
            
            var message = ""
            switch newMessage.kind {
            case .text(let messageText):
                message = messageText
            case .attributedText(_):
                break
            case .photo(_):
                break
            case .video(_):
                break
            case .location(_):
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
            
            guard let myEmail = UserDefaults.standard.value(forKey: "email") as? String else {
                completion(false)
                return
            }
            
            let currentUserEmail = DatabaseManager.safeEmail(emailAddress: myEmail)
            
            
            let newMessageEntry:[String:Any] = [
                "id":newMessage.messageId,
                "type":newMessage.kind.messageKindString,
                "content":message,
                "date":dateString,
                "sender_email":currentUserEmail,
                "is_read":false,
                "name":name
            ]
            
            currentMessages.append(newMessageEntry)
            self.database.child("\(conversation)/messages").setValue(currentMessages,withCompletionBlock: { error, _ in
                guard error == nil else {
                    completion(false)
                    return
                }
            
               // completion(true)
                // update sender latest message
                self.database.child("\(currentUserEmail)/conversations").observeSingleEvent(of: .value) { snapShot in
                    guard var currentUserConversations = snapShot.value as? [[String:Any]] else {
                        completion(false)
                        return
                    }

                    let updatedValue:[String:Any] = [
                        "date":dateString,
                        "is_read":false,
                        "message":message
                    ]

                    var index = 0
                    var targetConversation:[String:Any]?

                    for currentUserConversation in currentUserConversations {
                        if let currentId = currentUserConversation["id"] as? String, currentId == conversation {
                            targetConversation = currentUserConversation
                            break
                        }
                        index += 1
                    }
                    
                    targetConversation?["latest_message"] = updatedValue
                    guard let targetConversation = targetConversation else {
                        completion(false)
                        return
                    }
                    currentUserConversations[index] = targetConversation
                    self.database.child("\(currentUserEmail)/conversations").setValue(currentUserConversations) { error, _ in
                        guard error == nil else {
                            completion(false)
                            return
                        }

                         // update recepient latest message
                        self.database.child("\(otherUserEmail)/conversations").observeSingleEvent(of: .value) { snapShot in
                            guard var othertUserConversations = snapShot.value as? [[String:Any]] else {
                                completion(false)
                                return
                            }

                            let updatedValue:[String:Any] = [
                                "date":dateString,
                                "is_read":false,
                                "message":message
                            ]

                            var index = 0
                            var targetConversation:[String:Any]?

                            for othertUserConversation in othertUserConversations {
                                if let currentId = othertUserConversation["id"] as? String, currentId == conversation {
                                    targetConversation = othertUserConversation
                                    break
                                }
                                index += 1
                            }

                            targetConversation?["latest_message"] = updatedValue
                            guard let targetConversation = targetConversation else {
                                completion(false)
                                return
                            }
                            othertUserConversations[index] = targetConversation
                            self.database.child("\(otherUserEmail)/conversations").setValue(othertUserConversations) { error, _ in
                                guard error == nil else {
                                    completion(false)
                                    return
                                }
                                completion(true)
                            }
                        }

                    }
                }
                
                
            })
        }
    }
    
}
