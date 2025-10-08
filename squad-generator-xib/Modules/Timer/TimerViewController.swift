//
//  TimerViewController.swift
//  squad-generator
//
//  Created by Adham Farid on 04/10/25.
//

import UIKit

final class TimerViewController: UIViewController {
    private let label = UILabel()
    private var endDate: Date?
    private var timer: Timer?

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        label.font = .monospacedDigitSystemFont(ofSize: 48, weight: .bold)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(label)
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])

        startCountdown(seconds: 90)
    }

    func startCountdown(seconds: TimeInterval) {
        endDate = Date().addingTimeInterval(seconds)
        updateLabel() // immediate
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            self?.updateLabel()
        }
        // Keep firing while scrolling/gestures:
        RunLoop.current.add(timer!, forMode: .common)
    }

    private func updateLabel() {
        guard let end = endDate else { return }
        let r = max(0, end.timeIntervalSinceNow)
        label.text = format(r)
        if r == 0 { timer?.invalidate() }
    }

    private func format(_ t: TimeInterval) -> String {
        let total = Int(t.rounded(.down))
        return String(format: "%02d:%02d", total / 60, total % 60)
    }

    deinit {
        timer?.invalidate()
    }
}
