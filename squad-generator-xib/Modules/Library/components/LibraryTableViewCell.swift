//
//  LibraryTableViewCell.swift
//  squad-generator-xib
//
//  Created by Adham Farid on 29/10/25.
//

import UIKit

class LibraryTableViewCell: UITableViewCell {
    
    // MARK: - UI Elements
    private let titleLabel = UILabel()
    private let authorLabel = UILabel()
    private let yearLabel = UILabel()
    
    // MARK: - Init
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
    }
    
    // MARK: - Setup UI
    private func setupViews() {
        selectionStyle = .none
        contentView.backgroundColor = .systemBackground
        
        // Configure labels
        titleLabel.font = UIFont.boldSystemFont(ofSize: 18)
        titleLabel.textColor = .label
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        authorLabel.font = UIFont.systemFont(ofSize: 15)
        authorLabel.textColor = .secondaryLabel
        authorLabel.translatesAutoresizingMaskIntoConstraints = false
        
        yearLabel.font = UIFont.systemFont(ofSize: 14)
        yearLabel.textColor = .tertiaryLabel
        yearLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // Add to content view
        contentView.addSubview(titleLabel)
        contentView.addSubview(authorLabel)
        contentView.addSubview(yearLabel)
        
        // MARK: - Layout constraints
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            authorLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            authorLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            authorLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
            
            yearLabel.topAnchor.constraint(equalTo: authorLabel.bottomAnchor, constant: 4),
            yearLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            yearLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
            yearLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8)
        ])
    }
    
    // MARK: - Configure Cell
    func configure(with book: Book) {
        titleLabel.text = book.title
        authorLabel.text = "by \(book.author?.name ?? "author not available")"
        yearLabel.text = "Published: \(book.year)"
    }
}
