import UIKit
import FirebaseAuth

protocol RegisterDataManagerDelegate: AnyObject {
    func handleUserExistsRegistrationError()
    func handleRegistrationError()
}

final class RegisterDataManager {
    
    weak var delegate: RegisterDataManagerDelegate?
    
    func registerUser(
        email: String,
        username: String,
        password: String,
        image: UIImage?,
        completion: @escaping (String) -> Void
    ) {
        DatabaseManager.shared.checkUserExists(email: email) { [weak self] exists in
            guard let self = self else { return }
            
            guard !exists else {
                self.delegate?.handleUserExistsRegistrationError()
                return
            }
            
            FirebaseAuth.Auth.auth().createUser(withEmail: email, password: password) { result, error in
                guard result != nil, error == nil else {
                    self.delegate?.handleRegistrationError()
                    return
                }
                
                let chatUser = User(firstName: username, emailAddress: email)
                DatabaseManager.shared.insertUser(with: chatUser) { success in
                    guard success,
                          let image = image,
                          let data = image.pngData() else {
                        return
                    }
                    
                    let filename = chatUser.profilePictureFileName
                    StorageManager.shared.uploadProfilePicture(with: data, fileName: filename) { result in
                        switch result {
                        case .success(let downloadUrl):
                            UserDefaults.standard.set(downloadUrl, forKey: "profile_picture_url")
                        case .failure(let error):
                            print("Storage manager error: \(error)")
                        }
                    }
                }
                completion(email)
            }
        }
    }
}
