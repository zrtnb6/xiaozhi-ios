//
//  APIService.swift
//  xiaozhi
//
//  Created by Lee on 2025/11/15.
//

import Foundation
import UIKit // 用于获取设备信息

class APIService {
    static let shared = APIService()
    private let baseURL = "https://api.tenclass.net/"
    
    // 这个函数替代你的 ApiService.checkOta suspend fun
    // 'async' 表示这是一个异步函数，'throws' 表示它可能会抛出错误
    func checkOta(requestBody: OtaRequest) async throws -> OtaResponse {
        guard let url = URL(string: baseURL + "xiaozhi/ota/") else {
            throw URLError(.badURL)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        // 设置 Headers
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(IdentityManager.pseudoMacAddress, forHTTPHeaderField: "Device-Id")
        request.setValue(IdentityManager.clientId, forHTTPHeaderField: "Client-Id")
        request.setValue("xingzhi-ios/1.0.0", forHTTPHeaderField: "User-Agent")
        
        // 将 OtaRequest 对象编码成 JSON Data
        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase // 自动将驼峰命名转为下划线
        encoder.outputFormatting = .prettyPrinted
        request.httpBody = try encoder.encode(requestBody)
        
        print("----------- HTTP Request -----------")
        print("URL: \(url.absoluteString)")
        print("Method: \(request.httpMethod ?? "N/A")")
        print("Headers: \(request.allHTTPHeaderFields ?? [:])")
        
        if let body = request.httpBody, let bodyString = String(data: body, encoding: .utf8) {
            print("Body:\n\(bodyString)")
        } else {
            print("Body: (empty)")
        }
        print("------------------------------------")
        
        // 发起网络请求并等待结果 (await)
        let (data, response) = try await URLSession.shared.data(for: request)
        
        // 检查 HTTP 状态码
        guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
            throw URLError(.badServerResponse)
        }
        
        // 将收到的 JSON Data 解码成 OtaResponse 对象
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase // 自动将下划线转为驼峰命名
        return try decoder.decode(OtaResponse.self, from: data)
    }
}
