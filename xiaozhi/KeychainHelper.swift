//
//  KeychainHelper.swift
//  xiaozhi
//
//  Created by Lee on 2025/11/15.
//

import Foundation
import Security

// 一个简单的 Keychain 帮助类，封装了常用的增删改查操作
struct KeychainHelper {
    
    // 将数据保存到 Keychain
    static func save(key: String, data: Data) -> OSStatus {
        let query = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrAccount: key,
            kSecValueData: data
        ] as [String: Any]
        
        // 先删除旧的，防止重复
        SecItemDelete(query as CFDictionary)
        
        // 添加新的
        return SecItemAdd(query as CFDictionary, nil)
    }
    
    // 从 Keychain 读取数据
    static func load(key: String) -> Data? {
        let query = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrAccount: key,
            kSecReturnData: kCFBooleanTrue!,
            kSecMatchLimit: kSecMatchLimitOne
        ] as [String: Any]
        
        var dataTypeRef: AnyObject?
        let status: OSStatus = SecItemCopyMatching(query as CFDictionary, &dataTypeRef)
        
        if status == noErr {
            return dataTypeRef as? Data
        } else {
            return nil
        }
    }
    
    // 将字符串方便地存取
    static func save(key: String, string: String) -> OSStatus {
        if let data = string.data(using: .utf8) {
            return save(key: key, data: data)
        }
        return errSecParam
    }
    
    static func load(key: String) -> String? {
        if let data: Data = load(key: key) {
            return String(data: data, encoding: .utf8)
        }
        return nil
    }
}
