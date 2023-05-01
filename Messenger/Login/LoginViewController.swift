import UIKit
import FirebaseAuth
import JGProgressHUD
import GoogleSignIn
import FirebaseCore

final class LoginViewController: UIViewController {
    
    private let mainView = LoginView()
    
    private let spinner = JGProgressHUD(style: .dark)
    
    override func loadView() {
        super.loadView()
        
        view = mainView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        
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
        
        mainView.loginButton.setTitle("Login", for: .normal)
        
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
        }

        spinner.show(in: view)
        FirebaseAuth.Auth.auth().signIn(withEmail: email, password: password) { [weak self] result, error in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                self.spinner.dismiss()
            }
            
            guard result != nil, error == nil else {
                self.showAlert(title: "Ошибка", message: "Неверный логин или пароль")
                return
            }

            let safeEmail = email.safe
            
            DatabaseManager.shared.getDataFor(path: safeEmail) { result in
                switch result{
                case .success(let data):
                    guard let userData = data as? [String: Any],
                          let firstName = userData["first_name"] as? String
                    else {
                        return
                    }
                    UserDefaults.standard.set(firstName, forKey: "name")
                    
                case .failure(let error):
                    print("failed to read data with error: \(error)")
                }
            }
            
            UserDefaults.standard.set(email, forKey: "email")
            
            NotificationCenter.default.post(name: Notifications.loginDidFinish, object: nil)
        }
    }
    
    @objc
    private func googleSignInButtonTapped() {
        guard let clientID = FirebaseApp.app()?.options.clientID else { return }

        GIDSignIn.sharedInstance.configuration = GIDConfiguration(clientID: clientID)
        
        GIDSignIn.sharedInstance.signIn(withPresenting: self) { [unowned self] result, error in
            guard error == nil else {
                return
            }
            
            guard let user = result?.user,
                  let idToken = user.idToken?.tokenString,
                  let email = user.profile?.email,
                  let firstName = user.profile?.givenName
            else {
                return
            }
            
            UserDefaults.standard.set(email, forKey: "email")
            UserDefaults.standard.set(firstName, forKey: "name")
            
            DatabaseManager.shared.checkUserExists(email: email) { exists in
                guard !exists else { return }
                
                let chatUser = User(
                    firstName: firstName,
                    emailAddress: email
                )
                DatabaseManager.shared.insertUser(with: chatUser) { success in
                    guard success,
                          user.profile?.hasImage == true,
                          let url = user.profile?.imageURL(withDimension: 200)
                    else { return }
                    
                    URLSession.shared.dataTask(with: url, completionHandler: { data, _,_ in
                        guard let data = data else {
                            print("Failed to get data from facebook")
                            return
                        }
                        
                        let filename = chatUser.profilePictureFileName
                        StorageManager.shared.uploadProfilePicture(with: data, fileName: filename) { result in
                            switch result {
                            case .success(let downloadUrl):
                                UserDefaults.standard.set(downloadUrl, forKey: "profile_picture_url")
                                print(downloadUrl)
                            case .failure(let error):
                                print("Storage manager error: \(error)")
                            }
                        }
                    }).resume()
                }
            }
            
            let credential = GoogleAuthProvider.credential(
                withIDToken: idToken,
                accessToken: user.accessToken.tokenString
            )
            
            FirebaseAuth.Auth.auth().signIn(with: credential) { [weak self] result, error in
                guard let self = self else { return }
                
                guard result != nil, error == nil else {
                    self.showAlert(title: "Ошибка", message: "Неверный логин или пароль")
                    return
                }
                
                self.dismiss(animated: false)
            }
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
