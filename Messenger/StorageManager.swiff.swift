import Foundation
import FirebaseStorage

enum StorageErrors: Error {
    case failedToUpload
    case failedToGetDownloadUrl
}

final class StorageManager {
    
    static let shared = StorageManager()
    
    private let storage = Storage.storage().reference()
    
    typealias UploadPictureCompletion = (Result<String, Error>) -> Void
    
    func uploadProfilePicture(
        with data: Data,
        fileName: String,
        completion: @escaping UploadPictureCompletion
    ) {
        storage.child("images/\(fileName)").putData(data, metadata: nil) { [weak self] metadata, error in
            guard let self = self else { return }
            
            guard error == nil else {
                completion(.failure(StorageErrors.failedToUpload))
                return
            }
            
            self.storage.child("images/\(fileName)").downloadURL { url, error in
                guard let url = url else {
                    completion(.failure(StorageErrors.failedToGetDownloadUrl))
                    return
                }
                
                let urlString = url.absoluteString
    
                completion(.success(urlString))
            }
        }
    }
    
    func uploadMessagePhoto(
        with data: Data,
        fileName: String,
        completion: @escaping UploadPictureCompletion
    ) {
        storage.child("messages_images/\(fileName)").putData(data, metadata: nil) { [weak self] metadata, error in
            guard let self = self else { return }
            
            guard error == nil else {
                completion(.failure(StorageErrors.failedToUpload))
                return
            }
            
            self.storage.child("messages_images/\(fileName)").downloadURL { url, error in
                guard let url = url else {
                    completion(.failure(StorageErrors.failedToGetDownloadUrl))
                    return
                }
                
                let urlString = url.absoluteString

                completion(.success(urlString))
            }
        }
    }
    
    func uploadMessageVideo(
        with fileURL: URL,
        fileName: String,
        completion: @escaping UploadPictureCompletion
    ) {
        storage.child("messages_videos/\(fileName)").putFile(from: fileURL, metadata: nil) { [weak self] metadata, error in
            guard let self = self else { return }
            
            guard error == nil else {
                completion(.failure(StorageErrors.failedToUpload))
                return
            }
            
            self.storage.child("messages_videos/\(fileName)").downloadURL { url, error in
                guard let url = url else {
                    completion(.failure(StorageErrors.failedToGetDownloadUrl))
                    return
                }
                
                let urlString = url.absoluteString

                completion(.success(urlString))
            }
        }
    }
    
    func downloadURL(for path: String, completion: @escaping (Result<URL, Error>) -> Void) {
        let reference = storage.child(path)
        
        reference.downloadURL { url, error in
            guard let url = url, error == nil else {
                completion(.failure(StorageErrors.failedToGetDownloadUrl))
                return
            }
            
            completion(.success(url))
        }
    }
}
