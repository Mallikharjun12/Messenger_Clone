//
//  DatabaseManager.swift
//  Messenger
//
//  Created by Mallikharjun kakarla on 25/06/23.
//

import Foundation
import FirebaseDatabase

final class DatabaseManager {
    
    static let shared = DatabaseManager()
    
    private let database = Database.database().reference()
    
    static func safeEmail(emailAddress:String) -> String {
        let safeEmail = emailAddress.replacingOccurrences(of: ".", with: "_")
        return safeEmail.replacingOccurrences(of: "@", with: "_")
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


enum DatabaseError:Error {
    case failedToFetch
}

struct ChatAppUser {
    let firstName:String
    let lastName:String
    let emailAddress:String
    
    var safeEmail:String {
        let safeEmail = emailAddress.replacingOccurrences(of: ".", with: "_")
        return safeEmail.replacingOccurrences(of: "@", with: "_")
    }
 //   let profilePictureUrl:String
    var profilePictureFileName:String {
        return "\(safeEmail)_profile_picture.png"
    }
}

/*
   users => [
 
                 [
                 "name":
                 "safe_email"
                 ],
                 
                 [
                 "name":
                 "safe_email"
                 ]
 
            ]
 
 */
