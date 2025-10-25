//
//  ChatCellTableViewCell.swift
//  squad-generator-xib
//
//  Created by Adham Farid on 25/10/25.
//

import UIKit

class ChatCellTableViewCell: UITableViewCell {
    @IBOutlet weak var messageLabel: UILabel!
    
    private let checkmarkView = UIImageView()
    
    private var leadingConstraint: NSLayoutConstraint!
    private var trailingConstraint: NSLayoutConstraint!
    
    private let bubbleView = UIView()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        setupUI()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
    private func setupUI() {
        selectionStyle = .none
        contentView.backgroundColor = .clear
        
        bubbleView.layer.cornerRadius = 16
        bubbleView.layer.masksToBounds = true
        bubbleView.translatesAutoresizingMaskIntoConstraints = false
        
        messageLabel.numberOfLines = 0
        messageLabel.font = UIFont.systemFont(ofSize: 16)
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        
        
        checkmarkView.translatesAutoresizingMaskIntoConstraints = false
        checkmarkView.contentMode = .scaleAspectFit
        checkmarkView.tintColor = .systemBlue
        checkmarkView.image = UIImage(systemName: "checkmark")
        checkmarkView.isHidden = true
        
        bubbleView.addSubview(messageLabel)
        bubbleView.addSubview(checkmarkView)
        contentView.addSubview(bubbleView)
        
        // Padding inside the bubble
        NSLayoutConstraint.activate([
            messageLabel.topAnchor.constraint(equalTo: bubbleView.topAnchor, constant: 8),
            messageLabel.bottomAnchor.constraint(equalTo: bubbleView.bottomAnchor, constant: -8),
            messageLabel.leadingAnchor.constraint(equalTo: bubbleView.leadingAnchor, constant: 12),
            messageLabel.trailingAnchor.constraint(equalTo: bubbleView.trailingAnchor, constant: -12),
            
            checkmarkView.leadingAnchor.constraint(greaterThanOrEqualTo: bubbleView.leadingAnchor, constant: 8),
            checkmarkView.bottomAnchor.constraint(equalTo: bubbleView.bottomAnchor, constant: -4),
            checkmarkView.trailingAnchor.constraint(equalTo: bubbleView.trailingAnchor, constant: -6),
            checkmarkView.widthAnchor.constraint(equalToConstant: 14),
            checkmarkView.heightAnchor.constraint(equalToConstant: 14),
            
            bubbleView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 4),
            bubbleView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -4),
            bubbleView.widthAnchor.constraint(lessThanOrEqualTo: contentView.widthAnchor, multiplier: 0.75)
        ])
        
        // Left/right positioning
        leadingConstraint = bubbleView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10)
        trailingConstraint = bubbleView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10)
    }
    
    func configure(with message: ChatMessage) {
        messageLabel.text = message.text
        if message.isOutgoing {
            trailingConstraint.isActive = true
            leadingConstraint.isActive = false
            bubbleView.backgroundColor = .green
            messageLabel.textColor = .black
            checkmarkView.isHidden = false
            checkmarkView.tintColor = message.isSent ? .systemBlue : .systemGray3
            checkmarkView.image = UIImage(systemName: message.isSent ? "checkmark.circle.fill" : "checkmark.circle")
            
            NSLayoutConstraint.activate([
                messageLabel.trailingAnchor.constraint(equalTo: bubbleView.trailingAnchor, constant: -30)
            ])
        } else {
            leadingConstraint.isActive = true
            trailingConstraint.isActive = false
            bubbleView.backgroundColor = .lightGray
            messageLabel.textColor = .black
            checkmarkView.isHidden = true
        }
    }
    
}
