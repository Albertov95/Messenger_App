import UIKit

final class MainTabBarController: UITabBarController {
    
    var chatsNavigationController: UINavigationController {
        let chatsViewController = ChatListViewController()
        let chatsNavigationController = UINavigationController(rootViewController: chatsViewController)
        chatsNavigationController.tabBarItem = UITabBarItem(
            title: "Chats",
            image: UIImage(systemName: "message"),
            selectedImage: UIImage(named: "message.fill")
        )
        return chatsNavigationController
    }
    
    var profileViewController: UIViewController {
        let profileViewController = ProfileViewController()
        profileViewController.tabBarItem = UITabBarItem(
            title: "Profile",
            image: UIImage(systemName: "person"),
            selectedImage: UIImage(named: "person.fill")
        )
        return profileViewController
    }
    
    // MARK: - Init
    init() {
        super.init(nibName: nil, bundle: nil)
        
        viewControllers = [chatsNavigationController, profileViewController]
        
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
    
    // MARK: - Private methods
    @objc
    private func loginDidFinish() {
        selectedIndex = 0
    }
}
