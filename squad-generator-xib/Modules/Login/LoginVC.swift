//
//  LoginVC.swift
//  squad-generator-xib
//
//  Created by Adham Farid on 08/11/25.
//

import UIKit
import FirebaseAuth
import LocalAuthentication

// MARK: - LoginVC

class LoginVC: UIViewController {
    
    // Simple feature flags in UserDefaults
    private let kBiometricEnabled = "biometricLoginEnabled"
    private let kBiometricEmail   = "biometricLoginEmail"
    
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
    
    // This button either enables Face ID (if not set up) or performs Face ID login.
    private let faceIdButton: UIButton = {
        let b = UIButton(type: .system)
        b.setTitle("Use Face ID", for: .normal)
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
        
        // If Firebase has a session, optionally gate with Face ID before proceeding
        if let _ = Auth.auth().currentUser {
            if UserDefaults.standard.bool(forKey: kBiometricEnabled) {
                authenticateUser(reason: "Unlock your account") { [weak self] ok in
                    ok ? self?.goToHome() : self?.showAlert("Authentication cancelled")
                }
            } else {
                goToHome()
            }
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
    
    // MARK: - Email/Password
    
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
            self?.offerEnableBiometrics(email: email, password: password)
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
            self?.offerEnableBiometrics(email: email, password: password)
            self?.goToHome()
        }
    }
    
    private func offerEnableBiometrics(email: String, password: String) {
        guard biometricAvailable() else { return }
        // Only prompt if not already enabled for this user
        if UserDefaults.standard.bool(forKey: kBiometricEnabled) == false {
            let alert = UIAlertController(
                title: "Enable Face ID?",
                message: "Use Face ID or passcode next time to sign in automatically.",
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: "Not now", style: .cancel))
            alert.addAction(UIAlertAction(title: "Enable", style: .default, handler: { _ in
                do {
                    try SecureKeychain.savePassword(password, account: email)
                    UserDefaults.standard.set(true, forKey: self.kBiometricEnabled)
                    UserDefaults.standard.set(email, forKey: self.kBiometricEmail)
                } catch {
                    self.showAlert("Could not enable Face ID: \(error.localizedDescription)")
                }
            }))
            present(alert, animated: true)
        }
    }
    
    // MARK: - Face ID / Passcode
    
    @objc private func faceIdTapped() {
        // If already enabled, try to unlock and (if signed out) auto sign-in.
        let enabled = UserDefaults.standard.bool(forKey: kBiometricEnabled)
        if enabled {
            biometricLoginFlow()
        } else {
            // Let user enable via current fields (requires entered email+password)
            guard let email = emailField.text, let password = passwordField.text,
                  !email.isEmpty, !password.isEmpty else {
                showAlert("Enter email & password first, then tap Face ID to enable.")
                return
            }
            do {
                try SecureKeychain.savePassword(password, account: email)
                UserDefaults.standard.set(true, forKey: kBiometricEnabled)
                UserDefaults.standard.set(email, forKey: kBiometricEmail)
                showAlert("Face ID enabled")
            } catch {
                showAlert("Could not enable Face ID: \(error.localizedDescription)")
            }
        }
    }
    
    private func biometricLoginFlow() {
        authenticateUser(reason: "Sign in with Face ID") { [weak self] ok in
            guard let self else { return }
            guard ok else {
                self.showAlert("Authentication cancelled")
                return
            }
            
            if let _ = Auth.auth().currentUser {
                // Session alive → just proceed
                self.goToHome()
                return
            }
            
            // Session gone → auto sign-in with Keychain credential
            guard let email = UserDefaults.standard.string(forKey: self.kBiometricEmail) else {
                self.showAlert("No stored account")
                return
            }
            do {
                let password = try SecureKeychain.loadPassword(account: email, prompt: "Use Face ID to sign in")
                Auth.auth().signIn(withEmail: email, password: password) { result, error in
                    if let error = error {
                        self.showAlert(error.localizedDescription)
                        return
                    }
                    self.goToHome()
                }
            } catch {
                self.showAlert("Could not retrieve credential")
            }
        }
    }
    
    private func biometricAvailable() -> Bool {
        let ctx = LAContext()
        var err: NSError?
        // Use deviceOwnerAuthentication for biometric + passcode fallback
        return ctx.canEvaluatePolicy(.deviceOwnerAuthentication, error: &err)
    }
    
    private func authenticateUser(reason: String, completion: @escaping (Bool) -> Void) {
        let ctx = LAContext()
        ctx.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: reason) { success, _ in
            DispatchQueue.main.async { completion(success) }
        }
    }
    
    func disableBiometricLogin() {
        if let email = UserDefaults.standard.string(forKey: kBiometricEmail) {
            SecureKeychain.deletePassword(account: email)   // remove stored password
        }
        UserDefaults.standard.removeObject(forKey: kBiometricEnabled)
        UserDefaults.standard.removeObject(forKey: kBiometricEmail)
    }
    
    // MARK: - Navigation & UI
    
    private func goToHome() {
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
