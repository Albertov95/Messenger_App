import UIKit
import FirebaseAuth
import GoogleSignIn
import FirebaseCore

protocol LoginDataManagerDelegate: AnyObject {
    func handleUserLoginError()
}

final class LoginDataManager {
    
    weak var delegate: LoginDataManagerDelegate?
    
    func loginUser(
        email: String,
        password: String,
        completion: @escaping () -> Void
    ) {
        FirebaseAuth.Auth.auth().signIn(withEmail: email, password: password) { [weak self] result, error in
            guard let self = self else { return }
            
            guard result != nil, error == nil else {
                self.delegate?.handleUserLoginError()
                return
            }
            
            let safeEmail = email.safe
            
            DatabaseManager.shared.getDataFor(path: safeEmail) { result in
                switch result {
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
            
            completion()
        }
    }
    
    func googleSignIn(
        viewController: UIViewController,
        completion: @escaping () -> Void
    ) {
        guard let clientID = FirebaseApp.app()?.options.clientID else { return }

        GIDSignIn.sharedInstance.configuration = GIDConfiguration(clientID: clientID)
        
        GIDSignIn.sharedInstance.signIn(withPresenting: viewController) { result, error in
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
                            print("Failed to get data from google")
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
                    self.delegate?.handleUserLoginError()
                    return
                }
                
                completion()
            }
        }
    }
}
