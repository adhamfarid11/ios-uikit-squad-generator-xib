//
//  BookNotificationService.swift
//  squad-generator-xib
//
//  Created by Adham Farid on 31/10/25.
//

import Foundation
import UserNotifications

final class BookNotificationService {
    static let shared = BookNotificationService()

    private var task: URLSessionWebSocketTask?
    private var active = false
    private let pingInterval: TimeInterval = 25
    private var endpoint: URL!

    private init() {}

    func start(with endpoint: URL) {
        guard !active else { return }
        self.endpoint = endpoint
        active = true
        requestNotificationAuthorization()
        connect()
    }

    func stop() {
        active = false
        task?.cancel(with: .goingAway, reason: "Stopped".data(using: .utf8))
        task = nil
    }

    // MARK: - Private

    private func connect() {
        guard active else { return }
        if task != nil { return }

        let t = URLSession.shared.webSocketTask(with: endpoint)
        task = t
        t.resume()

        schedulePing()
        receiveNext()
    }

    private func schedulePing() {
        guard active, let task else { return }
        DispatchQueue.main.asyncAfter(deadline: .now() + pingInterval) { [weak self] in
            guard let self, self.active else { return }
            task.sendPing { [weak self] error in
                if let error {
                    self?.handleError(error)
                    self?.reconnectSoon()
                } else {
                    self?.schedulePing()
                }
            }
        }
    }

    private func receiveNext() {
        task?.receive { [weak self] result in
            guard let self else { return }
            switch result {
            case .failure(let error):
                self.handleError(error)
                self.reconnectSoon()

            case .success(let message):
                self.handleMessage(message)
                self.receiveNext()
            }
        }
    }

    private func handleMessage(_ message: URLSessionWebSocketTask.Message) {
        switch message {
        case .string(let text):
            print("Received text:", text)
            postLocalNotification(title: "Book Update", body: text)

        case .data(let data):
            // Optional: if your server sometimes sends JSON data
            if let text = String(data: data, encoding: .utf8) {
                print("Received binary -> text:", text)
                postLocalNotification(title: "Book Update", body: text)
            } else {
                print("Received binary data (\(data.count) bytes)")
                postLocalNotification(title: "Book Update", body: "Received binary message (\(data.count) bytes)")
            }

        @unknown default:
            handleError(URLError(.badServerResponse))
        }
    }


    private func handleError(_ error: Error) {
        // Optional: log or post a diagnostic notification
         postLocalNotification(title: "Listener Error", body: error.localizedDescription)
    }

    private func reconnectSoon() {
        guard active else { return }
        task?.cancel()
        task = nil
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) { [weak self] in
            self?.connect()
        }
    }

    // MARK: - Local Notifications

    private func requestNotificationAuthorization() {
        let center = UNUserNotificationCenter.current()
        center.getNotificationSettings { settings in
            guard settings.authorizationStatus == .notDetermined else { return }
            center.requestAuthorization(options: [.alert, .badge, .sound]) { _, _ in }
        }
    }

    private func postLocalNotification(title: String, body: String) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 0.1, repeats: false)
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
    }
}
