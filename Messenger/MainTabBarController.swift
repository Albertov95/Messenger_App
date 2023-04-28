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
    
    init() {
        super.init(nibName: nil, bundle: nil)
        
        viewControllers = [chatsNavigationController, profileViewController]
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
