//
//  XhsResultView.swift
//  xiaozhi
//
//  Created by Lee on 2025/11/26.
//

import SwiftUI

struct XhsResultView: View {
//    let feeds: [XhsFeed]
    @Environment(\.dismiss) var dismiss
    @ObservedObject var viewModel: ChatViewModel
    
    // 双列布局
    let columns = [
        GridItem(.flexible(), spacing: 10),
        GridItem(.flexible(), spacing: 10)
    ]
    
    var body: some View {
        NavigationView {
            ScrollView {
                LazyVGrid(columns: columns, spacing: 15) { // 增加垂直间距
                    ForEach(viewModel.xhsFeeds) { feed in
                        NoteCardView(feed: feed)
                            .onTapGesture {
                                // ✅ 点击卡片，获取详情
                                Task {
                                    await viewModel.fetchNoteDetail(
                                        feedId: feed.feedId,
                                        xsecToken: feed.xsecToken
                                    )
                                }
                            }
                    }
                }
                .padding(15) // 增加整体内边距，防止贴边
            }
            .background(Color(UIColor.systemGray6)) // 给背景加个浅灰色，突出白色卡片
            .navigationTitle("小红书搜索结果")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $viewModel.showNoteDetail) {
                if let detail = viewModel.selectedNoteDetail {
                    XhsDetailView(detail: detail)
                }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("关闭") { dismiss() }
                }
            }
        }
    }
}

// 单个卡片视图
// XhsResultView.swift 中的 NoteCardView
struct NoteCardView: View {
    let feed: XhsFeed
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // 1. 图片区域 (固定高度，裁切填充)
            GeometryReader { geometry in
                AsyncImage(url: URL(string: feed.noteCard.cover.urlPre)) { phase in
                    switch phase {
                    case .success(let image):
                        image.resizable()
                            .aspectRatio(contentMode: .fill) // 填充模式
                            .frame(width: geometry.size.width, height: 200) // 强制宽高
                            .clipped() // 裁切掉超出的部分
                    case .failure(_):
                        Color.gray.frame(height: 200)
                    case .empty:
                        Color(UIColor.systemGray5).frame(height: 200)
                    @unknown default:
                        EmptyView()
                    }
                }
            }
            .frame(height: 200) // 占位高度
            .cornerRadius(8)
            
            // 2. 标题区域
            Text(feed.noteCard.displayTitle.isEmpty ? "无标题" : feed.noteCard.displayTitle)
                .font(.system(size: 14, weight: .medium))
                .lineLimit(2) // 最多两行
                .multilineTextAlignment(.leading)
                .foregroundColor(.primary)
                .frame(height: 40, alignment: .topLeading) // 固定文字区域高度，防止参差不齐
                .padding(.horizontal, 4)
            
            // 3. 作者与点赞
            HStack {
                // 头像
                AsyncImage(url: URL(string: feed.noteCard.user.avatar)) { image in
                    image.resizable()
                } placeholder: {
                    Circle().fill(Color.gray.opacity(0.3))
                }
                .frame(width: 16, height: 16)
                .clipShape(Circle())
                
                // 名字
                Text(feed.noteCard.user.nickname)
                    .font(.caption2)
                    .foregroundColor(.gray)
                    .lineLimit(1)
                
                Spacer()
                
                // 爱心
                Image(systemName: "heart")
                    .font(.caption2)
                    .foregroundColor(.gray)
                
                // 赞数
                Text(feed.noteCard.interactInfo.likedCount)
                    .font(.caption2)
                    .foregroundColor(.gray)
            }
            .padding(.horizontal, 4)
            .padding(.bottom, 8)
        }
        .background(Color.white)
        .cornerRadius(8)
        // 给整个卡片加阴影，更有层次感
        .shadow(color: Color.black.opacity(0.08), radius: 4, x: 0, y: 2)
    }
}
