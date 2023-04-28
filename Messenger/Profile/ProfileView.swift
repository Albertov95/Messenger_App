import UIKit

final class ProfileView: UIView {
    
    var userImage: UIImage? {
        didSet {
            userImageView.image = userImage
        }
    }
    
    var email: String? {
        didSet {
            emailLabel.text = email
        }
    }
    
    // MARK: - UI Elements
    private let userImageView: UIImageView = {
        let image = UIImageView()
        image.translatesAutoresizingMaskIntoConstraints = false
        image.image = UIImage(named: "user")
        image.isUserInteractionEnabled = true
        image.clipsToBounds = true
        image.layer.cornerRadius = Metrics.halfModule * 10
        image.layer.borderWidth = 1
        return image
    }()
    
    private let emailLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 16)
        return label
    }()
    
    lazy var logOutButton = PersonalDataViewFactory.actionButton()
    
    // MARK: - Init
    init() {
        super.init(frame: .zero)
            
        backgroundColor = .white
        
        setupLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Layout
    private func setupLayout() {
        setupUserImageViewLayout()
        setupEmailLabelLayout()
        setupLogOutButtonLayout()
    }
    
    private func setupUserImageViewLayout() {
        addSubview(userImageView)
        
        userImageView.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        userImageView.topAnchor.constraint(equalTo: topAnchor, constant: Metrics.halfModule * 25).isActive = true
        userImageView.widthAnchor.constraint(equalToConstant: Metrics.halfModule * 20).isActive = true
        userImageView.heightAnchor.constraint(equalToConstant: Metrics.halfModule * 20).isActive = true
    }
    
    private func setupEmailLabelLayout() {
        addSubview(emailLabel)
        
        emailLabel.topAnchor.constraint(equalTo: userImageView.bottomAnchor, constant: Metrics.module * 3).isActive = true
        emailLabel.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
    }
    
    private func setupLogOutButtonLayout() {
        addSubview(logOutButton)
        
        logOutButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Metrics.halfModule * 5).isActive = true
        logOutButton.topAnchor.constraint(equalTo: emailLabel.bottomAnchor, constant: Metrics.halfModule * 10).isActive = true
        logOutButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -Metrics.halfModule * 5).isActive = true
        logOutButton.heightAnchor.constraint(equalToConstant: Metrics.module * 7).isActive = true
    }
}
