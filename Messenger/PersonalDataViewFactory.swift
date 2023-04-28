import UIKit

struct PersonalDataViewFactory {
    
    static func textField(placeholder: String) -> UITextField {
        let textField = UITextField()
        textField.layer.borderColor = UIColor.black.cgColor
        textField.layer.cornerRadius = Metrics.module * 2
        textField.layer.borderWidth = 1
        textField.leftView = UIView(frame: .init(x: 0, y: 0, width: 18, height: 0))
        textField.leftViewMode = .always
        textField.placeholder = placeholder
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }
    
    static func separatorView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .systemGray
        return view
    }
    
    static func actionButton() -> UIButton {
        let button = UIButton()
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = Metrics.halfModule * 3
        button.clipsToBounds = true
        button.backgroundColor = .black
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }
}

