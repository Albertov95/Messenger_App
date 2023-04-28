import UIKit
import FirebaseAuth

final class RegisterViewController: UIViewController {
    
    private let mainView = RegisterView()
    
    override func loadView() {
        view = mainView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        
        let tapGesture = UITapGestureRecognizer()
        tapGesture.addTarget(self, action: #selector(userImageViewTapped))
        
        mainView.userImageView.addGestureRecognizer(tapGesture)
        
        mainView.passwordTextField.isSecureTextEntry = true
        mainView.confirmPasswordTextField.isSecureTextEntry = true
        
        mainView.registerButton.addTarget(self, action: #selector(registerButtonTapped), for: .touchDown)
        mainView.registerButton.setTitle("Register", for: .normal)
        
        mainView.loginButton.addTarget(self, action: #selector(openScreen), for: .touchDown)
        
        mainView.emailTextField.autocapitalizationType = .none
        mainView.passwordTextField.autocapitalizationType = .none
        mainView.passwordTextField.isSecureTextEntry = true
        mainView.confirmPasswordTextField.autocapitalizationType = .none
        mainView.confirmPasswordTextField.isSecureTextEntry = true
        
        mainView.emailTextField.delegate = self
        mainView.passwordTextField.delegate = self
    }

    @objc
    private func registerButtonTapped() {
        guard let username = mainView.usernameTextField.text,
              let email = mainView.emailTextField.text,
              let password = mainView.passwordTextField.text,
              let confirmPassword = mainView.confirmPasswordTextField.text,
              !username.isEmpty,
              !email.isEmpty,
              !password.isEmpty,
              !confirmPassword.isEmpty
        else {
            showAlert(title: "Ошибка", message: "Данные не должны быть пустыми")
            return
        }
        
        if username.count < 5 || email.count < 5 || password.count < 5 || confirmPassword.count < 5 {
            showAlert(title: "Ошибка", message: "Минимальная длина 5 символов")
            return
        }
        
        DatabaseManager.shared.checkUserExists(email: email) { [weak self] exists in
            guard let strongSelf = self else { return }
            
            guard !exists else {
                strongSelf.showAlert(title: "Ошибка", message: "Такой пользователь уже существует")
                return
            }
            
            FirebaseAuth.Auth.auth().createUser(withEmail: email, password: password) { result, error in
                guard result != nil, error == nil else {
                    strongSelf.showAlert(title: "Произошла ошибка регистрации", message: "Error")
                    return
                }
                
                let chatUser = User(firstName: username, emailAddress: email)
                DatabaseManager.shared.insertUser(with: chatUser) { success in
                    if success {
                        guard let image = strongSelf.mainView.userImageView.image,
                              let data = image.pngData() else {
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
                    }
                }
                strongSelf.dismiss(animated: true)
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
    private func userImageViewTapped() {
        let actionSheet = UIAlertController(title: "Выберите изображение", message: nil, preferredStyle: .actionSheet)
        
        let cameraAction = UIAlertAction(title: "Сделать при помощи камеры", style: .default) { _ in
            self.showCamera()
        }
        let galleryAction = UIAlertAction(title: "Добавить из галереи", style: .default) { _ in
            self.showGallery()
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        
        actionSheet.addAction(cameraAction)
        actionSheet.addAction(galleryAction)
        actionSheet.addAction(cancelAction)
        
        present(actionSheet, animated: false)
    }
    
    private func showGallery() {
        let picker = UIImagePickerController()
        picker.sourceType = .photoLibrary
        picker.allowsEditing = true
        picker.delegate = self
        present(picker, animated: false)
    }
    
    private func showCamera() {
        let picker = UIImagePickerController()
        picker.sourceType = .camera
        picker.delegate = self
        present(picker, animated: false)
    }
    
    @objc func openScreen() {
        let vc = LoginViewController()
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: false)
    }
}

extension RegisterViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(
        _ picker: UIImagePickerController,
        didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]
    ) {
        guard let image = info[.originalImage] as? UIImage else { return }
        mainView.userImageView.image = image
        picker.dismiss(animated: false)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: false)
    }
}

extension RegisterViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == mainView.usernameTextField {
            mainView.emailTextField.becomeFirstResponder()
        } else if textField == mainView.emailTextField {
            mainView.passwordTextField.becomeFirstResponder()
        } else if textField == mainView.passwordTextField {
            registerButtonTapped()
        }
        return true
    }
}
