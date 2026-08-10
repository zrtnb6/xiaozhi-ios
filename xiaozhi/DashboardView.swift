//
//  DashboardView.swift
//  xiaozhi
//
//  Created by Lee on 2026/1/10.
//

import SwiftUI

struct DashboardView: View {
    @State private var searchText = ""
    @StateObject private var configService = AppConfigService.shared
    
    // 控制跳转的状态
    @State private var showChatView = false
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(UIColor.systemGray6).ignoresSafeArea()
                
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 20) {
                        
                        // 1. 顶部搜索框
                        HStack {
                            TextField("输入你想要知道的事", text: $searchText)
                                .padding(.leading, 10)
                            
                            Button(action: {
                                // 搜索动作
                            }) {
                                Text("搜索")
                                    .font(.system(size: 14, weight: .bold))
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 8)
                                    .background(Color.black)
                                    .cornerRadius(20)
                            }
                        }
                        .padding(10)
                        .background(Color.white)
                        .cornerRadius(30)
                        .overlay(
                            RoundedRectangle(cornerRadius: 30)
                                .stroke(Color.black, lineWidth: 1.5)
                        )
                        .padding(.horizontal)
                        .padding(.top, 20)
                        
                        // 2. 功能卡片区 (横向滚动)
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 15) {
                                // 卡片 1: 图片生成 (这里可以做成跳转到相机/相册)
                                FunctionCard(
                                    title: "图片生成",
                                    desc: "万能魔法，生存你脑海里的图片",
                                    iconName: "photo.artframe",
                                    color: .purple,
                                    imageName: "img_create" // 请在 Assets 添加图片
                                )
                                
                                // 卡片 2: 实时对话 (点击跳转 ContentView)
                                NavigationLink(destination: ContentView()) {
                                    FunctionCard(
                                        title: "实时对话",
                                        desc: "与 AI 进行流畅的语音或文字交流",
                                        iconName: "bubble.left.and.bubble.right.fill",
                                        color: .green,
                                        imageName: "img_chat" // 请在 Assets 添加图片
                                    )
                                }
                                
                                // 占位卡片 (保持设计图的右侧露出效果)
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(Color.white)
                                    .frame(width: 40, height: 180)
                            }
                            .padding(.horizontal)
                        }
                        
                        // 3. 灵感创意 (文案创作)
                        VStack(alignment: .leading, spacing: 15) {
                            Text("灵感创意")
                                .font(.title2)
                                .fontWeight(.bold)
                                .padding(.horizontal)
                            
                            // 文案助手卡片
                            HStack(alignment: .top, spacing: 15) {
                                // 左侧图标/图片
                                ZStack {
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color.black)
                                        .frame(width: 60, height: 60)
                                    
                                    Image(systemName: "text.bubble.fill")
                                        .font(.title)
                                        .foregroundColor(.cyan)
                                }
                                
                                // 中间文字
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("文案创作小助手")
                                        .font(.headline)
                                    Text("可以轻松撰写规范化文案方案")
                                        .font(.subheadline)
                                        .foregroundColor(.gray)
                                        .lineLimit(2)
                                }
                                
                                Spacer()
                                
                                // 右侧头像组 (模拟)
                                HStack(spacing: -8) {
                                    Circle().fill(Color.gray).frame(width: 24, height: 24)
                                    Circle().fill(Color.brown).frame(width: 24, height: 24)
                                    ZStack {
                                        Circle().fill(Color.black).frame(width: 24, height: 24)
                                        Text("+98").font(.system(size: 8)).foregroundColor(.white)
                                    }
                                }
                            }
                            .padding()
                            .background(Color.white)
                            .cornerRadius(16)
                            .padding(.horizontal)
                        }
                        
                        Spacer()
                    }
                    .padding(.bottom, 20)
                }
            }
            .navigationBarHidden(true)
        }
    }
}

// 辅助组件：功能大卡片
struct FunctionCard: View {
    let title: String
    let desc: String
    let iconName: String
    let color: Color
    let imageName: String // 背景图
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            Color.white
            
            VStack(alignment: .leading) {
                // 上半部分：图片区域
                ZStack {
                    Color.gray.opacity(0.1) // 占位背景
                    // 如果有真实图片资源，取消下面注释
                    // Image(imageName).resizable().scaledToFill()
                }
                .frame(height: 100)
                .clipped()
                
                Spacer()
                
                // 下半部分：文字
                VStack(alignment: .leading, spacing: 4) {
                    // 图标 + 标题
                    HStack(spacing: 6) {
                        Image(systemName: iconName)
                            .padding(6)
                            .background(color)
                            .foregroundColor(.white)
                            .cornerRadius(6)
                        
                        Text(title)
                            .font(.headline)
                            .foregroundColor(.black)
                    }
                    
                    Text(desc)
                        .font(.caption)
                        .foregroundColor(.gray)
                        .lineLimit(2)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding(12)
            }
        }
        .frame(width: 160, height: 220)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}

struct DashboardView_Previews: PreviewProvider {
    static var previews: some View {
        DashboardView()
    }
}
