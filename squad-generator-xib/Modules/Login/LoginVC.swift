//
//  LoginVC.swift
//  squad-generator-xib
//
//  Created by Adham Farid on 08/11/25.
//

import UIKit
import FirebaseAuth
import LocalAuthentication

class LoginVC: UIViewController {
    
    private let emailField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Email"
        tf.autocapitalizationType = .none
        tf.keyboardType = .emailAddress
        tf.borderStyle = .roundedRect
        return tf
    }()
    
    private let passwordField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Password"
        tf.isSecureTextEntry = true
        tf.borderStyle = .roundedRect
        return tf
    }()
    
    private let signInButton: UIButton = {
        let b = UIButton(type: .system)
        b.setTitle("Sign In", for: .normal)
        b.addTarget(self, action: #selector(signInTapped), for: .touchUpInside)
        return b
    }()
    
    private let createButton: UIButton = {
        let b = UIButton(type: .system)
        b.setTitle("Create Account", for: .normal)
        b.addTarget(self, action: #selector(createTapped), for: .touchUpInside)
        return b
    }()
    
    private let faceIdButton: UIButton = {
        let b = UIButton(type: .system)
        b.setTitle("Face ID", for: .normal)
        b.addTarget(self, action: #selector(faceIdTapped), for: .touchUpInside)
        return b
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Login"
        view.backgroundColor = .systemBackground
        [emailField, passwordField, signInButton, createButton, faceIdButton].forEach { v in
            v.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(v)
        }
        layout()
        // If already signed in, skip:
        if Auth.auth().currentUser != nil {
            goToHome()
        }
    }
    
    private func layout() {
        NSLayoutConstraint.activate([
            emailField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 40),
            emailField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            emailField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            passwordField.topAnchor.constraint(equalTo: emailField.bottomAnchor, constant: 12),
            passwordField.leadingAnchor.constraint(equalTo: emailField.leadingAnchor),
            passwordField.trailingAnchor.constraint(equalTo: emailField.trailingAnchor),
            
            signInButton.topAnchor.constraint(equalTo: passwordField.bottomAnchor, constant: 20),
            signInButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            createButton.topAnchor.constraint(equalTo: signInButton.bottomAnchor, constant: 8),
            createButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            faceIdButton.topAnchor.constraint(equalTo: createButton.bottomAnchor, constant: 8),
            faceIdButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
        ])
    }
    
    @objc private func signInTapped() {
        guard let email = emailField.text, let password = passwordField.text,
              !email.isEmpty, !password.isEmpty else {
            showAlert("Enter email and password")
            return
        }
        Auth.auth().signIn(withEmail: email, password: password) { [weak self] result, error in
            if let error = error {
                self?.showAlert(error.localizedDescription)
                return
            }
            self?.goToHome()
        }
    }
    
    @objc private func createTapped() {
        guard let email = emailField.text, let password = passwordField.text,
              !email.isEmpty, !password.isEmpty else {
            showAlert("Enter email and password")
            return
        }
        Auth.auth().createUser(withEmail: email, password: password) { [weak self] result, error in
            if let error = error {
                self?.showAlert(error.localizedDescription)
                return
            }
            self?.goToHome()
        }
    }
    
    @objc private func faceIdTapped() {
        biometricsAuthentication()
    }
    
    func biometricsAuthentication() {
        let context = LAContext()
        var error : NSError? = nil
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: "Access to your app") { success, error in
                DispatchQueue.main.async {
                    if success {
                        self.goToHome()
                    } else {
                        self.showAlert("Authentication failed")
                    }
                }
            }
        } else {
            self.showAlert("Unavailable")
        }
    }
    
    private func goToHome() {
        // Replace with your Home VC
        let vc = RootTabBarController()
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true)
    }
    
    private func showAlert(_ message: String) {
        let alert = UIAlertController(title: "Auth", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
