import UIKit
import GoogleSignIn

final class LoginWithGoogleView: UIView {
    
    private lazy var leftSeparator = PersonalDataViewFactory.separatorView()
    private lazy var rightSeparator = PersonalDataViewFactory.separatorView()

    lazy var googleButton = GIDSignInButton()
    
    private let loginWithLabel: UILabel = {
        let label = UILabel()
        label.text = "Or Login with"
        label.font = .systemFont(ofSize: 16)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // MARK: - Init
    init() {
        super.init(frame: .zero)
        
        setupLayout()
        
        translatesAutoresizingMaskIntoConstraints = false
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Layout
    private func setupLayout() {
        setupHeaderLayout()
        setupGoogleButtonLayout()
    }
    
    private func setupHeaderLayout() {
        addSubview(leftSeparator)
        addSubview(rightSeparator)
        addSubview(loginWithLabel)
        
        leftSeparator.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Metrics.halfModule * 5).isActive = true
        leftSeparator.trailingAnchor.constraint(equalTo: loginWithLabel.leadingAnchor, constant: -Metrics.halfModule * 3).isActive = true
        leftSeparator.heightAnchor.constraint(equalToConstant: 1).isActive = true
        leftSeparator.centerYAnchor.constraint(equalTo: loginWithLabel.centerYAnchor).isActive = true
        
        loginWithLabel.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        loginWithLabel.topAnchor.constraint(equalTo: topAnchor, constant: Metrics.halfModule * 9).isActive = true
        
        rightSeparator.leadingAnchor.constraint(equalTo: loginWithLabel.trailingAnchor, constant: Metrics.halfModule * 3).isActive = true
        rightSeparator.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -Metrics.halfModule * 5).isActive = true
        rightSeparator.heightAnchor.constraint(equalToConstant: 1).isActive = true
        rightSeparator.centerYAnchor.constraint(equalTo: loginWithLabel.centerYAnchor).isActive = true
    }
    
    private func setupGoogleButtonLayout() {
        googleButton.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(googleButton)
        
        googleButton.topAnchor.constraint(equalTo: loginWithLabel.bottomAnchor, constant: Metrics.doubleModule).isActive = true
        googleButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Metrics.doubleModule).isActive = true
        googleButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -Metrics.doubleModule).isActive = true
        googleButton.heightAnchor.constraint(equalToConstant: Metrics.module * 7).isActive = true
        googleButton.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
    }
}
