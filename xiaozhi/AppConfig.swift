//
//  AppConfig.swift
//  xiaozhi
//
//  Created by Lee on 2025/12/2.
//

import Foundation

struct AppConfig {
    static let localIP = "47.109.149.246:8005" // 本地服务 (高德/中间层/微信)
    
    struct BaseURLs {
        static var xhs: String { "http://\(AppConfig.localIP)" }
        static var vision: String { "http://\(AppConfig.localIP)" }
        static var amap: String { "http://\(AppConfig.localIP)" }
        static var middleLayer: String { "http://\(AppConfig.localIP)" }
        static var wechat: String { "http://\(AppConfig.localIP)" }
    }
}
