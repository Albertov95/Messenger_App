import UIKit
import FirebaseAuth
import GoogleSignIn

final class ProfileViewController: UIViewController {
    
    private let mainView = ProfileView()
    
    // MARK: - Lifecycle
    override func loadView() {
        view = mainView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        
        mainView.logOutButton.setTitle("Log Out", for: .normal)
        mainView.logOutButton.addTarget(self, action: #selector(buttonTapped), for: .touchDown)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        updateUserData()
    }
    
    // MARK: - Private methods
    @objc
    private func buttonTapped() {
        let alert = UIAlertController(title: "Выйти из аккаунта?", message: "Выберите", preferredStyle: .alert)
        let okActionYes = UIAlertAction(title: "Да", style: .default) { [weak self] _ in
            guard let self = self else { return }
            
            GIDSignIn.sharedInstance.signOut()
            
            do {
                try FirebaseAuth.Auth.auth().signOut()
                let vc = LoginViewController()
                vc.modalPresentationStyle = .fullScreen
                self.present(vc, animated: false)
            } catch {}
        }
        let okActionNo = UIAlertAction(title: "Нет", style: .default, handler: nil)
        alert.addAction(okActionYes)
        alert.addAction(okActionNo)
        present(alert, animated: false)
    }
    
    private func updateUserData() {
        mainView.email = FirebaseAuth.Auth.auth().currentUser?.email
        fetchUserImage()
    }
}

// MARK: - Network
extension ProfileViewController {
    
    private func fetchUserImage() {
        guard let email = UserDefaults.standard.value(forKey: "email") as? String else {
            return
        }
        
        let safeEmail = email.safe
        let filename = safeEmail + "_profile_picture.png"
        
        let path = "images/" + filename
        
        StorageManager.shared.downloadURL(for: path, completion: { [weak self] result in
            switch result {
            case .success(let url):
                self?.downloadImage(url: url)
            case .failure(let error):
                print("Failed to get download ur: \(error)")
            }
        })
    }
    
    private func downloadImage(url: URL) {
        URLSession.shared.dataTask(with: url) { [weak self] data, _, error in
            guard let data = data, error == nil else {
                return
            }
            
            DispatchQueue.main.async {
                self?.mainView.userImage = UIImage(data: data)
            }
        }.resume()
    }
}
