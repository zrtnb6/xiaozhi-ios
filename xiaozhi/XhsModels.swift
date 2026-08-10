//
//  XhsModels.swift
//  xiaozhi
//
//  Created by Lee on 2025/11/26.
//

import Foundation

// 笔记卡片模型
// XhsModels.swift
struct XhsFeed: Identifiable, Decodable {
    // ✅ 修改：自己生成唯一 ID，而不是用服务端的 id
    let id = UUID()
    
    // 原来的服务端 id 改名为 feedId (如果后续需要传给详情页)
    let feedId: String
    let xsecToken: String
    let noteCard: NoteCard
    // "note" 是正常笔记，"hot_query" 是无图的推荐词
    let modelType: String?
    
    // CodingKeys 映射
    enum CodingKeys: String, CodingKey {
        case feedId = "id" // 把 JSON 里的 "id" 映射给 feedId
        case xsecToken
        case noteCard
        case modelType // ✅ 映射该字段
    }
    
    // 判断数据是否有效的逻辑
    var isValid: Bool {
        // 1. 必须有 ID
        if feedId.isEmpty { return false }
        
        // 2. 类型必须是笔记 (过滤掉 hot_query 等广告/推荐词)
        if let type = modelType, type != "note" { return false }
        
        // 3. 必须有图片链接 (没有图片的笔记展示出来很难看)
        if noteCard.cover.urlPre.isEmpty { return false }
        
        // 4. 必须有标题 (可选，如果你想过滤掉无标题的)
        if noteCard.displayTitle.isEmpty { return false }
        
        return true
    }
}

struct NoteCard: Decodable {
    let displayTitle: String
    let user: XhsUser
    let cover: XhsCover
    let interactInfo: XhsInteract
}

struct XhsUser: Decodable {
    let nickname: String
    let avatar: String
}

struct XhsCover: Decodable {
    let urlPre: String // 预览图 URL
    let urlDefault: String // 大图 URL
}

struct XhsInteract: Decodable {
    let likedCount: String
}

// ✅ 新增：笔记详情模型
// 顶层响应
struct XhsDetailResponse: Decodable {
    let success: Bool?
    let data: XhsDetailData? // 这是一个包装层
    let message: String?
    
    let error: String?
    let code: String?
    
    // 辅助属性：判断是否真正成功
    var isSuccess: Bool {
        return success == true && data != nil
    }
}

// 中间层 data
struct XhsDetailData: Decodable {
    let feed_id: String?
    let data: XhsDetailInnerData? // 这里面才是真正的 note
}

// 内层 data
struct XhsDetailInnerData: Decodable {
    let note: XhsNoteDetail?
}

// 真正的笔记详情
struct XhsNoteDetail: Decodable {
    let noteId: String?
    let title: String?
    let desc: String?
    let user: XhsUser?
    let imageList: [XhsImage]?
    let interactInfo: XhsInteract?
    let time: Int64?
    
    struct XhsImage: Decodable, Identifiable {
        // ✅ 关键：给 id 一个初始值，或者用 var
        let id = UUID()
        let urlDefault: String?
        
        // ✅✅✅ 关键：显式定义 CodingKeys，且里面不要包含 'id'
        // 这样 Decodable 就只会去解 urlDefault，而不管 id
        enum CodingKeys: String, CodingKey {
            case urlDefault
        }
    }
}
