import UIKit

final class NewChatTableViewCell: UITableViewCell {
    
    static let reuseId = "NewChatTableViewCell"
    
    // MARK: - UI Elements
    private let userImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = Metrics.module * 5
        imageView.layer.masksToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(named: "user")
        return imageView
    }()
    
    private let usernameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 21, weight: .semibold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // MARK: - Init
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setupLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Private methods
    private func setupLayout() {
        setupUserImageViewLayout()
        setupUsernameLabelViewLayout()
    }
    
    private func setupUserImageViewLayout() {
        contentView.addSubview(userImageView)
        
        userImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Metrics.module).isActive = true
        userImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
        userImageView.heightAnchor.constraint(equalToConstant: Metrics.module * 10).isActive = true
        userImageView.widthAnchor.constraint(equalToConstant: Metrics.module * 10).isActive = true
    }
    
    private func setupUsernameLabelViewLayout() {
        contentView.addSubview(usernameLabel)
        
        usernameLabel.leadingAnchor.constraint(equalTo: userImageView.trailingAnchor, constant: Metrics.doubleModule).isActive = true
        usernameLabel.centerYAnchor.constraint(equalTo: userImageView.centerYAnchor).isActive = true
    }
    
    // MARK: - Configure
    func configure(with model: SearchResult) {
        usernameLabel.text = model.name
        loadImage(for: model.email)
    }
}

// MARK: - Loading
extension NewChatTableViewCell {
    
    private func loadImage(for email: String) {
        let path = "images/\(email)_profile_picture.png"
        
        StorageManager.shared.downloadURL(for: path) { [weak self] result in
            switch result {
            case .success(let url):
                DispatchQueue.main.async {
                    self?.userImageView.sd_setImage(with: url)
                }
            case .failure(let error):
                print("failed to load image: \(error)")
            }
        }
    }
}
