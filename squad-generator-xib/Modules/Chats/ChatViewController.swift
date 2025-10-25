//
//  ChatViewController.swift
//  squad-generator-xib
//
//  Created by Adham Farid on 23/10/25.
//

import UIKit
import Foundation

class ChatViewController: UIViewController {
    
    @IBOutlet weak var mainStackView: UIStackView!
    @IBOutlet weak var sendBtnView: UIView!
    @IBOutlet weak var textFieldView: UITextView!
    @IBOutlet weak var inputFieldStackView: UIStackView!
    @IBOutlet weak var chatTableView: UITableView!
    
    var items: [ChatMessage] = [
        .init(text: "Hello!", isOutgoing: true,  isSent: true),
        .init(text: "Hi there 👋", isOutgoing: false, isSent: true)
    ]
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        setupView()
        setupAction()
        chatTableView.delegate = self
        chatTableView.dataSource = self
        textFieldView.delegate = self
        
        let nib = UINib(nibName: "ChatCellTableViewCell", bundle: nil)
        chatTableView.register(nib, forCellReuseIdentifier: "ChatCell")
    }
    
    func setupView() {
        view.backgroundColor = .systemBackground
        navigationItem.title = "Chats with LeWin"
        navigationItem.subtitle = "Konakting..."
        
        sendBtnView.layer.cornerRadius = 20
        sendBtnView.clipsToBounds = true
        
        textFieldView.textContainerInset = UIEdgeInsets(top: 16, left: 10, bottom: 12, right: 10)
        textFieldView.layer.cornerRadius = 20
        textFieldView.borderStyle = .none
        textFieldView.layer.borderWidth = 2
        textFieldView.layer.borderColor = UIColor.lightGray.cgColor
        textFieldView.clipsToBounds = true
        textFieldView.text = "Send message..."
        textFieldView.textColor = UIColor.lightGray
        
        chatTableView.separatorStyle = .none
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
    
    
    @objc func sendMessage() {
        UIView.animate(withDuration: 0.1, animations: {
            self.sendBtnView.alpha = 0.5
        }) { _ in
            UIView.animate(withDuration: 0.1) {
                self.sendBtnView.alpha = 1.0
            }
        }
        
        guard let message = textFieldView.text, !message.isEmpty else {
            print("No message to send")
            return
        }
        
        self.sendMessageLogic(message)
        
        textFieldView.text = ""
        textFieldView.resignFirstResponder()
    }
    
    func sendMessageLogic(_ text: String) {
        guard !text.isEmpty else { return }
        let newMsg = ChatMessage(text: text, isOutgoing: true, isSent: false)
        items.append(newMsg)
        
        let newIndex = IndexPath(row: items.count - 1, section: 0)
        chatTableView.insertRows(at: [newIndex], with: .automatic)
        chatTableView.scrollToRow(at: newIndex, at: .bottom, animated: true)
        
        // Simulate send success → update isSent and reload that row
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.items[self.items.count - 1] = ChatMessage(text: text, isOutgoing: true, isSent: true)
            self.chatTableView.reloadRows(at: [newIndex], with: .none)
        }
    }
}

// MARK: - Keyboard
extension ChatViewController {
    @objc func keyboardWillShow(sender: NSNotification) {
        guard let userInfo = sender.userInfo,
              let keyboardFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue,
              let duration = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? TimeInterval
        else {return}
        
        let kbFrameInView = view.convert(keyboardFrame.cgRectValue, from: view.window)
        
        let keyboardTopY = kbFrameInView.origin.y
        let convertedTextFieldFrame = view.convert(inputFieldStackView.frame, from: inputFieldStackView.superview)
        let textFieldBottomY = convertedTextFieldFrame.origin.y + convertedTextFieldFrame.size.height
        
        if textFieldBottomY > keyboardTopY {
            let overlap = max(0, view.bounds.maxY - keyboardTopY - convertedTextFieldFrame.size.height)
            
            UIView.animate(withDuration: duration) {
                self.additionalSafeAreaInsets.bottom = overlap
                self.view.layoutIfNeeded()
            }
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        UIView.animate(withDuration: 0.3) {
            self.additionalSafeAreaInsets.bottom = 0
            self.view.layoutIfNeeded()
        }
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}

extension ChatViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        sendBtnView.isUserInteractionEnabled = !textView.text.isEmpty
        sendBtnView.alpha = !textView.text.isEmpty ? 1 : 0.5
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == UIColor.lightGray {
            textView.text = nil
            textView.textColor = UIColor.black
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "Send message..."
            textView.textColor = UIColor.lightGray
        }
    }
}

extension ChatViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ChatCell",
                                                 for: indexPath) as! ChatCellTableViewCell
        let msg = items[indexPath.row]
        cell.configure(with: msg)
        return cell
    }
}
