import Foundation

// MARK: - Connection state for UI
struct ChatErr: Equatable {
    let domain: String
    let code: Int
    let message: String
    
    init(_ error: Error) {
        let ns = error as NSError
        self.domain = ns.domain
        self.code = ns.code
        self.message = ns.localizedDescription
    }
}

enum ChatConnectionState: Equatable {
    case idle, connecting, connected
    case reconnecting(Int)
    case failed(ChatErr)
    case closed(ChatErr?)
}


protocol ChatPresenterDelegate: AnyObject {
    func didReceiveChatMessages(message: String, username: String)
    func chatPresenter(_ presenter: ChatPresenter, didChange state: ChatConnectionState)
}

final class ChatPresenter {
    
    // MARK: - Public
    weak var delegate: ChatPresenterDelegate?
    
    private weak var view: ChatViewController?
    private let router: ChatRouter
    
    private let url = URL(string: "ws://ec2-13-250-109-94.ap-southeast-1.compute.amazonaws.com/ws")!
    
    init(view: ChatViewController,
         router: ChatRouter) {
        self.view = view
        self.router = router
    }
    
    func start() {
        guard webSocketTask == nil else { return }
        reconnectAttempt = 0
        connect()
    }
    
    func stop() {
        webSocketTask?.cancel(with: .goingAway, reason: nil)
        webSocketTask = nil
        state = .closed(nil)
    }
    
    // MARK: - HELPER METHOD FOR SENDING JSON DATA TO MESSAGE
    private func sendJSONData(_ data: [String: Any]) {
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: data, options: [])
            
            guard let jsonString = String(data: jsonData, encoding: .utf8) else {
                let error = NSError(domain: "ChatPresenter", code: 999, userInfo: [NSLocalizedDescriptionKey: "Could not encode JSON data to UTF8 string."])
                handleSendFailure(error)
                return
            }
            self.sendMessage(jsonString)
        } catch {
            self.handleSendFailure(error)
        }
    }
    
    // MARK: - Public Message Functions (Cleaned)
    func sendChatMessage(text: String, username: String) {
        let messageData: [String: Any] = [
            "message": text
        ]
        sendJSONData(messageData)
    }
    
    
    
    func sendMessage(_ message: String) {
        guard let task = webSocketTask else { return }
        task.send(.string(message)) { [weak self] error in
            if let error = error {
                self?.handleSendFailure(error)
            }
        }
    }
    
    private func handleSendFailure(_ error: Error) {
        delegateOnMain { [weak self] in
            guard let self else { return }
            self.delegate?.didReceiveChatMessages(message: "❌ send error: \(error.localizedDescription)", username: "error")
            self.state = .failed(ChatErr(error))
        }
    }
    
    // MARK: - Internals
    private lazy var session: URLSession = URLSession(configuration: .default)
    private var webSocketTask: URLSessionWebSocketTask?
    private var reconnectAttempt = 0
    private let maxReconnectAttempts = 5
    
    private(set) var state: ChatConnectionState = .idle {
        didSet { notifyStateChange() }
    }
    
    private func connect() {
        state = (reconnectAttempt == 0) ? .connecting : .reconnecting(reconnectAttempt)
        let request: URLRequest = {
            var req = URLRequest(url: url)
            req.addValue("room1", forHTTPHeaderField: "room-id")
            req.addValue(view?.username ?? "null", forHTTPHeaderField: "username")
            return req
        }()

        let task = session.webSocketTask(with: request)
        
        webSocketTask = task
        task.resume()
        
        startPing()
        listen()
    }
    
    private func listen() {
        webSocketTask?.receive { [weak self] result in
            guard let self else { return }
            switch result {
            case .success(let message):
                if case .connecting = self.state { self.state = .connected }
                if case .reconnecting = self.state { self.state = .connected }
                
                switch message {
                case .string(let text):
                    if let data = text.data(using: .utf8) {
                        do {
                            if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                               let message = json["message"] as? String,
                               let username = json["username"] as? String {
                                self.delegateOnMain {
                                    self.delegate?.didReceiveChatMessages(message: message, username: username)
                                }
                            } else {
                                self.delegateOnMain {
                                    self.delegate?.didReceiveChatMessages(message: text, username: "asfkaskfk")
                                }
                            }
                        } catch {
                            // fallback if JSON decoding fails
                            self.delegateOnMain {
                                self.delegate?.didReceiveChatMessages(message: text, username: "asfkaskfk")
                            }
                        }
                    }
                case .data(let data):
                    self.delegateOnMain { self.delegate?.didReceiveChatMessages(message: "(binary \(data.count) bytes)", username: "username") }
                @unknown default:
                    break
                }
                self.listen()
                
            case .failure(let error):
                self.handleFailure(error)
            }
        }
    }
    
    private func startPing() {
        webSocketTask?.sendPing { [weak self] error in
            guard let self else { return }
            if let error = error {
                self.handleFailure(error)
                return
            }
            if case .connecting = self.state { self.state = .connected }
            if case .reconnecting = self.state { self.state = .connected }
            
            DispatchQueue.global().asyncAfter(deadline: .now() + 15) { [weak self] in
                self?.startPing()
            }
        }
    }
    
    private func handleFailure(_ error: Error) {
        switch state {
        case .connecting, .connected, .reconnecting:
            attemptReconnect(after: backoff(for: reconnectAttempt), lastError: error)
        default:
            state = .failed(ChatErr(error))
        }
    }
    
    private func attemptReconnect(after delay: TimeInterval, lastError: Error) {
        guard reconnectAttempt < maxReconnectAttempts else {
            state = .failed(ChatErr(lastError))
            return
        }
        reconnectAttempt += 1
        state = .reconnecting(reconnectAttempt)
        // Tear down the old task
        webSocketTask?.cancel(with: .goingAway, reason: nil)
        webSocketTask = nil
        
        DispatchQueue.global().asyncAfter(deadline: .now() + delay) { [weak self] in
            self?.connect()
        }
    }
    
    private func backoff(for attempt: Int) -> TimeInterval {
        min(pow(2.0, Double(attempt)) * 0.5, 8.0)
    }
    
    private func notifyStateChange() {
        delegateOnMain { [weak self] in
            guard let self else { return }
            self.delegate?.chatPresenter(self, didChange: self.state)
        }
        if case .connected = state { reconnectAttempt = 0 }
        if case .closed = state { reconnectAttempt = 0 }
    }
    
    private func delegateOnMain(_ work: @escaping () -> Void) {
        if Thread.isMainThread { work() } else { DispatchQueue.main.async(execute: work) }
    }
}
