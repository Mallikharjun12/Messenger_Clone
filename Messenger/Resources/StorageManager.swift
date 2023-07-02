//
//  StorageManager.swift
//  Messenger
//
//  Created by Mallikharjun kakarla on 02/07/23.
//

import Foundation
import FirebaseStorage

final class StorageManager {
    
    static let shared = StorageManager()
    
    private let storage = Storage.storage().reference()
    
    public typealias uploadPictureCompletion = (Result<String,Error>) -> Void
    
    ///uploads picture to Firebase Storage and returns completion with urlString to download
    public func uploadProfilePicture(with data:Data, fileName:String, completion:@escaping uploadPictureCompletion) {
        storage.child("images/\(fileName)").putData(data, metadata: nil) { metaData, error in
            guard error == nil else {
                print("Failed to upload data to firebase for picture")
                completion(.failure(StorageErrors.failedToUpload))
                return
            }
        }
        storage.child("images/\(fileName)").downloadURL { url, error in
            guard let url = url else {
                print("Failed to get download url")
                completion(.failure(StorageErrors.failedToGetDownloadUrl))
                return
            }
            
            let urlString = url.absoluteString
            print("download url returned: \(urlString)")
            completion(.success(urlString))
        }
    }
}

enum StorageErrors:Error {
    case failedToUpload
    case failedToGetDownloadUrl
}
