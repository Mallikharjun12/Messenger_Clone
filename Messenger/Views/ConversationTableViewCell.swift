//
//  ConversationTableViewCell.swift
//  Messenger
//
//  Created by Mallikharjun kakarla on 06/07/23.
//

import UIKit
import SDWebImage

class ConversationTableViewCell: UITableViewCell {
    static let identidier = "ConversationTableViewCell"
    
    
    private let userImageView:UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 40
        imageView.layer.masksToBounds = true
        return imageView
    }()
    
    private let userNameLabel:UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 21, weight: .semibold)
        return label
    }()
    
    private let userMessageLabel:UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 18, weight: .regular)
        label.numberOfLines = -1
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubviews(userImageView,userNameLabel,userMessageLabel)
        addConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    private func addConstraints() {
        NSLayoutConstraint.activate([
            userImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor,constant: 12),
            userImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            userImageView.widthAnchor.constraint(equalToConstant: 80),
            userImageView.heightAnchor.constraint(equalToConstant: 80),
            userImageView.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -12),
            
            userNameLabel.leadingAnchor.constraint(equalTo: userImageView.trailingAnchor, constant: 12),
            userNameLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            userNameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12),

            userMessageLabel.topAnchor.constraint(equalTo: userImageView.centerYAnchor, constant: 2),
            userMessageLabel.leadingAnchor.constraint(equalTo: userImageView.trailingAnchor, constant: 12),
            userMessageLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12)
            
        ])
    }
    
//    override func layoutSubviews() {
//        super.layoutSubviews()
//
//        userImageView.frame = CGRect(x: 10,
//                                     y: 10,
//                                     width: 80,
//                                     height: 80)
//
//        userNameLabel.frame = CGRect(x: userImageView.right + 10,
//                                     y: 10,
//                                     width: contentView.width - 20 - userImageView.width,
//                                     height: (contentView.height)/2)
//
//        userMessageLabel.frame = CGRect(x: userImageView.right + 12,
//                                        y: userNameLabel.bottom + 10,
//                                     width: contentView.width - 20 - userImageView.width,
//                                     height: (contentView.height)/2)
//    }
    
    func configure(with model:Conversation) {
        userNameLabel.text = model.name
        userMessageLabel.text = model.latestMessage.text
        

        let path = "images/\(model.otherUserEmail)_profile_picture.png"
        
        StorageManager.shared.downloadURL(for: path) {[weak self] result in
            switch result {
            case .success(let url):
                DispatchQueue.main.async {
                    self?.userImageView.sd_setImage(with: url, completed: nil)
                }
            case .failure(let error):
                print("Failed to get url for profile:\(error.localizedDescription)")
            }
        }
    }
    
}
