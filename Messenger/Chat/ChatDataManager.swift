import UIKit

final class ChatDataManager {
    
    private lazy var dateFormatter: DateFormatter = {
        let formattre = DateFormatter()
        formattre.dateStyle = .medium
        formattre.timeStyle = .long
        formattre.locale = .current
        return formattre
    }()
    
    // MARK: - Media
    func uploadMedia(
        info: [UIImagePickerController.InfoKey : Any],
        name: String,
        sender: Sender,
        conversationId: String,
        otherUserEmail: String
    ) {
        guard let messageId = createMessageId(otherUserEmail: otherUserEmail) else { return }
        
        if let image = info[.editedImage] as? UIImage, let imageData = image.pngData() {
            uploadMessagePhoto(
                messageId: messageId,
                imageData: imageData,
                name: name,
                sender: sender,
                conversationId: conversationId,
                otherUserEmail: otherUserEmail
            )
        } else if let videoUrl = info[.mediaURL] as? URL {
            uploadMessageVideo(
                messageId: messageId,
                url: videoUrl,
                name: name,
                sender: sender,
                conversationId: conversationId,
                otherUserEmail: otherUserEmail
            )
        }
    }
    
    private func uploadMessagePhoto(
        messageId: String,
        imageData: Data,
        name: String,
        sender: Sender,
        conversationId: String,
        otherUserEmail: String
    ) {
        let fileName = "photo_message_" + messageId.replacingOccurrences(of: " ", with: "-") + ".png"
        
        StorageManager.shared.uploadMessagePhoto(with: imageData, fileName: fileName) { result in
            switch result {
            case .success(let urlString):
                guard let url = URL(string: urlString),
                      let placeholder = UIImage(systemName: "plus")
                else {
                    return
                }
                
                let media = Media(url: url, image: nil, placeholderImage: placeholder, size: .zero)
                
                let message = Message(
                    sender: sender,
                    messageId: messageId,
                    sentDate: Date(),
                    kind: .photo(media)
                )
                
                DatabaseManager.shared.sendMessage(
                    to: conversationId,
                    otherUserEmail: otherUserEmail,
                    name: name,
                    newMessage: message
                ) { success in
                    if !success {
                        print("failed to send photo message")
                    }
                }
            case .failure(let error):
                print("message photo upload error: \(error)")
            }
        }
    }
    
    private func uploadMessageVideo(
        messageId: String,
        url: URL,
        name: String,
        sender: Sender,
        conversationId: String,
        otherUserEmail: String
    ) {
        let fileName = "photo_message_" + messageId.replacingOccurrences(of: " ", with: "-") + ".mov"
        
        StorageManager.shared.uploadMessageVideo(with: url, fileName: fileName) { result in
            switch result {
            case .success(let urlString):
                guard let url = URL(string: urlString),
                      let placeholder = UIImage(systemName: "plus")
                else {
                    return
                }
                
                let media = Media(url: url, image: nil, placeholderImage: placeholder, size: .zero)
                
                let message = Message(
                    sender: sender,
                    messageId: messageId,
                    sentDate: Date(),
                    kind: .video(media)
                )
                
                DatabaseManager.shared.sendMessage(
                    to: conversationId,
                    otherUserEmail: otherUserEmail,
                    name: name,
                    newMessage: message
                ) { success in
                    if !success {
                        print("failed to send photo message")
                    }
                }
            case .failure(let error):
                print("message photo upload error: \(error)")
            }
        }
    }
}

// MARK: - Message
extension ChatDataManager {
    
    func sendNewMessage(
        sender: Sender,
        text: String,
        otherUserEmail: String,
        isNewConversation: Bool,
        title: String?,
        conversationId: String?,
        createNewChatCompletion: @escaping (String) -> Void
    ) {
        guard let messageId = createMessageId(otherUserEmail: otherUserEmail) else { return }
        
        let message = Message(
            sender: sender,
            messageId: messageId,
            sentDate: Date(),
            kind: .text(text)
        )
        
        if isNewConversation {
            DatabaseManager.shared.createNewConversation(
                with: otherUserEmail,
                name: title ?? "User",
                firstMessage: message
            ) { success in
                guard success else { return }
                createNewChatCompletion(messageId)
            }
        } else {
            guard let conversationId = conversationId, let name = title else {
                return
            }
            
            DatabaseManager.shared.sendMessage(
                to: conversationId,
                otherUserEmail: otherUserEmail,
                name: name,
                newMessage: message
            ) { _ in }
        }
    }
    
    private func createMessageId(otherUserEmail: String) -> String? {
        guard let currentUserEmail = UserDefaults.standard.value(forKey: "email") as? String else {
            return nil
        }
        
        let safeCurrentEmail = currentUserEmail.safe
        let dateString = dateFormatter.string(from: Date()).safe
        let newIdentifier = "\(otherUserEmail)_\(safeCurrentEmail)_\(dateString)"

        return newIdentifier
    }
}

