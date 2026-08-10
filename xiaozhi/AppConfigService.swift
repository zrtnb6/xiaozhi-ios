//
//  AppConfigService.swift
//  xiaozhi
//
//  Created by Lee on 2026/1/10.
//

import Foundation
import Combine

class AppConfigService: ObservableObject {
    static let shared = AppConfigService()
    
    // 默认关闭 (审核模式)，只有接口返回 true 才开启完整功能
    @Published var isFullFeatureEnabled: Bool = false
    
    // 接口地址
    private let configURL = URL(string: "https://aichatbot-api.yy2app.cn/api/v1/common/app-bootstrap-config")!
    
    private init() {
        //fetchConfig()
    }
    
    func fetchConfig() {
        print(">>> 🔄 正在获取开关配置...")
        
        let request = URLRequest(url: configURL, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: 10)
        
        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            if let error = error {
                print("❌ Config Error: \(error.localizedDescription)")
                return
            }
            
            guard let data = data else { return }
            
            do {
                // 解析 JSON
                if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let dataObj = json["data"] as? [String: Any],
                   let enable = dataObj["enable"] as? Bool {
                    
                    DispatchQueue.main.async {
                        self?.isFullFeatureEnabled = enable
                        print(">>> ✅ 开关获取成功: \(enable ? "开启 (完整模式)" : "关闭 (审核模式)")")
                        print(">>> ✅ 更新状态: \(enable)")
                    }
                }else {
                    print("❌ 'data' 字段解析失败")
                }
            } catch {
                print("❌ JSON Parse Error: \(error)")
            }
        }.resume()
    }
}
