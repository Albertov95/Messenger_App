import UIKit

final class RegisterView: UIView {
    
    // MARK: - UI Elements
    let userImageView: UIImageView = {
        let image = UIImageView()
        image.translatesAutoresizingMaskIntoConstraints = false
        image.image = UIImage(named: "user")
        image.isUserInteractionEnabled = true
        image.clipsToBounds = true
        image.layer.cornerRadius = Metrics.doubleModule * 3
        image.layer.borderWidth = 1
        return image
    }()
    
    lazy var usernameTextField = PersonalDataViewFactory.textField(placeholder: "Username")
    lazy var emailTextField = PersonalDataViewFactory.textField(placeholder: "Email")
    lazy var passwordTextField = PersonalDataViewFactory.textField(placeholder: "Password")
    lazy var confirmPasswordTextField = PersonalDataViewFactory.textField(placeholder: "Confirm password")
    
    lazy var registerButton = PersonalDataViewFactory.actionButton()
    
    private let haveAccountLabel: UILabel = {
        let label = UILabel()
        label.text = "Already have an account?"
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 16)
        return label
    }()
    
    let loginButton: UIButton = {
        let button = UIButton()
        button.setTitle("Login Now", for: .normal)
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
    
    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
            
        backgroundColor = .white
        
        setupLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Layout
    private func setupLayout() {
        setupUserImageLayout()
        setupTextFieldStackViewLayout()
        setupLoginButtonLayout()
        setupHaveAccountStackViewLayout()
    }
    
    private func setupUserImageLayout() {
        addSubview(userImageView)
        
        userImageView.topAnchor.constraint(equalTo: topAnchor, constant: Metrics.halfModule * 31).isActive = true
        userImageView.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        userImageView.heightAnchor.constraint(equalToConstant: Metrics.doubleModule * 6).isActive = true
        userImageView.widthAnchor.constraint(equalToConstant: Metrics.doubleModule * 6).isActive = true
    }

    private func setupTextFieldStackViewLayout() {
        addSubview(textFieldStackView)
        
        textFieldStackView.addArrangedSubview(usernameTextField)
        textFieldStackView.addArrangedSubview(emailTextField)
        textFieldStackView.addArrangedSubview(passwordTextField)
        textFieldStackView.addArrangedSubview(confirmPasswordTextField)
    
        textFieldStackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Metrics.halfModule * 5).isActive = true
        textFieldStackView.topAnchor.constraint(equalTo: topAnchor, constant: Metrics.halfModule * 59).isActive = true
        textFieldStackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -Metrics.halfModule * 5).isActive = true
        
        usernameTextField.heightAnchor.constraint(equalToConstant: Metrics.module * 7).isActive = true
        emailTextField.heightAnchor.constraint(equalToConstant: Metrics.module * 7).isActive = true
        passwordTextField.heightAnchor.constraint(equalToConstant: Metrics.module * 7).isActive = true
        confirmPasswordTextField.heightAnchor.constraint(equalToConstant: Metrics.module * 7).isActive = true
    }
    
    private func setupLoginButtonLayout() {
        addSubview(registerButton)
        
        registerButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Metrics.halfModule * 5).isActive = true
        registerButton.topAnchor.constraint(equalTo: textFieldStackView.bottomAnchor, constant: Metrics.halfModule * 5).isActive = true
        registerButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -Metrics.halfModule * 5).isActive = true
        registerButton.heightAnchor.constraint(equalToConstant: Metrics.module * 7).isActive = true
    }
    
    private func setupHaveAccountStackViewLayout() {
        addSubview(haveAccountStackView)
        
        haveAccountStackView.addArrangedSubview(haveAccountLabel)
        haveAccountStackView.addArrangedSubview(loginButton)
        
        haveAccountStackView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -Metrics.doubleModule).isActive = true
        haveAccountStackView.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
    }
}
