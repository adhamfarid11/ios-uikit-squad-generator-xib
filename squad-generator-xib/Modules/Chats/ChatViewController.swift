//
//  ChatViewController.swift
//  squad-generator-xib
//
//  Created by Adham Farid on 23/10/25.
//

import UIKit

class ChatViewController: UIViewController {
    
    @IBOutlet weak var mainStackView: UIStackView!
    @IBOutlet weak var sendBtnView: UIView!
    @IBOutlet weak var textField: UITextField!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        setupView()
        setupAction()
        textField.delegate = self
    }
    
    func setupView() {
        view.backgroundColor = .systemBackground
        navigationItem.title = "Chats with LeWin"
        
        sendBtnView.layer.cornerRadius = 20
        sendBtnView.clipsToBounds = true
        
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: textField.frame.height))
        textField.leftView = paddingView
        textField.rightView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: textField.frame.height))
        textField.rightViewMode = .always
        
        textField.leftViewMode = .always
        textField.layer.cornerRadius = 20
        textField.borderStyle = .none
        textField.layer.borderWidth = 2
        textField.layer.borderColor = UIColor.lightGray.cgColor
        textField.clipsToBounds = true
    }
    
    func setupAction() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
        
        sendBtnView.isUserInteractionEnabled = true
        let sendGesture = UITapGestureRecognizer(target: self, action: #selector(sendMessage))
        sendBtnView.addGestureRecognizer(sendGesture)

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillShow),
                                               name: UIResponder.keyboardWillShowNotification,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillHide),
                                               name: UIResponder.keyboardWillHideNotification,
                                               object: nil)
    }

    // MARK: Keyboard
    @objc func keyboardWillShow(sender: NSNotification) {
        guard let userInfo = sender.userInfo,
              let keyboardFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue
        else {return}
    
        let keyboardTopY = keyboardFrame.cgRectValue.origin.y
        let convertedTextFieldFrame = view.convert(textField.frame, from: textField.superview)
        let textFieldBottomY = convertedTextFieldFrame.origin.y + convertedTextFieldFrame.size.height
        
        if textFieldBottomY > keyboardTopY {
            let textBoxY = convertedTextFieldFrame.origin.y
            let newFrameY = (Int(textBoxY - keyboardTopY) as Int) * ~1
            view.frame.origin.y = CGFloat(newFrameY)
        }
    }
        
    @objc func keyboardWillHide(notification: NSNotification) {
        view.frame.origin.y = 0
    }
    
    @objc func sendMessage() {
        UIView.animate(withDuration: 0.1, animations: {
            self.sendBtnView.alpha = 0.5
        }) { _ in
            UIView.animate(withDuration: 0.1) {
                self.sendBtnView.alpha = 1.0
            }
        }
        
        guard let message = textField.text, !message.isEmpty else {
            print("No message to send")
            return
        }
        
        print("Sending message: \(message)")
        
        // TODO: Add your send logic here (e.g. append to array, API call, etc.)
        
        // Clear the text field
        textField.text = ""
        
        // Dismiss keyboard
        textField.resignFirstResponder()
    }
    
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}

extension ChatViewController: UITextFieldDelegate {

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        sendMessage()
        return true
    }
}
