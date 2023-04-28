import UIKit
import SDWebImage

final class ChatsTableViewCell: UITableViewCell {
    
    static let reuseId = "ChatsTableViewCell"
    
    // MARK: - UI Elements
    private let userImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = Metrics.module * 5
        imageView.layer.masksToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let usernameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 21, weight: .semibold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let userMessageLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 19, weight: .regular)
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // MARK: - Init
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setupLayout()
        
        contentView.addSubview(usernameLabel)
        contentView.addSubview(userMessageLabel)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Layout
    private func setupLayout() {
        setupImageViewLayout()
        setupUsernameLabelLayout()
        setupUserMessageLabelLayout()
    }
    
    private func setupImageViewLayout() {
        contentView.addSubview(userImageView)
        
        userImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Metrics.module).isActive = true
        userImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
        userImageView.widthAnchor.constraint(equalToConstant: Metrics.module * 10).isActive = true
        userImageView.heightAnchor.constraint(equalToConstant: Metrics.module * 10).isActive = true
    }
    
    private func setupUsernameLabelLayout() {
        contentView.addSubview(usernameLabel)
        
        usernameLabel.leadingAnchor.constraint(equalTo: usernameLabel.trailingAnchor, constant: Metrics.doubleModule).isActive = true
        usernameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Metrics.module).isActive = true
        usernameLabel.topAnchor.constraint(equalTo: usernameLabel.topAnchor, constant: Metrics.halfModule).isActive = true
    }
    
    private func setupUserMessageLabelLayout() {
        contentView.addSubview(userMessageLabel)
        
        userMessageLabel.leadingAnchor.constraint(equalTo: usernameLabel.leadingAnchor).isActive = true
        userMessageLabel.topAnchor.constraint(equalTo: usernameLabel.bottomAnchor, constant: Metrics.halfModule).isActive = true
    }
    
    // MARK: - Configure
    func configure(with model: Conversation) {
        userMessageLabel.text = model.latestMessage.text
        usernameLabel.text = model.name
        loadImage(for: model.otherUserEmail)
    }
}

// MARK: - Loading
extension ChatsTableViewCell {
    
    private func loadImage(for email: String) {
        let path = "images/\(email)_profile_picture.png"
        StorageManager.shared.downloadURL(for: path) { [weak self] result in
            switch result {
            case .success(let url):
                DispatchQueue.main.async {
                    self?.userImageView.sd_setImage(with: url)
                }
            case .failure(let error):
                print("failet to get image url: \(error)")
            }
        }
    }
}
