import UIKit
import JGProgressHUD

final class NewChatsViewController: UIViewController {
    
    var completion: ((SearchResult) -> (Void))? 
    
    private let spinner = JGProgressHUD(style: .dark)
    
    private var users = [[String: String]]()
    private var results = [SearchResult]()
    private var hasFetched = false
    
    // MARK: UI Elements
    private let searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        searchBar.placeholder = "Поиск"
        return searchBar
    }()
    
    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.isHidden = true
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        
        setupNavigationBar()
        setupTableView()
        setupTableViewLayout()
        setupSearchBar()
    }
    
    // MARK: - Private methods
    private func setupNavigationBar() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "Cancel",
            style: .plain,
            target: self,
            action: #selector(cancelButtonTapped)
        )
    }
    
    private func setupSearchBar() {
        searchBar.delegate = self
        searchBar.becomeFirstResponder()
        
        navigationController?.navigationBar.topItem?.titleView = searchBar
    }
    
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.register(NewChatTableViewCell.self, forCellReuseIdentifier: NewChatTableViewCell.reuseId)
    }
    
    private func setupTableViewLayout() {
        view.addSubview(tableView)
        
        tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
    }
    
    @objc
    private func cancelButtonTapped() {
        dismiss(animated: true)
    }
}

// MARK: - UITableViewDataSource
extension NewChatsViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return results.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: NewChatTableViewCell.reuseId, for: indexPath
        ) as? NewChatTableViewCell else {
            fatalError("Can not dequeue NewChatTableViewCell")
        }
        
        let item = results[indexPath.row]
        
        cell.configure(with: item)

        return cell
    }
}

// MARK: - UITableViewDelegate
extension NewChatsViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let targetUserData = results[indexPath.row]
        
        self.dismiss(animated: false) { [weak self] in
            self?.completion?(targetUserData)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        90
    }
}

// MARK: - UISearchBarDelegate
extension NewChatsViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let text = searchBar.text, !text.replacingOccurrences(of: " ", with: "").isEmpty else {
            return
        }
        
        searchBar.resignFirstResponder()
        
        results.removeAll()
        
        spinner.show(in: view)
        
        searchUsers(query: text)
    }
}

// MARK: - Users
extension NewChatsViewController {
    
    private func searchUsers(query: String) {
        if hasFetched {
            filterUsers(with: query)
        } else {
            DatabaseManager.shared.getAllUsers { [weak self] result in
                guard let self = self else { return }
                
                switch result {
                case .success(let usersCollection):
                    self.hasFetched = true
                    self.users = usersCollection
                    self.filterUsers(with: query)
                case .failure(let error):
                    print("failed to get users: \(error)")
                }
            }
        }
    }
    
    private func filterUsers(with term: String) {
        guard let currentUserEmail = UserDefaults.standard.value(forKey: "email") as? String, hasFetched else {
            return
        }
        
        let safeEmail = currentUserEmail.safeEmail
        
        self.spinner.dismiss()
        
        let filteredUsers = users.filter {
            guard let email = $0["email"],
                  email != safeEmail,
                  let name = $0["name"]?.lowercased()
            else {
                return false
            }

            return name.hasPrefix(term.lowercased())
        }
        
        let results: [SearchResult] = filteredUsers.compactMap {
            guard let email = $0["email"],
                  let name = $0["name"]
            else {
                return nil
            }
            
            return SearchResult(name: name, email: email)
        }
        
        self.results = results
        
        updateResult()
    }
    
    private func updateResult() {
        if results.isEmpty {
            self.tableView.isHidden = true
        } else {
            self.tableView.isHidden = false
            self.tableView.reloadData()
        }
    }
}
