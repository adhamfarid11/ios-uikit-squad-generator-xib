//
//  ProfileVC.swift
//  squad-generator-xib
//
//  Created by Adham Farid on 08/11/25.
//

import UIKit
import FirebaseAuth

final class ProfileVC: UIViewController {

  // Reuse the same keys used in LoginVC
  private let kBiometricEnabled = "biometricLoginEnabled"
  private let kBiometricEmail   = "biometricLoginEmail"

  private let emailTitle: UILabel = {
    let l = UILabel()
    l.text = "Email"
    l.font = .boldSystemFont(ofSize: 16)
    l.translatesAutoresizingMaskIntoConstraints = false
    return l
  }()

  private let emailValue: UILabel = {
    let l = UILabel()
    l.font = .systemFont(ofSize: 16)
    l.textColor = .secondaryLabel
    l.translatesAutoresizingMaskIntoConstraints = false
    return l
  }()

  private let faceIDLabel: UILabel = {
    let l = UILabel()
    l.text = "Login with Face ID"
    l.font = .systemFont(ofSize: 16)
    l.translatesAutoresizingMaskIntoConstraints = false
    return l
  }()

  private let faceIDSwitch: UISwitch = {
    let s = UISwitch()
    s.translatesAutoresizingMaskIntoConstraints = false
    return s
  }()

  override func viewDidLoad() {
    super.viewDidLoad()
    title = "Profile"
    view.backgroundColor = .systemBackground
    setupUI()
    bind()
    refresh()
  }

  private func setupUI() {
    view.addSubview(emailTitle)
    view.addSubview(emailValue)
    view.addSubview(faceIDLabel)
    view.addSubview(faceIDSwitch)

    NSLayoutConstraint.activate([
      emailTitle.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
      emailTitle.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),

      emailValue.centerYAnchor.constraint(equalTo: emailTitle.centerYAnchor),
      emailValue.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),

      faceIDLabel.topAnchor.constraint(equalTo: emailTitle.bottomAnchor, constant: 32),
      faceIDLabel.leadingAnchor.constraint(equalTo: emailTitle.leadingAnchor),

      faceIDSwitch.centerYAnchor.constraint(equalTo: faceIDLabel.centerYAnchor),
      faceIDSwitch.trailingAnchor.constraint(equalTo: emailValue.trailingAnchor),
    ])
  }

  private func bind() {
    faceIDSwitch.addTarget(self, action: #selector(faceIDChanged(_:)), for: .valueChanged)
  }

  private func refresh() {
    emailValue.text = Auth.auth().currentUser?.email ?? "Unknown"
    faceIDSwitch.isOn = UserDefaults.standard.bool(forKey: kBiometricEnabled)
  }

  @objc private func faceIDChanged(_ sender: UISwitch) {
    guard let email = Auth.auth().currentUser?.email else {
      sender.isOn = false
      toast("No signed-in user")
      return
    }

    if sender.isOn {
      // Enable → ask once for password to store securely
      let ac = UIAlertController(title: "Enable Face ID Login",
                                 message: "Enter your password to secure it with Face ID/Passcode.",
                                 preferredStyle: .alert)
      ac.addTextField { tf in
        tf.placeholder = "Password"
        tf.isSecureTextEntry = true
      }
      ac.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { _ in
        sender.isOn = false
      }))
      ac.addAction(UIAlertAction(title: "Enable", style: .default, handler: { [weak self] _ in
        guard let self else { return }
        let pwd = ac.textFields?.first?.text ?? ""
        guard !pwd.isEmpty else {
          sender.isOn = false
          self.toast("Password required")
          return
        }
        do {
          try SecureKeychain.savePassword(pwd, account: email)
          UserDefaults.standard.set(true, forKey: self.kBiometricEnabled)
          UserDefaults.standard.set(email, forKey: self.kBiometricEmail)
          self.toast("Face ID login enabled")
        } catch {
          sender.isOn = false
          self.toast("Could not enable Face ID")
        }
      }))
      present(ac, animated: true)
    } else {
      // Disable → remove stored secret & flags
      SecureKeychain.deletePassword(account: email)
      UserDefaults.standard.removeObject(forKey: kBiometricEnabled)
      UserDefaults.standard.removeObject(forKey: kBiometricEmail)
      toast("Face ID login disabled")
    }
  }

  // Small inline helper
  private func toast(_ msg: String) {
    let ac = UIAlertController(title: nil, message: msg, preferredStyle: .alert)
    present(ac, animated: true)
    DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) { [weak ac] in ac?.dismiss(animated: true) }
  }
}
