//
//  dummyModel.swift
//  Messenger
//
//  Created by Mallikharjun kakarla on 25/06/23.
//

import Foundation

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
