//
//  ViewController.swift
//  squad-generator
//
//  Created by Adham Farid on 04/10/25.
//

import UIKit

final class ViewController: UIViewController, GeneratorView {

    var presenter: GeneratorPresenting?

    private let nameLabel: UILabel = {
        let label = UILabel()
        label.text = ""
        label.font = .systemFont(ofSize: 28, weight: .bold)
        label.textAlignment = .center
        label.numberOfLines = 2
        return label
    }()

    private let generateButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Generate Name", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 20, weight: .semibold)
        button.backgroundColor = .systemBlue
        button.tintColor = .white
        button.layer.cornerRadius = 12
        button.contentEdgeInsets = UIEdgeInsets(top: 12, left: 24, bottom: 12, right: 24)
        return button
    }()

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "Generator"

        view.addSubview(nameLabel)
        view.addSubview(generateButton)

        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        generateButton.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            nameLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            nameLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -60),
            nameLabel.leadingAnchor.constraint(greaterThanOrEqualTo: view.leadingAnchor, constant: 20),
            nameLabel.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -20),

            generateButton.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 40),
            generateButton.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])

        generateButton.addTarget(self, action: #selector(didTapGenerate), for: .touchUpInside)

        presenter?.viewDidLoad()
    }

    // MARK: - Actions
    @objc private func didTapGenerate() {
        presenter?.didTapGenerate()
    }

    // MARK: - GeneratorView
    func show(name: String) {
        UIView.transition(with: nameLabel, duration: 0.2, options: .transitionCrossDissolve) {
            self.nameLabel.text = name
        }
    }
}
