import UIKit
import JGProgressHUD
import MessageKit
import InputBarAccessoryView
import SDWebImage
import AVFoundation
import AVKit

final class ChatViewController: MessagesViewController {
    
    private var sender: Sender? {
        guard let email = UserDefaults.standard.value(forKey: "email") as? String else {
            return nil
        }

        return Sender(
            photoURL: "",
            senderId: email.safeEmail,
            displayName: "Me"
        )
    }
    
    private let dataController = ChatDataController()
    
    private let spinner = JGProgressHUD(style: .dark)
    
    private let otherUserEmail: String
    private let conversationId: String?
    
    private var isNewConversation = false
    private var messages = [Message]()
    
    // MARK: - Init
    init(with email: String, id: String?, isNewConversation: Bool = false) {
        self.conversationId = id
        self.otherUserEmail = email
        self.isNewConversation = isNewConversation
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        
        setupMessageCollectionView()
        setupInputButton()
    }
    
    // MARK: - Private methods
    private func setupMessageCollectionView() {
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        messagesCollectionView.messageCellDelegate = self
        messageInputBar.delegate = self
    }
    
    private func setupInputButton() {
        let button = InputBarButtonItem()
        button.setSize(CGSize(width: 36, height: 36), animated: false)
        button.setImage(UIImage(systemName: "plus"), for: .normal)
        button.tintColor = .black
        button.onTouchUpInside { [weak self] _ in
            self?.presentInputActionSheet()
        }
        messageInputBar.setLeftStackViewWidthConstant(to: 36, animated: false)
        messageInputBar.setStackViewItems([button], forStack: .left, animated: false)
    }
    
    private func listenForMessages(id: String, shouldScrollToBottom: Bool) {
        DatabaseManager.shared.getAllMessagesForConversation(with: id) { [weak self] result in
            switch result {
            case .success(let messages):
                guard !messages.isEmpty else {
                    return
                }
                self?.messages = messages
                
                DispatchQueue.main.async {
                    self?.messagesCollectionView.reloadDataAndKeepOffset()
                    
                    if shouldScrollToBottom {
                        self?.messagesCollectionView.scrollToLastItem()
                    }
                }
            case .failure(let error):
                print("failed to get messages: \(error)")
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        messageInputBar.inputTextView.becomeFirstResponder()
        
        if let conversationId = conversationId {
            listenForMessages(id: conversationId, shouldScrollToBottom: true)
        }
    }
}

// MARK: - Alert
extension ChatViewController {
    
    private func presentInputActionSheet() {
        let actionSheet = UIAlertController(
            title: "Attach media",
            message: "What would you like to attach?",
            preferredStyle: .actionSheet
        )
        
        let photoAction = UIAlertAction(title: "Photo", style: .default) { [weak self] _ in
            self?.presentPhotoInputActionSheet()
        }
        
        let videoAction = UIAlertAction(title: "Video", style: .default) { [weak self] _ in
            self?.presentVideoInputActionSheet()
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        
        actionSheet.addAction(photoAction)
        actionSheet.addAction(videoAction)
        actionSheet.addAction(cancelAction)
        
        present(actionSheet, animated: true)
    }
    
    private func presentPhotoInputActionSheet() {
        let actionSheet = UIAlertController(
            title: "Attach Photo",
            message: "Where would you like to attach a photo from",
            preferredStyle: .actionSheet
        )
        
        let cameraAction = UIAlertAction(title: "Camera", style: .default) { [weak self] _ in
            let picker = UIImagePickerController()
            picker.sourceType = .camera
            picker.delegate = self
            picker.allowsEditing = true
            self?.present(picker, animated: true)
        }
        
        let libraryAction = UIAlertAction(title: "Photo Library", style: .default) { [weak self] _ in
            let picker = UIImagePickerController()
            picker.sourceType = .photoLibrary
            picker.delegate = self
            picker.allowsEditing = true
            self?.present(picker, animated: true)
        }
        
        actionSheet.addAction(cameraAction)
        actionSheet.addAction(libraryAction)
        actionSheet.addAction(
            UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        )
        
        present(actionSheet, animated: true)
    }
    
    private func presentVideoInputActionSheet() {
        let actionSheet = UIAlertController(
            title: "Attach Video",
            message: "Where would you like to attach a video from",
            preferredStyle: .actionSheet
        )
        
        let cameraAction = UIAlertAction(title: "Camera", style: .default) { [weak self] _ in
            let picker = UIImagePickerController()
            picker.sourceType = .camera
            picker.delegate = self
            picker.mediaTypes = ["public.movie"]
            picker.videoQuality = .typeMedium
            picker.allowsEditing = true
            self?.present(picker, animated: true)
        }
        
        let libraryAction = UIAlertAction(title: "Library", style: .default) { [weak self] _ in
            let picker = UIImagePickerController()
            picker.sourceType = .photoLibrary
            picker.delegate = self
            picker.allowsEditing = true
            picker.mediaTypes = ["public.movie"]
            picker.videoQuality = .typeMedium
            self?.present(picker, animated: true)
        }
        
        actionSheet.addAction(cameraAction)
        actionSheet.addAction(libraryAction)
        actionSheet.addAction(
            UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        )
        
        present(actionSheet, animated: true)
    }
}

extension ChatViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
    
    func imagePickerController(
        _ picker: UIImagePickerController,
        didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]
    ) {
        picker.dismiss(animated: true)

        guard let conversationId = conversationId,
              let name = self.title,
              let sender = sender
        else {
            return
        }
        
        dataController.uploadMedia(
            info: info,
            name: name,
            sender: sender,
            conversationId: conversationId,
            otherUserEmail: otherUserEmail
        )
    }
}

// MARK: - InputBarAccessoryViewDelegate
extension ChatViewController: InputBarAccessoryViewDelegate {
    
    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
        guard !text.replacingOccurrences(of: " ", with: "").isEmpty,
              let sender = sender
        else {
            return
        }
        
