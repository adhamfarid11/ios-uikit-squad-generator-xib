//
//  ViewController.swift
//  squad-generator
//
//  Created by Adham Farid on 04/10/25.
//

import UIKit


// MARK: - ViewController Implementation
class ViewController: UIViewController, GeneratorView {

    // MARK: - Outlets
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var generateButton: UIButton!
    
    // MARK: - Properties
    var presenter: GeneratorPresenting?

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemBackground
        title = "Generator"

        generateButton?.addTarget(self, action: #selector(didTapGenerate), for: .touchUpInside)

        presenter?.viewDidLoad()
    }

    // MARK: - Actions
    @objc private func didTapGenerate() {
        // Delegate action handling to the presenter
        presenter?.didTapGenerate()
    }

    // MARK: - GeneratorView
    
    /// Updates the name label with a new name using a cross-dissolve transition.
    func show(name: String) {
        // FIX: Access nameLabel directly. The crash risk is here if the outlet is missing.
        UIView.transition(with: nameLabel, duration: 0.2, options: .transitionCrossDissolve) {
            self.nameLabel.text = name
        }
    }
}
