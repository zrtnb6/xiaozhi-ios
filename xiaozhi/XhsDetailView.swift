//
//  XhsDetailView.swift
//  xiaozhi
//
//  Created by Lee on 2025/11/26.
//

// XhsDetailView.swift

import SwiftUI

struct XhsDetailView: View {
    let detail: XhsNoteDetail
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                
                // 1. 图片轮播 (如果有图)
                if let images = detail.imageList, !images.isEmpty {
                    TabView {
                        ForEach(images) { img in // 这里使用解包后的 images
                            // ✅ 修复：img.urlDefault 也是可选的，提供默认值
                            AsyncImage(url: URL(string: img.urlDefault ?? "")) { image in
                                image.resizable()
                                     .aspectRatio(contentMode: .fit)
                            } placeholder: {
                                ProgressView()
                            }
                        }
                    }
                    .frame(height: 400)
                    .tabViewStyle(PageTabViewStyle())
                    .indexViewStyle(PageIndexViewStyle(backgroundDisplayMode: .always))
                }
                
                // 2. 标题与作者
                VStack(alignment: .leading, spacing: 12) {
                    Text(detail.title ?? "无标题")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    HStack {
                        AsyncImage(url: URL(string: detail.user?.avatar ?? "无头像")) { image in
                            image.resizable()
                        } placeholder: {
                            Circle().fill(Color.gray)
                        }
                        .frame(width: 36, height: 36)
                        .clipShape(Circle())
                        
                        Text(detail.user?.nickname ?? "无昵称")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                        
                        Spacer()
                        
                        // 关注按钮 (装饰用)
                        Text("关注")
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundColor(.red)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .overlay(
                                RoundedRectangle(cornerRadius: 14)
                                    .stroke(Color.red, lineWidth: 1)
                            )
                    }
                    
                    Divider()
                    
                    // 3. 正文内容
                    Text(detail.desc ?? "无描述")
                        .font(.body)
                        .lineSpacing(6) // 增加行间距，提升阅读体验
                        .foregroundColor(Color(UIColor.label))
                    
                    // 4. 底部信息 (点赞/时间)
                    HStack {
                        Text(formatDate(timestamp: detail.time ?? 0))
                            .font(.caption)
                            .foregroundColor(.gray)
                        
                        Spacer()
                        
                        Image(systemName: "heart")
                        Text(detail.interactInfo?.likedCount ?? "无点赞")
                        
                        Image(systemName: "star")
                        
                        Image(systemName: "message")
                    }
                    .foregroundColor(.gray)
                    .padding(.top, 20)
                }
                .padding(.horizontal)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: { dismiss() }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.gray)
                }
            }
        }
    }
    
    // 简单的时间格式化
    func formatDate(timestamp: Int64) -> String {
        let date = Date(timeIntervalSince1970: TimeInterval(timestamp / 1000))
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }
}
