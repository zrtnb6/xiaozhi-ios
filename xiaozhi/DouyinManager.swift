import Foundation

// 1. 定义协议
protocol DouyinManagerDelegate: AnyObject {
    func douyinDidReceiveMessage(type: String, user: String, content: String)
}

class DouyinManager: NSObject {
    static let shared = DouyinManager()
    weak var delegate: DouyinManagerDelegate?
    
    private var webSocketTask: URLSessionWebSocketTask?
    private let urlSession = URLSession(configuration: .default)
    private var isConnected = false
    
    // 连接到 Go 服务器的 WebSocket 推送通道
    func connectToPushService() {
        if isConnected { return }
        
        // 注意：这里用了 AppConfig.localIP，端口是 8080
        let urlStr = "ws://\(AppConfig.localIP):8080/ws"
        guard let url = URL(string: urlStr) else { return }
        
        print(">>> 🎵 正在连接抖音推送服务: \(urlStr)")
        webSocketTask = urlSession.webSocketTask(with: url)
        webSocketTask?.resume()
        
        isConnected = true
        receiveMessage()
    }
    
    func disconnect() {
        webSocketTask?.cancel(with: .goingAway, reason: nil)
        isConnected = false
        print(">>> 🎵 抖音推送服务已断开")
    }
    
    // HTTP 控制指令: 启动
    func startMonitor(roomId: String) async {
        print(">>> 🎵 请求启动监控: \(roomId)")
        let _ = try? await NetworkService.postRequest(
            url: "http://\(AppConfig.localIP):8080/start",
            body: ["room_id": roomId]
        )
    }
    
    // HTTP 控制指令: 停止
    func stopMonitor() async {
        print(">>> 🎵 请求停止监控")
        let _ = try? await NetworkService.postRequest(
            url: "http://\(AppConfig.localIP):8080/stop",
            body: [:]
        )
    }
    
    // 持续接收 WebSocket 消息
    private func receiveMessage() {
        webSocketTask?.receive { [weak self] result in
            guard let self = self, self.isConnected else { return }
            
            switch result {
            case .failure(let error):
                print("❌ Douyin WS Error: \(error)")
                self.isConnected = false
            case .success(let message):
                switch message {
                case .string(let text):
                    self.handleJson(text)
                case .data(let data):
                    if let text = String(data: data, encoding: .utf8) {
                        self.handleJson(text)
                    }
                @unknown default: break
                }
                // 递归调用，继续监听下一条
                self.receiveMessage()
            }
        }
    }
    
    // 解析 Go 服务器发来的 JSON
    private func handleJson(_ text: String) {
        guard let data = text.data(using: .utf8),
              let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let type = json["type"] as? String,
              type == "douyin_push", // 对应 Go 代码里的 broadcastMessage
              let payload = json["data"] as? [String: Any] else { return }
        
        let msgType = payload["type"] as? String ?? ""
        let user = payload["username"] as? String ?? "Unknown"
        let content = payload["content"] as? String ?? ""
        
        DispatchQueue.main.async {
            self.delegate?.douyinDidReceiveMessage(type: msgType, user: user, content: content)
        }
    }
}
