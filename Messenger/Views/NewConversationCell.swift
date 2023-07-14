//
//  NewConversationCell.swift
//  Messenger
//
//  Created by Mallikharjun kakarla on 09/07/23.
//

import UIKit
import SDWebImage

class NewConversationCell: UITableViewCell {
    static let identidier = "NewConversationCell"
    
    
    private let userImageView:UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 25
        imageView.layer.masksToBounds = true
        return imageView
    }()
    
    private let userNameLabel:UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 21, weight: .regular)
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubviews(userImageView,userNameLabel)
        addConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    private func addConstraints() {
        NSLayoutConstraint.activate([
            userImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor,constant: 12),
            userImageView.widthAnchor.constraint(equalToConstant: 50),
            userImageView.heightAnchor.constraint(equalToConstant: 50),
            userImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 4),
            userImageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -4),
            
            userNameLabel.leadingAnchor.constraint(equalTo: userImageView.trailingAnchor, constant: 12),
            userNameLabel.centerYAnchor.constraint(equalTo: userImageView.centerYAnchor)

            
        ])
    }
    
    func configure(with model:SearchResult) {
        userNameLabel.text = model.name
        let path = "images/\(model.email)_profile_picture.png"
        
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
