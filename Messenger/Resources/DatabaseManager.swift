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
    public func insertUser(with user:ChatAppUser) {
        database.child(user.safeEmail).setValue([
            "firstName":user.firstName,
            "lastName":user.lastName
        ])
    }
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
}
