import UIKit

final class LoginView: UIView {
    
    private let textLabel: UILabel = {
        let label = UILabel()
        label.text = "Welcome back! Glad to see you, Again!"
        label.numberOfLines = 2
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 30)
        return label
    }()
    
    lazy var emailTextField = PersonalDataViewFactory.textField(placeholder: "Enter your email")
    lazy var passwordTextField = PersonalDataViewFactory.textField(placeholder: "Enter your password")
    
    let socialNetworksView = LoginWithGoogleView()
    
    lazy var loginButton = PersonalDataViewFactory.actionButton()
    
    private let haveAccountLabel: UILabel = {
        let label = UILabel()
        label.text = "Don't have an account?"
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 16)
        return label
    }()
    
    let registerButton: UIButton = {
        let button = UIButton()
        button.setTitle("Register Now", for: .normal)
        button.setTitleColor(.systemBlue, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        return button
    }()
    
    private let haveAccountStackView: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .horizontal
        stack.spacing = Metrics.halfModule 
        return stack
    }()
    
    private let textFieldStackView: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.spacing = Metrics.module * 2
        return stack
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
            
        backgroundColor = .white
        
        setupLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupLayout() {
        setupTextLabelLayout()
        setupTextFieldStackViewLayout()
        setupLoginButtonLayout()
        setupSocialNetworkslayout()
        setupHaveAccountStackViewLayout()
    }
    
    private func setupTextLabelLayout() {
        addSubview(textLabel)
        
        textLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Metrics.halfModule * 5).isActive = true
        textLabel.topAnchor.constraint(equalTo: topAnchor, constant: Metrics.module * 15).isActive = true
        textLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -Metrics.halfModule * 5).isActive = true
    }
    
    private func setupTextFieldStackViewLayout() {
        addSubview(textFieldStackView)
        
        textFieldStackView.addArrangedSubview(emailTextField)
        textFieldStackView.addArrangedSubview(passwordTextField)
        
        textFieldStackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Metrics.halfModule * 5).isActive = true
        textFieldStackView.topAnchor.constraint(equalTo: textLabel.bottomAnchor, constant: Metrics.module * 4).isActive = true
        textFieldStackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -Metrics.halfModule * 5).isActive = true
        
        emailTextField.heightAnchor.constraint(equalToConstant: Metrics.module * 7).isActive = true

        passwordTextField.heightAnchor.constraint(equalToConstant: Metrics.module * 7).isActive = true
    }
    
    private func setupLoginButtonLayout() {
        addSubview(loginButton)
        
        loginButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Metrics.halfModule * 5).isActive = true
        loginButton.topAnchor.constraint(equalTo: textFieldStackView.bottomAnchor, constant: Metrics.halfModule * 5).isActive = true
        loginButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -Metrics.halfModule * 5).isActive = true
        loginButton.heightAnchor.constraint(equalToConstant: Metrics.module * 7).isActive = true
    }
    
    private func setupSocialNetworkslayout() {
        socialNetworksView.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(socialNetworksView)
        
        socialNetworksView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        socialNetworksView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        socialNetworksView.topAnchor.constraint(equalTo: loginButton.bottomAnchor).isActive = true
    }
    
    private func setupHaveAccountStackViewLayout() {
        addSubview(haveAccountStackView)
        
        haveAccountStackView.addArrangedSubview(haveAccountLabel)
        haveAccountStackView.addArrangedSubview(registerButton)
        
        haveAccountStackView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -Metrics.doubleModule).isActive = true
        haveAccountStackView.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
    }
}
