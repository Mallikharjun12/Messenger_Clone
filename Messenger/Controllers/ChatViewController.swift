//
//  ChatViewController.swift
//  Messenger
//
//  Created by Mallikharjun kakarla on 02/07/23.
//

import UIKit
import MessageKit

struct Message:MessageType {
    var sender: MessageKit.SenderType
    var messageId: String
    var sentDate: Date
    var kind: MessageKit.MessageKind
}

struct Sender:SenderType {
    var photo:String
    var senderId: String
    var displayName: String
}

class ChatViewController: MessagesViewController {

    private var messages = [Message]()
    
    private let selfSender = Sender(photo: "",
                                    senderId: "1",
                                    displayName: "Joe")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        messages.append(Message(sender: selfSender,
                                messageId: "1",
                                sentDate: Date(),
                                kind: .text("Hello World Message")))
        
        messages.append(Message(sender: selfSender,
                                messageId: "1",
                                sentDate: Date(),
                                kind: .text("Hello World Message|Hello World Message|Hello World Message|Hello World Message")))
        
        view.backgroundColor = .systemBackground
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
    }

}

extension ChatViewController:MessagesDataSource,MessagesLayoutDelegate,MessagesDisplayDelegate {
    func currentSender() -> MessageKit.SenderType {
        return selfSender
    }
    
    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessageKit.MessagesCollectionView) -> MessageKit.MessageType {
        return messages[indexPath.section]
    }
    
    func numberOfSections(in messagesCollectionView: MessageKit.MessagesCollectionView) -> Int {
        return messages.count
    }
    
    
}
