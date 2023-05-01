//
//  LoginCoordinator.swift
//  Messenger
//
//  Created by Jaizy Albertov on 30.04.2023.
//

import UIKit

final class LoginFlowCoordinator {
    
    private let tabBarController: UITabBarController

    init(tabBarController: UITabBarController) {
        self.tabBarController = tabBarController
    }

    func start() {
        let vc = LoginViewController()
        vc.modalPresentationStyle = .fullScreen
        tabBarController.present(vc, animated: false)
    }
}
