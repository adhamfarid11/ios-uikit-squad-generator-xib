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
    
    var messages: [ChatMessage] = [
        .init(text: "Hello!", isOutgoing: true,  isSent: true),
        .init(text: "Hi there 👋", isOutgoing: false, isSent: true)
    ]
    
    private let presenter = ChatPresenter()
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        setupView()
        setupAction()
        chatTableView.delegate = self
        chatTableView.dataSource = self
        textFieldView.delegate = self
        
        let nib = UINib(nibName: "ChatCellTableViewCell", bundle: nil)
        chatTableView.register(nib, forCellReuseIdentifier: "ChatCell")
        
        presenter.delegate = self
        presenter.start()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
        presenter.stop()
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
        
        self.appendMessages(message, isOutgoing: true)
        presenter.sendMessage(message)
        
        textFieldView.text = ""
        textFieldView.resignFirstResponder()
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
        return messages.count
    }
    
    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ChatCell",
                                                 for: indexPath) as! ChatCellTableViewCell
        let msg = messages[indexPath.row]
        cell.configure(with: msg)
        return cell
    }
}

extension ChatViewController: ChatPresenterDelegate {
    func disableSendBtnView() {
        sendBtnView.isUserInteractionEnabled = false
        sendBtnView.alpha = 0.5
    }
    
    func enableSendBtnView() {
        sendBtnView.isUserInteractionEnabled = true
        sendBtnView.alpha = 1
    }
    
    func chatPresenter(_ presenter: ChatPresenter, didChange state: ChatConnectionState) {
        DispatchQueue.main.async {
            switch state {
            case .idle:
                self.navigationItem.subtitle = "Idle"
                self.disableSendBtnView()
                
            case .connecting:
                self.navigationItem.subtitle = "Connecting..."
                self.disableSendBtnView()
                
            case .reconnecting(let attempt):
                self.navigationItem.subtitle = "Reconnecting (\(attempt))..."
                self.showSnackbar(message: "Reconnecting!", backgroundColor: .systemBlue)
                self.disableSendBtnView()
                
            case .connected:
                self.navigationItem.subtitle = ""
                self.enableSendBtnView()
                
            case .failed(let error):
                self.navigationItem.subtitle = "Connection failed: \(error)"
                self.showSnackbar(message: "Connection failed: \(error)", backgroundColor: .systemRed)
                self.disableSendBtnView()
                
            case .closed(let error):
                if let error = error {
                    self.navigationItem.subtitle = "Closed: \(error)"
                } else {
                    self.navigationItem.subtitle = "Connection closed"
                }
                self.showSnackbar(message: "Connection Closed!", backgroundColor: .systemRed)
                self.disableSendBtnView()
            }
        }
        
    }
    
    func didReceiveChatMessages(_ messages: String) {
        DispatchQueue.main.async { [weak self] in
            self?.appendMessages(messages, isOutgoing: false)
        }
    }
    
    private func appendMessages(_ newMsgs: String, isOutgoing: Bool = false, isSent: Bool = false) {
        let start = messages.count
        guard !newMsgs.isEmpty else { return }
        
        messages.append(ChatMessage(text: newMsgs, isOutgoing: isOutgoing, isSent: isSent))
        
        let end = messages.count
        let indexPaths = (start..<end).map { IndexPath(row: $0, section: 0) }
        
        DispatchQueue.main.async {
            self.chatTableView.performBatchUpdates({
                self.chatTableView.insertRows(at: indexPaths, with: .automatic)
            }, completion: { _ in
                if let last = indexPaths.last {
                    self.chatTableView.scrollToRow(at: last, at: .bottom, animated: true)
                }
            })
        }
    }
}

extension ChatViewController {
    func showSnackbar(
        message: String,
        backgroundColor: UIColor = .label,
        textColor: UIColor = .systemBackground,
        duration: TimeInterval = 2.0
    ) {
        // Remove any existing snackbar first
        view.subviews.filter { $0.tag == 9999 }.forEach { $0.removeFromSuperview() }
        
        // Snackbar container
        let snackbar = UIView()
        snackbar.tag = 9999
        snackbar.backgroundColor = backgroundColor
        snackbar.layer.cornerRadius = 10
        snackbar.layer.masksToBounds = true
        snackbar.alpha = 0

        // Label inside snackbar
        let label = UILabel()
        label.text = message
        label.textColor = textColor
        label.numberOfLines = 0
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 15, weight: .medium)
        label.translatesAutoresizingMaskIntoConstraints = false
        
        snackbar.addSubview(label)
        view.addSubview(snackbar)

        // Layout constraints
        snackbar.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: snackbar.topAnchor, constant: 12),
            label.bottomAnchor.constraint(equalTo: snackbar.bottomAnchor, constant: -12),
            label.leadingAnchor.constraint(equalTo: snackbar.leadingAnchor, constant: 16),
            label.trailingAnchor.constraint(equalTo: snackbar.trailingAnchor, constant: -16),

            snackbar.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            snackbar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: -150)
        ])

        // Animate in
        UIView.animate(withDuration: 0.3) {
            snackbar.alpha = 1
            snackbar.transform = CGAffineTransform(translationX: 0, y: 100)
        }

        // Hide after delay
        DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
            UIView.animate(withDuration: 0.3, animations: {
                snackbar.alpha = 0
                snackbar.transform = .identity
            }) { _ in
                snackbar.removeFromSuperview()
            }
        }
    }
}

