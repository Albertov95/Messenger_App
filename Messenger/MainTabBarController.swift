import UIKit
import FirebaseAuth

final class MainTabBarController: UITabBarController {
    
    private var chatFlowCoordinator: ChatFlowCoordinator?
    private var loginFlowCoordinator: LoginFlowCoordinator?
    
    private var chatsNavigationController: UINavigationController {
        let chatsNavigationController = UINavigationController()
        chatsNavigationController.tabBarItem = UITabBarItem(
            title: "Chats",
            image: UIImage(systemName: "message"),
            selectedImage: UIImage(named: "message.fill")
        )
        chatFlowCoordinator = ChatFlowCoordinator(navigationController: chatsNavigationController)
        return chatsNavigationController
    }
    
    private var profileViewController: UIViewController {
        let profileViewController = ProfileViewController()
        profileViewController.tabBarItem = UITabBarItem(
            title: "Profile",
            image: UIImage(systemName: "person"),
            selectedImage: UIImage(named: "person.fill")
        )
        profileViewController.coordinator = loginFlowCoordinator
        return profileViewController
    }
    
    // MARK: - Init
    init() {
        super.init(nibName: nil, bundle: nil)
        
        loginFlowCoordinator = LoginFlowCoordinator(tabBarController: self)
        
        viewControllers = [chatsNavigationController, profileViewController]
        
        chatFlowCoordinator?.start()
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(loginDidFinish),
            name: Notifications.loginDidFinish,
            object: nil
        )
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        showLoginScreenIfNeeded()
    }
    
    private func showLoginScreenIfNeeded() {
        if FirebaseAuth.Auth.auth().currentUser == nil {
            loginFlowCoordinator?.start()
        }
    }
    
    // MARK: - Private methods
    @objc
    private func loginDidFinish() {
        selectedIndex = 0
    }
}
