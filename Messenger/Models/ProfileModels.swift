//
//  ProfileModels.swift
//  Messenger
//
//  Created by Mallikharjun kakarla on 16/07/23.
//

import Foundation

enum ProfileViewModelType {
    case info, logOut
}

struct ProfileViewModel {
    let viewModelType:ProfileViewModelType
    let title:String
    let handler: (() -> ())?
}
