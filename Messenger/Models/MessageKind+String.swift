import MessageKit

extension MessageKind {
    
    var messageKindString: String {
        switch self {
        case .text:
            return "text"
        case .attributedText:
            return "attributedText"
        case .photo:
            return "photo"
        case .video:
            return "video"
        case .location:
            return "location"
        case .emoji:
            return "emoji"
        case .audio:
            return "audio"
        case .contact:
            return "contact"
        case .linkPreview:
            return "linkPreview"
        case .custom:
            return "custom"
        }
    }
}
