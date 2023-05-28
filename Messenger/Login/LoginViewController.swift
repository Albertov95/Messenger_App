import UIKit
import JGProgressHUD

final class LoginViewController: UIViewController {
    
    private let mainView = LoginView()
    private let dataController = LoginDataManager()
    
    private let spinner = JGProgressHUD(style: .dark)
    
    override func loadView() {
        view = mainView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        
        dataController.delegate = self
        
        view.addSubview(spinner)
        
        setupView()
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(loginDidFinish),
            name: Notifications.loginDidFinish,
            object: nil
        )
    }
    
    // MARK: - Private methods
    private func setupView() {
        mainView.loginButton.addTarget(self, action: #selector(loginButtonTapped), for: .touchDown)
        mainView.loginButton.setTitle("Login", for: .normal)
        
        mainView.registerButton.addTarget(self, action: #selector(registerButtonTapped), for: .touchDown)
        
        mainView.passwordTextField.isSecureTextEntry = true
        mainView.passwordTextField.autocapitalizationType = .none
        
        mainView.emailTextField.autocapitalizationType = . none
        
        mainView.emailTextField.delegate = self
        mainView.passwordTextField.delegate = self

        mainView.socialNetworksView.googleButton.addTarget(self, action: #selector(googleSignInButtonTapped), for: .touchDown)
    }
    
    @objc
    private func loginDidFinish() {
        dismiss(animated: true)
    }
    
    @objc
    private func loginButtonTapped() {
        guard let email = mainView.emailTextField.text,
              let password = mainView.passwordTextField.text,
              !email.isEmpty,
              !password.isEmpty
        else {
            showAlert(title: "Ошибка", message: "Данные не должны быть пустыми")
            return
        }
        
        if email.count < 5 || password.count < 5 {
            showAlert(title: "Ошибка", message: "Минимальная длина 5 символов")
            return
        }

        spinner.show(in: view)
        
        dataController.loginUser(
            email: email,
            password: password
        ) { [weak self] in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                self.spinner.dismiss()
            }
            
            NotificationCenter.default.post(name: Notifications.loginDidFinish, object: nil)
        }
    }
    
    @objc
    private func googleSignInButtonTapped() {
        dataController.googleSignIn(viewController: self) { [weak self] in
            self?.dismiss(animated: false)
        }
    }
    
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(okAction)
        present(alert, animated: false, completion: nil)
    }
    
    @objc
    private func registerButtonTapped() {
        let vc = RegisterViewController()
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: false)
    }
}

extension LoginViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == mainView.emailTextField {
            mainView.passwordTextField.becomeFirstResponder()
        } else if textField == mainView.passwordTextField {
            loginButtonTapped()
        }
        return true
    }
}

extension LoginViewController: LoginDataManagerDelegate {
    
    func handleUserLoginError() {
        spinner.dismiss()
        showAlert(title: "Ошибка", message: "Неверный логин или пароль")
    }
}
