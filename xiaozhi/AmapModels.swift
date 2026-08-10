//
//  AmapModels.swift
//  xiaozhi
//
//  Created by Lee on 2025/11/30.
//

// 文件: AmapModels.swift

import Foundation
import CoreLocation

// 1. 地点 (POI) 模型
struct AmapPOI: Identifiable, Decodable {
    let id = UUID() // 本地生成唯一ID
    let name: String
    let address: String
    let latitude: Double
    let longitude: Double
    let tel: String?
    
    // 方便 MapKit 使用的坐标计算属性
    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
    
    enum CodingKeys: String, CodingKey {
        case name, address, latitude, longitude, tel
    }
}

// 2. 路线 (Route) 模型
struct AmapRoute: Decodable {
    let type: String      // "route"
    let originName: String
    let destName: String
    let polyline: String  // 坐标串 "104.0,30.0;104.1,30.1"
    let distance: Int     // 公里
    let duration: Int     // 分钟
    
    enum CodingKeys: String, CodingKey {
        case type
        case originName = "origin_name"
        case destName = "dest_name"
        case polyline
        case distance, duration
    }
}
