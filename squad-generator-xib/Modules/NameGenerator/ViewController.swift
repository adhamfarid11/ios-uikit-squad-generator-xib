//
//  ViewController.swift
//  squad-generator
//
//  Created by Adham Farid on 04/10/25.
//

import UIKit
import UserNotifications

// MARK: - ViewController Implementation
class ViewController: UIViewController, GeneratorView, UNUserNotificationCenterDelegate {

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
        
        // Notification setup
        UNUserNotificationCenter.current().delegate = self
        requestNotificationPermission()
    }

    // MARK: - Actions
    @objc private func didTapGenerate() {
        // Delegate to presenter
        presenter?.didTapGenerate()
        
        // Fire an immediate local notification
        scheduleImmediateNotification()
    }

    // MARK: - GeneratorView
    func show(name: String) {
        UIView.transition(with: nameLabel, duration: 0.2, options: .transitionCrossDissolve) {
            self.nameLabel.text = name
        }
    }

    // MARK: - Notification Helpers

    private func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if let error = error {
                print("Notification auth error: \(error)")
            }
            print("Notifications granted: \(granted)")
        }
    }

    private func scheduleImmediateNotification() {
        let content = UNMutableNotificationContent()
        content.title = "Button Pressed!"
        content.body = "You pressed the Generate button."
        content.sound = .default

        // Trigger immediately (1 second delay for safety)
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)

        let id = UUID().uuidString
        let request = UNNotificationRequest(identifier: id, content: content, trigger: trigger)

        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling notification: \(error)")
            } else {
                print("Immediate notification scheduled.")
            }
        }
    }

    // Show notification even if app is in foreground
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.banner, .sound, .badge, .list])
    }
}
