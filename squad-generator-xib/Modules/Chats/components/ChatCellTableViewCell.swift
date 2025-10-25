//
//  ChatCellTableViewCell.swift
//  squad-generator-xib
//
//  Created by Adham Farid on 25/10/25.
//

import UIKit

class ChatCellTableViewCell: UITableViewCell {
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var checkmarkStatus: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
    func configure(with message: ChatMessage) {
        messageLabel.text = message.text
        
        
        // Show checkmark only for outgoing + sent
        if message.isOutgoing {
            checkmarkStatus.isHidden = !message.isSent
        } else {
            checkmarkStatus.isHidden = true
        }
    }
    
}
