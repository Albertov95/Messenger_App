import UIKit
import FirebaseAuth
import JGProgressHUD

final class ChatListViewController: UIViewController {
    
    weak var coordinator: ChatFlowCoordinator?

    private var conversations = [Conversation]()

    private let tableView: UITableView = {
        let table = UITableView()
        table.translatesAutoresizingMaskIntoConstraints = false
        return table
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        
        setupNavigationItem()
        setupTableView()
        setupTableViewLayout()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        fetchConversations()
    }
    
    // MARK: - Private methods
    private func setupNavigationItem() {
        navigationItem.title = "Чаты"
        navigationItem.searchController = UISearchController()
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .compose,
            target: self,
            action: #selector(newChatButtonTapped)
        )
    }
    
    private func setupTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        
        tableView.register(ChatsTableViewCell.self, forCellReuseIdentifier: ChatsTableViewCell.reuseId)
    }
    
    private func setupTableViewLayout() {
        view.addSubview(tableView)

        tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
    }
    
    private func fetchConversations() {
        guard let email = UserDefaults.standard.value(forKey: "email") as? String else {
            return
        }

        DatabaseManager.shared.getAllConversations(for: email.safe) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let conversations):
                guard !conversations.isEmpty else { return }
                
                self.conversations = conversations
            case .failure(let error):
                print("failed to get conversations: \(error)")
                self.conversations = []
            }
            
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    @objc
    private func newChatButtonTapped() {
        coordinator?.newChatButtonDidTapped(delegate: self)
    }
    
    private func createNewChatViewController(result: SearchResult) {
        coordinator?.chatItemDidTapped(
            email: result.email,
            id: nil,
            title: result.name,
            isNewConversation: true
        )
    }
    
    private func openConversation(id: String, email: String, title: String) {
        coordinator?.chatItemDidTapped(email: email, id: id, title: title)
    }
}

// MARK: - NewChatsViewControllerDelegate
extension ChatListViewController: NewChatsViewControllerDelegate {
    
    func newChatItemTapped(searchResult: SearchResult) {
        if let targetConversation = conversations.first(
            where: { $0.otherUserEmail == searchResult.email.safe }
        ) {
            openConversation(
                id: targetConversation.id,
                email: targetConversation.otherUserEmail,
                title: searchResult.name
            )
        } else {
            createNewChatViewController(result: searchResult)
        }
    }
}

// MARK: - UITableViewDataSource
extension ChatListViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        conversations.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: ChatsTableViewCell.reuseId
        ) as? ChatsTableViewCell else {
            fatalError("Can not dequeue ChatsTableViewCell")
        }
        
        let item = conversations[indexPath.row]

        cell.configure(with: item)
        cell.selectionStyle = .none
        
        return cell
    }
}

// MARK: - UITableViewDelegate
extension ChatListViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let model = conversations[indexPath.row]
        
        openConversation(id: model.id, email: model.otherUserEmail, title: model.name)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120
    }
}
