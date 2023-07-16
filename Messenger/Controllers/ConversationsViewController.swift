//
//  ViewController.swift
//  Messenger
//
//  Created by Mallikharjun kakarla on 25/06/23.
//

import UIKit
import FirebaseAuth
import JGProgressHUD


/// Controller that shows a list of conversations for a user
final class ConversationsViewController: UIViewController {

    private let spinner = JGProgressHUD(style: .dark)
    
    private var conversations = [Conversation]()
    
    private let tableView:UITableView = {
        let table = UITableView(frame: .zero, style: .insetGrouped)
        table.isHidden = true
        table.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        table.register(ConversationTableViewCell.self, forCellReuseIdentifier: ConversationTableViewCell.identidier)
        return table
    }()
    
    private let noConversationsLabel:UILabel = {
        let label = UILabel()
        label.text = "No Conversations!"
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 21,weight: .medium)
        label.isHidden = true
        label.textColor = .gray
        return label
    }()
    
    
    private var loginObserver:NSObjectProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .compose,
                                                            target: self,
                                                            action: #selector(didTapCompose))
        
        view.addSubviews(tableView,noConversationsLabel)
        setUpTableView()
        startListeningForConversations()
        
        loginObserver = NotificationCenter.default.addObserver(forName: Notification.Name.didLogInNotification, object: nil, queue: .main, using: {[weak self] _ in
            self?.startListeningForConversations()
        })
    }

    private func startListeningForConversations() {
        guard let email = UserDefaults.standard.value(forKey: "email") as? String else {
            return
        }
        
        if let observer = loginObserver {
            NotificationCenter.default.removeObserver(observer)
        }
        
        let safeEmail = DatabaseManager.safeEmail(emailAddress: email)
        
        DatabaseManager.shared.getAllConversations(for: safeEmail) {[weak self] result in
            switch result {
            case .success(let conversations):
                guard !conversations.isEmpty else {
                    self?.tableView.isHidden = true
                    self?.noConversationsLabel.isHidden = false
                    return
                }
                self?.conversations = conversations
                print("Coversations:\(conversations)")
                self?.tableView.isHidden = false
                self?.noConversationsLabel.isHidden = true
                
                DispatchQueue.main.async {
                    self?.tableView.reloadData()
                }
                
            case .failure(let error):
                print("Failed to get conversations:\(error)")
                self?.tableView.isHidden = true
                self?.noConversationsLabel.isHidden = false
            }
        }
    }
    
    @objc private func didTapCompose() {
        let vc = NewCoversationViewController()
        vc.completion = { [weak self] result in
           // print(result)
            guard let self else {
                return
            }
            let currentConversations = self.conversations
            if let targetConversation = currentConversations.first(where: {
                $0.otherUserEmail == DatabaseManager.safeEmail(emailAddress: result.email)
            }) {
                let vc = ChatViewController(with: targetConversation.otherUserEmail,id: targetConversation.id)
                vc.title = targetConversation.name
                vc.isNewConversation = false
                vc.navigationItem.largeTitleDisplayMode = .never
                self.navigationController?.pushViewController(vc, animated: true)
            } else {
                self.createNewConversation(result: result)
            }
            
        }
        let navVC = UINavigationController(rootViewController: vc)
        present(navVC, animated: true)
    }
    
    private func createNewConversation(result:SearchResult) {
        let name = result.name
        let email = result.email
        
        //check in database if conversation with these two users exists
        DatabaseManager.shared.isConversationExists(with: email) {[weak self] result in
            guard let self else {
                return
            }
            switch result {
            case .success(let conversationId):
                let vc = ChatViewController(with: email,id: conversationId)
                vc.title = name
                vc.isNewConversation = false
                vc.navigationItem.largeTitleDisplayMode = .never
                self.navigationController?.pushViewController(vc, animated: true)
            case .failure:
                let vc = ChatViewController(with: email,id: nil)
                vc.title = name
                vc.isNewConversation = true
                vc.navigationItem.largeTitleDisplayMode = .never
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
        
        
        //if it does,reuse the conversationId
        //otherwise
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        validateAuth()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = view.bounds
        noConversationsLabel.frame = CGRect(x: 10, y: view.center.y, width: view.width-20, height: 30)
    }
    
    private func validateAuth() {
        
        if Auth.auth().currentUser == nil {
            let vc = LoginViewController()
            let nav = UINavigationController(rootViewController: vc)
            nav.modalPresentationStyle = .fullScreen
            present(nav, animated: false)
        }
    }
    
    private func setUpTableView() {
        tableView.delegate = self
        tableView.dataSource = self
    }
    
}


extension ConversationsViewController:UITableViewDelegate,UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.conversations.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ConversationTableViewCell.identidier, for: indexPath) as! ConversationTableViewCell
        let model = conversations[indexPath.row]
        cell.configure(with: model)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let model = conversations[indexPath.row]
        openConversation(model)
    }
    
    func openConversation(_ model:Conversation) {
        let vc = ChatViewController(with: model.otherUserEmail, id: model.id)
        vc.title = model.name
        vc.navigationItem.largeTitleDisplayMode = .never
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .delete
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        let conversationId = conversations[indexPath.row].id
        
        if editingStyle == .delete {
            tableView.beginUpdates()
            self.conversations.remove(at: indexPath.section)
            tableView.deleteRows(at: [indexPath], with: .fade)
            DatabaseManager.shared.deleteConversation(conversationId: conversationId) { done in
                if !done {
                    print("failed to delete")
                }
            }
            tableView.endUpdates()
            
        }
    }
}
