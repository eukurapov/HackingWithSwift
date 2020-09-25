//
//  ViewController.swift
//  Project28
//
//  Created by Eugene Kurapov on 25.09.2020.
//

import UIKit
import LocalAuthentication

class ViewController: UIViewController {
    
    @IBOutlet weak var secret: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Nothing to see here!"
        
        NotificationCenter.default.addObserver(self, selector: #selector(layoutForKeyboard), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(layoutForKeyboard), name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(saveSecret), name: UIApplication.willResignActiveNotification, object: nil)
    }
    
    @IBAction func authenticateTapped(_ sender: Any) {
        let context = LAContext()
        var error: NSError?
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { [weak self] success, error in
                DispatchQueue.main.async {
                    if success {
                        self?.loadSecret()
                    } else {
                        let ac = UIAlertController(title: "Failed to Authenticate", message: error?.localizedDescription, preferredStyle: .alert)
                        ac.addAction(UIAlertAction(title: "OK", style: .default))
                        self?.present(ac, animated: true)
                    }
                }
            }
        } else {
            let ac = UIAlertController(title: "Could not use authentication", message: error?.localizedDescription, preferredStyle: .alert)
            if isPasswordSet {
                ac.addAction(UIAlertAction(title: "Auth with password", style: .default, handler: authWithPassword))
            } else {
                ac.addAction(UIAlertAction(title: "Set password", style: .default, handler: setPassword))
            }
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            present(ac, animated: true)
        }
    }
    
    private var isPasswordSet: Bool {
        return KeychainWrapper.standard.hasValue(forKey: passwordKey)
    }
    
    private func authWithPassword(action: UIAlertAction) {
        let ac = UIAlertController(title: "Auth with Password", message: nil, preferredStyle: .alert)
        ac.addTextField { textField in
            textField.isSecureTextEntry = true
        }
        ac.addAction(UIAlertAction(title: "OK", style: .default) { _ in
            if let password = ac.textFields?.first?.text {
                if KeychainWrapper.standard.string(forKey: self.passwordKey) == password {
                    self.loadSecret()
                } else {
                    let errorAC = UIAlertController(title: "Failed to Authenticate", message: "Wrong password", preferredStyle: .alert)
                    errorAC.addAction(UIAlertAction(title: "OK", style: .default))
                    self.present(errorAC, animated: true)
                }
            }
        })
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(ac, animated: true)
    }
    
    private func setPassword(action: UIAlertAction) {
        let ac = UIAlertController(title: "Auth with Password", message: nil, preferredStyle: .alert)
        ac.addTextField { textField in
            textField.isSecureTextEntry = true
        }
        ac.addAction(UIAlertAction(title: "OK", style: .default) { _ in
            if let password = ac.textFields?.first?.text, password.trimmingCharacters(in: .whitespaces).isEmpty == false {
                KeychainWrapper.standard.set(password, forKey: self.passwordKey)
            }
        })
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(ac, animated: true)
    }
    
    private func loadSecret() {
        secret.isHidden = false
        secret.text = KeychainWrapper.standard.string(forKey: secretKey)
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(saveSecret))
    }
    
    @objc
    private func saveSecret() {
        guard secret.isHidden == false else { return }
        secret.resignFirstResponder()
        secret.isHidden = true
        navigationItem.rightBarButtonItem = nil
        KeychainWrapper.standard.set(secret.text, forKey: secretKey)
    }
    
    @objc
    private func layoutForKeyboard(notification: Notification) {
        guard let keyboardValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }
        let keyboardScreenEndFrame = keyboardValue.cgRectValue
        let keyboardViewEndFrame = view.convert(keyboardScreenEndFrame, from: view.window)

        var contentInset = secret.contentInset
        if notification.name == UIResponder.keyboardWillHideNotification {
            contentInset.bottom = .zero
        } else {
            contentInset.bottom = keyboardViewEndFrame.height - view.safeAreaInsets.bottom
        }
        secret.contentInset = contentInset
        
        secret.scrollIndicatorInsets = secret.contentInset
        let selectedRange = secret.selectedRange
        secret.scrollRangeToVisible(selectedRange)
    }
    
    // MARK: - Constant Values
    
    private let secretKey: String = "SecretKey"
    private let passwordKey: String = "SecretPassword"
    
    private let reason: String = "Auth to see the secret"
    
}

