//
//  XhsPublishView.swift
//  xiaozhi
//
//  Created by Lee on 2025/11/26.
//

import SwiftUI
import PhotosUI

struct XhsPublishView: View {
    // 接收参数
    @State var image: UIImage?
    @Binding var title: String
    @Binding var content: String
    
    // 回调
    var onPublish: (UIImage) -> Void // 把最终图片传出去
    var onCancel: () -> Void
    
    @State private var isPublishing = false
    @State private var selectedItem: PhotosPickerItem? // 相册选择项
    
    init(image: UIImage?, title: Binding<String>, content: Binding<String>, onPublish: @escaping (UIImage) -> Void, onCancel: @escaping () -> Void) {
        _image = State(initialValue: image) // 初始化 State
        _title = title
        _content = content
        self.onPublish = onPublish
        self.onCancel = onCancel
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // 1. 图片预览
                    ZStack(alignment: .bottomTrailing) {
                        if let img = image {
                            Image(uiImage: img)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(height: 250)
                                .cornerRadius(12)
                                .clipped()
                        } else {
                            Rectangle().fill(Color.gray.opacity(0.2)).frame(height: 250)
                        }
                        
                        // 更换图片按钮
                        PhotosPicker(selection: $selectedItem, matching: .images) {
                            Label("更换图片", systemImage: "photo")
                                .font(.caption)
                                .padding(8)
                                .background(.ultraThinMaterial)
                                .cornerRadius(8)
                                .padding(8)
                        }
                    }
                    
                    // 2. 标题输入
                    VStack(alignment: .leading) {
                        Text("标题")
                            .font(.caption)
                            .foregroundColor(.gray)
                        TextField("填写标题会有更多赞哦~", text: $title)
                            .font(.headline)
                            .padding()
                            .background(Color(UIColor.systemGray6))
                            .cornerRadius(8)
                    }
                    
                    // 3. 正文输入
                    VStack(alignment: .leading) {
                        Text("正文")
                            .font(.caption)
                            .foregroundColor(.gray)
                        
                        ZStack(alignment: .topLeading) {
                            if content.isEmpty {
                                Text("分享你的此刻想法...")
                                    .foregroundColor(.gray.opacity(0.5))
                                    .padding(.top, 12)
                                    .padding(.leading, 12)
                            }
                            TextEditor(text: $content)
                                .frame(height: 150)
                                .padding(4)
                                .background(Color.clear)
                        }
                        .background(Color(UIColor.systemGray6))
                        .cornerRadius(8)
                    }
                    
                    Spacer()
                    
                    // 4. 发布按钮
                    Button(action: {
                        if let finalImg = image {
                            isPublishing = true
                            onPublish(finalImg)
                        }
                    }) {
                        HStack {
                            if isPublishing {
                                ProgressView().tint(.white)
                            }
                            Text(isPublishing ? "发布中..." : "发布笔记")
                                .fontWeight(.bold)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.red)
                        .foregroundColor(.white)
                        .cornerRadius(25)
                    }
                    .disabled(isPublishing)
                }
                .padding()
            }
            .navigationTitle("发布笔记")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("取消") { onCancel() }
                }
            }
            .onChange(of: selectedItem) { newItem in
                Task {
                    if let data = try? await newItem?.loadTransferable(type: Data.self),
                       let uiImage = UIImage(data: data) {
                        self.image = uiImage
                    }
                }
            }
        }
    }
}
