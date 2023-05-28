import UIKit

final class RegisterViewController: UIViewController {
    
    private let mainView = RegisterView()
    private let dataController = RegisterDataManager()
    
    // MARK: - Lifecycle
    override func loadView() {
        view = mainView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        
        dataController.delegate = self
        
        let tapGesture = UITapGestureRecognizer()
        tapGesture.addTarget(self, action: #selector(userImageViewTapped))
        
        mainView.userImageView.addGestureRecognizer(tapGesture)
        
        mainView.passwordTextField.isSecureTextEntry = true
        mainView.confirmPasswordTextField.isSecureTextEntry = true
        
        mainView.registerButton.addTarget(self, action: #selector(registerButtonTapped), for: .touchDown)
        mainView.registerButton.setTitle("Register", for: .normal)
        
        mainView.loginButton.addTarget(self, action: #selector(loginButtonTapped), for: .touchDown)
        
        mainView.emailTextField.autocapitalizationType = .none
        mainView.passwordTextField.autocapitalizationType = .none
        mainView.passwordTextField.isSecureTextEntry = true
        mainView.confirmPasswordTextField.autocapitalizationType = .none
        mainView.confirmPasswordTextField.isSecureTextEntry = true
        
        mainView.emailTextField.delegate = self
        mainView.passwordTextField.delegate = self
    }

    // MARK: - Private methods
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
        
        dataController.registerUser(
            email: email,
            username: username,
            password: password,
            image: mainView.userImageView.image
        ) { [weak self] email in
            guard let self = self else { return }
            
            UserDefaults.standard.set(email, forKey: "email")
            
            self.dismiss(animated: true)
            
            NotificationCenter.default.post(name: Notifications.loginDidFinish, object: nil)
        }
    }
    
    @objc
    private func loginButtonTapped() {
        dismiss(animated: false)
    }
    
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(okAction)
        present(alert, animated: false, completion: nil)
    }
}

// MARK: - Image picker
extension RegisterViewController {
    
    @objc
    private func userImageViewTapped() {
        let actionSheet = UIAlertController(title: "Выберите изображение", message: nil, preferredStyle: .actionSheet)
        
        let cameraAction = UIAlertAction(title: "Сделать при помощи камеры", style: .default) { [weak self] _ in
            self?.showCamera()
        }
        let galleryAction = UIAlertAction(title: "Добавить из галереи", style: .default) { [weak self] _ in
            self?.showGallery()
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
}

// MARK: - UIImagePickerControllerDelegate
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

// MARK: - UITextFieldDelegate
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

// MARK: - RegisterDataControllerDelegate
extension RegisterViewController: RegisterDataManagerDelegate {
    
    func handleUserExistsRegistrationError() {
        showAlert(title: "Ошибка", message: "Пользователь уже существует")
    }
    
    func handleRegistrationError() {
        showAlert(title: "Ошибка", message: "Произошла ошибка регистрации")
    }
}
