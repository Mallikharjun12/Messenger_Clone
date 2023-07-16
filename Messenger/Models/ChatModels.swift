//
//  ChatModels.swift
//  Messenger
//
//  Created by Mallikharjun kakarla on 16/07/23.
//

import Foundation
import CoreLocation
import MessageKit

struct Message:MessageType {
    var sender: MessageKit.SenderType
    var messageId: String
    var sentDate: Date
    var kind: MessageKit.MessageKind
}

extension MessageKind {
    var messageKindString:String {
        switch self {
        case .text:
            return "text"
        case .attributedText:
            return "attributed_text"
        case .photo:
            return "photo"
        case .video:
            return "video"
        case .location:
            return "location"
        case .emoji:
            return "emoji"
        case .audio:
            return "audio"
        case .contact:
            return "contact"
        case .linkPreview:
            return "linkPreview"
        case .custom:
            return "custom"
        }
    }
}

struct Sender:SenderType {
    var photo:String
    var senderId: String
    var displayName: String
}

struct Media:MediaItem {
    var url: URL?
    var image: UIImage?
    var placeholderImage: UIImage
    var size: CGSize
    
}

struct Location:LocationItem {
    var location: CLLocation
    var size: CGSize
}