        dataController.sendNewMessage(
            sender: sender,
            text: text,
            otherUserEmail: otherUserEmail,
            isNewConversation: isNewConversation,
            title: title,
            conversationId: conversationId
        ) { [weak self] in
            self?.isNewConversation = false
        }
        
        inputBar.inputTextView.text = nil
    }
}

// MARK: - MessagesDataSource
extension ChatViewController: MessagesDataSource, MessagesLayoutDelegate, MessagesDisplayDelegate {
    
    func currentSender() -> SenderType {
        if let sender = sender {
            return sender
        }
        fatalError("sender is nil, email should be cached")
    }
    
    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessageKit.MessagesCollectionView) -> MessageType {
        messages[indexPath.section]
    }
    
    func numberOfSections(in messagesCollectionView: MessageKit.MessagesCollectionView) -> Int {
        messages.count
    }
    
    func configureMediaMessageImageView(
        _ imageView: UIImageView,
        for message: MessageType,
        at indexPath: IndexPath,
        in messagesCollectionView: MessagesCollectionView
    ) {
        guard let message = message as? Message else {
            return
        }
        
        switch message.kind {
        case .photo(let media):
            guard let imageUrl = media.url else {
                return
            }
            imageView.sd_setImage(with: imageUrl, completed: nil)
        default:
            break
        }
    }
}

// MARK: - MessageCellDelegate
extension ChatViewController: MessageCellDelegate {
    
    func didTapImage(in cell: MessageCollectionViewCell) {
        guard let indexPath = messagesCollectionView.indexPath(for: cell) else {
            return
        }
        
        let message = messages[indexPath.section]
        
        switch message.kind {
        case .photo(let media):
            guard let imageUrl = media.url else {
                return
            }
            let vc = PhotoViewerViewController(with: imageUrl)
            self.navigationController?.pushViewController(vc, animated: true)
        case .video(let media):
            guard let videoURL = media.url else {
                return
            }
            let vc = AVPlayerViewController()
            vc.player = AVPlayer(url: videoURL)
            present(vc, animated: true)
        default:
            break
        }
    }
}
