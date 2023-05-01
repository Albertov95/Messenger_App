//
//  ChatListCoordinator.swift
//  Messenger
//
//  Created by Jaizy Albertov on 30.04.2023.
//

import UIKit

final class ChatFlowCoordinator {
    
    private let navigationController: UINavigationController
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
        let vc = ChatListViewController()
        vc.coordinator = self
        navigationController.pushViewController(vc, animated: true)
    }
    
    func chatItemDidTapped(email: String, id: String?, title: String?, isNewConversation: Bool = false) {
        let vc = ChatViewController(with: email, id: id, isNewConversation: isNewConversation)
        vc.title = title
        navigationController.pushViewController(vc, animated: true)
    }
    
    func newChatButtonDidTapped(delegate: NewChatsViewControllerDelegate) {
        let vc = NewChatsViewController()
        vc.delegate = delegate
        let newChatNavigationController = UINavigationController(rootViewController: vc)
        newChatNavigationController.modalPresentationStyle = .formSheet
        navigationController.present(newChatNavigationController, animated: false)
    }
}
