import UIKit
import MessageKit

struct MessageConverter {
    
    static func messages(from messageResult: [[String: Any]], dateFormatter: DateFormatter) -> [Message] {
        let messages: [Message] = messageResult.compactMap { dictionary in
            guard let name = dictionary["name"] as? String,
                  let messageID = dictionary["id"] as? String,
                  let content = dictionary["content"] as? String,
                  let senderEmail = dictionary["sender_email"] as? String,
                  let type = dictionary["type"] as? String,
                  let dateString = dictionary["date"] as? String,
                  let date = dateFormatter.date(from: dateString)
            else {
                return nil
            }
            
            guard let finalKind = messageKind(type: type, content: content) else {
                return nil
            }
            
            let sender = Sender(photoURL: "", senderId: senderEmail, displayName: name)
            
            return Message(sender: sender, messageId: messageID, sentDate: date, kind: finalKind)
        }
        
        return messages
    }
    
    private static func messageKind(type: String, content: String) -> MessageKind? {
        var kind: MessageKind?
        if type == "photo" {
            kind = messagePhotoKind(content: content)
        } else if type == "video" {
            kind = messageVideoKind(content: content)
        } else {
            kind = .text(content)
        }
        
        return kind
    }
    
    private static func messagePhotoKind(content: String) -> MessageKind? {
        guard let imageUrl = URL(string: content),
              let placeholder = UIImage(systemName: "plus")
        else {
            return nil
        }
        let media = Media(
            url: imageUrl,
            image: nil,
            placeholderImage: placeholder,
            size: CGSize(width: 300, height: 300)
        )
        
        return .photo(media)
    }
    
    private static func messageVideoKind(content: String) -> MessageKind? {
        guard let videoURL = URL(string: content),
              let placeholder = UIImage(systemName: "plus")
        else {
            return nil
        }
        let media = Media(
            url: videoURL,
            image: nil,
            placeholderImage: placeholder,
            size: CGSize(width: 300, height: 300)
        )
        return .video(media)
    }
}
