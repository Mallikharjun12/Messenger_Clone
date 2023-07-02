//
//  NewCoversationViewController.swift
//  Messenger
//
//  Created by Mallikharjun kakarla on 25/06/23.
//

import UIKit
import JGProgressHUD

class NewCoversationViewController: UIViewController {

    private let searchBar:UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.placeholder = "Search For Users..."
        return searchBar
    }()
    
    private let tableView:UITableView = {
        let table = UITableView()
        table.isHidden = true
        table.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        return table
    }()
    
    private let noResultsLabel:UILabel = {
        let label = UILabel()
        label.text = "No Results!"
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 21,weight: .medium)
        label.isHidden = true
        label.textColor = .green
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchBar.delegate = self
        view.backgroundColor = .systemBackground
        navigationController?.navigationBar.topItem?.titleView = searchBar
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel,
                                                           target: self,
                                                           action: #selector(didTapClose))
        searchBar.becomeFirstResponder()
        
    }
    
    @objc private func didTapClose() {
        self.dismiss(animated: true, completion: nil)
    }
}

extension NewCoversationViewController:UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
    }
}
