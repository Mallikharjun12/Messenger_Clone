//
//  StorageManager.swift
//  Messenger
//
//  Created by Mallikharjun kakarla on 02/07/23.
//

import Foundation
import FirebaseStorage

/// Allows user to fetch and upload files to firebase storage
final class StorageManager {
    
    static let shared = StorageManager()
    
    private init() {}
    
    private let storage = Storage.storage().reference()
    
    public typealias uploadPictureCompletion = (Result<String,Error>) -> Void
    
    ///uploads picture to Firebase Storage and returns completion with urlString to download
    public func uploadProfilePicture(with data:Data, fileName:String, completion:@escaping uploadPictureCompletion) {
        storage.child("images/\(fileName)").putData(data, metadata: nil) {[weak self] metaData, error in
            guard error == nil else {
                print("Failed to upload data to firebase for picture")
                completion(.failure(StorageErrors.failedToUpload))
                return
            }
            self?.storage.child("images/\(fileName)").downloadURL { url, error in
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
    
    ///uploads image that will be sent in a conversation message
    public func uploadPhotoMessage(with data:Data, fileName:String, completion:@escaping uploadPictureCompletion) {
        storage.child("message_images/\(fileName)").putData(data, metadata: nil) {[weak self] metaData, error in
            guard error == nil else {
                print("Failed to upload data to firebase for picture")
                completion(.failure(StorageErrors.failedToUpload))
                return
            }
            
            self?.storage.child("message_images/\(fileName)").downloadURL { url, error in
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
    
    ///uploads video that will be sent in a conversation message
    public func uploadVideoMessage(with fileUrl:URL, fileName:String, completion:@escaping uploadPictureCompletion) {
        storage.child("message_videos/\(fileName)").putFile(from:fileUrl, metadata: nil) {[weak self] metaData, error in
            guard error == nil else {
                print("Failed to upload url to firebase for video")
                completion(.failure(StorageErrors.failedToUpload))
                return
            }
            
            self?.storage.child("message_videos/\(fileName)").downloadURL { url, error in
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
    
    
    
    public func downloadURL(for path:String, completion:@escaping (Result<URL,Error>) -> Void ) {
        let reference = self.storage.child(path)
        
        reference.downloadURL { url, error in
            guard let url = url ,error == nil else {
                completion(.failure(StorageErrors.failedToGetDownloadUrl))
                return
            }
            completion(.success(url))
        }
    }
}

enum StorageErrors:Error {
    case failedToUpload
    case failedToGetDownloadUrl
}
