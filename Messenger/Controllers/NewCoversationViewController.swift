//
//  NewCoversationViewController.swift
//  Messenger
//
//  Created by Mallikharjun kakarla on 25/06/23.
//

import UIKit
import JGProgressHUD

class NewCoversationViewController: UIViewController {

    private let spinner = JGProgressHUD(style: .dark)
    
    private var users = [[String:String]]()
    private var results = [[String:String]]()
    
    private var hasFetched = false
    
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
        navigationItem.hidesBackButton = false
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel,
                                                           target: self,
                                                           action: #selector(didTapClose))
        searchBar.becomeFirstResponder()
        
        view.addSubviews(noResultsLabel,tableView)
        tableView.delegate = self
        tableView.dataSource = self
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = view.bounds
        noResultsLabel.frame = CGRect(x: view.width/4,
                                      y: (view.height-200)/2,
                                      width: view.width/2,
                                      height: 200)
    }
    
    @objc private func didTapClose() {
        self.dismiss(animated: true, completion: nil)
    }
}

//MARK: TableView
extension NewCoversationViewController:UITableViewDelegate,UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.results.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = results[indexPath.row]["name"]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
    }
}

//MARK: Searchbar delegate
extension NewCoversationViewController:UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let text = searchBar.text,!text.trimmingCharacters(in: .whitespaces).isEmpty else {
            return
        }
        
        searchBar.resignFirstResponder()
        
        self.results.removeAll()
        spinner.show(in: view)
        self.searchUsers(query: text)
    }
    
    func searchUsers(query:String) {
        //check if array has firebase results
        if hasFetched {
            // if it does, then filter
            self.filterUsers(with: query)
        } else {
            // if not,fetch and then filter
            DatabaseManager.shared.getAllUsers { [weak self] result in
                switch result {
                case .success(let users):
                    self?.hasFetched = true
                    self?.users = users
                    self?.filterUsers(with: query)
                case .failure(let error):
                    print(error.localizedDescription)
                }
            }
        }
        
        
        //update the UI
    }
    
    func filterUsers(with term:String) {
        guard hasFetched else {
            return
        }
        
        spinner.dismiss(animated: true)
        var results:[[String:String]] = self.users.filter({
            guard let name = $0["name"]?.lowercased() else {
                return false
            }
            return name.hasPrefix(term.lowercased())
        })
        self.results = results
        
        if self.results.isEmpty {
            noResultsLabel.isHidden = false
            tableView.isHidden = true
        } else {
            noResultsLabel.isHidden = true
            tableView.isHidden = false
            tableView.reloadData()
        }
    }
    
}
