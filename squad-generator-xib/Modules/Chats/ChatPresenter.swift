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
    func didReceiveChatMessages(_ message: String)
    func chatPresenter(_ presenter: ChatPresenter, didChange state: ChatConnectionState)
}

final class ChatPresenter {

    // MARK: - Public
    weak var delegate: ChatPresenterDelegate?

    // Replace with a working endpoint; echo.websocket.org is no longer available.
    private let url = URL(string: "wss://echo.websocket.org")!

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

    func sendMessage(_ message: String) {
        guard let task = webSocketTask else { return }
        task.send(.string(message)) { [weak self] error in
            if let error = error {
                self?.delegateOnMain { [weak self] in
                    guard let self else { return }
                    self.delegate?.didReceiveChatMessages("❌ send error: \(error.localizedDescription)")
                    self.state = .failed(ChatErr(error))
                }
            }
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
        let task = session.webSocketTask(with: url)
        webSocketTask = task
        task.resume()

        // Consider connected after successful ping/receive
        startPing()
        listen()
    }

    private func listen() {
        webSocketTask?.receive { [weak self] result in
            guard let self else { return }
            switch result {
            case .success(let message):
                // Mark connected if we were in connecting/reconnecting
                if case .connecting = self.state { self.state = .connected }
                if case .reconnecting = self.state { self.state = .connected }

                switch message {
                case .string(let text):
                    self.delegateOnMain { self.delegate?.didReceiveChatMessages(text) }
                case .data(let data):
                    self.delegateOnMain { self.delegate?.didReceiveChatMessages("(binary \(data.count) bytes)") }
                @unknown default:
                    break
                }
                // Keep listening
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

            // Schedule next ping
            DispatchQueue.global().asyncAfter(deadline: .now() + 15) { [weak self] in
                self?.startPing()
            }
        }
    }

    private func handleFailure(_ error: Error) {
        // If we’re active, try to reconnect; otherwise mark failed
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
        // 0→0.5s, 1→1s, 2→2s, 3→4s, capped at 8s
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
