import Foundation
import CryptoKit // 引入苹果官方的加密库，用于计算 MD5/SHA256
import UIKit

struct IdentityManager {
    
    private static let clientIdKey = "com.yourcompany.xiaozhi.clientId"
    private static let deviceIdKey = "com.yourcompany.xiaozhi.deviceId"
    
    // 使用缓存，避免每次都从 Keychain 读取
    private static var cachedClientId: String?
    private static var cachedDeviceId: String?

    // ★★★ 获取 Client ID ★★★
    static var clientId: String {
        if let cached = cachedClientId { return cached }
        
        // 1. 尝试从 Keychain 读取
        if let savedId: String = KeychainHelper.load(key: clientIdKey) {
            cachedClientId = savedId
            return savedId
        }
        
        // 2. 如果 Keychain 没有，就生成一个新的并保存
        // 你的安卓代码基于 ANDROID_ID 生成确定性 UUID，
        // iOS 没有完全等价物。identifierForVendor 最接近，但会变。
        // 所以我们直接生成一个随机 UUID，然后用 Keychain 持久化它。
        let newId = UUID().uuidString
        _ = KeychainHelper.save(key: clientIdKey, string: newId)
        
        cachedClientId = newId
        print("Generated and saved new Client ID: \(newId)")
        return newId
    }

    // ★★★ 获取伪 MAC 地址 (Device ID) ★★★
    static var pseudoMacAddress: String {
        if let cached = cachedDeviceId { return cached }

        // 1. 尝试从 Keychain 读取
        if let savedId: String = KeychainHelper.load(key: deviceIdKey) {
            cachedDeviceId = savedId
            return savedId
        }
        
        // 2. 如果 Keychain 没有，就基于 Client ID 生成一个伪 MAC 并保存
        // 这样保证了 deviceId 和 clientId 不同，但又有稳定的关联
        guard let data = clientId.data(using: .utf8) else {
            return "02:00:00:00:00:00" // 极端情况下的回退值
        }
        
        // 使用 CryptoKit 计算 MD5 哈希值
        let digest = Insecure.MD5.hash(data: data)
        
        // 将哈希结果（一个包含16个字节的元组）转换为字节数组
        let hashBytes = digest.map { $0 }
        
        // 取前6个字节
        let macBytes = hashBytes.prefix(6)
        
        // 格式化为 xx:xx:xx:xx:xx:xx
        let macString = macBytes.map { String(format: "%02x", $0) }.joined(separator: ":")
   
        // 保存到 Keychain
        _ = KeychainHelper.save(key: deviceIdKey, string: macString)
        cachedDeviceId = macString
        print("Generated and saved new Pseudo MAC Address: \(macString)")
        return macString
    }
}
