//
//  WebResultView.swift
//  xiaozhi
//
//  Created by Lee on 2025/12/1.
//

// 文件: WebResultView.swift

import SwiftUI
import WebKit

struct WebResultView: View {
    let htmlContent: String
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            WebViewWrapper(htmlContent: htmlContent)
                .navigationTitle("AI 旅行攻略")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("关闭") { dismiss() }
                    }
                }
        }
    }
}

struct WebViewWrapper: UIViewRepresentable {
    let htmlContent: String
    
    func makeUIView(context: Context) -> WKWebView {
        let config = WKWebViewConfiguration()
        let webView = WKWebView(frame: .zero, configuration: config)
        webView.navigationDelegate = context.coordinator
        return webView
    }
    
    func updateUIView(_ webView: WKWebView, context: Context) {
        // 加载 HTML 字符串
        webView.loadHTMLString(htmlContent, baseURL: nil)
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator()
    }
    
    class Coordinator: NSObject, WKNavigationDelegate {
        func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
            
            guard let url = navigationAction.request.url else {
                decisionHandler(.allow)
                return
            }
            
            print(">>> WebView 点击链接: \(url.absoluteString)") // ✅ 加日志调试
            
            // ✅ 优化 1：拦截 about:blank
                    if url.absoluteString == "about:blank" {
                        decisionHandler(.cancel)
                        return
                    }
            
            // ✅ 优化 2：处理高德/外部链接
            // 如果是 http/https，在当前页打开
            // 如果是 schema (如 iosamap://)，尝试跳转外部 App
            if let scheme = url.scheme, !["http", "https", "file"].contains(scheme) {
                if UIApplication.shared.canOpenURL(url) {
                    UIApplication.shared.open(url)
                    decisionHandler(.cancel)
                    return
                }
            }
            
            // 拦截高德 (iosamap) 和 百度 (baidumap)
            if url.scheme == "iosamap" || url.scheme == "baidumap" {
                if UIApplication.shared.canOpenURL(url) {
                    UIApplication.shared.open(url)
                } else {
                    print("❌ 未安装地图 App")
                }
                decisionHandler(.cancel)
                return
            }
            
            // 拦截自定义协议 (比如我们在 HTML 里写的 fake://navigate)
            if url.scheme == "app" && url.host == "navigate" {
                if let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
                   let dest = components.queryItems?.first(where: { $0.name == "dest" })?.value {
                    
                    print(">>> 🚗 导航去: \(dest)")
                    
                    // 这里可以做一个 ActionSheet 让用户选地图，或者直接跳高德
                    // 简单起见，直接跳高德 (如果安装了)，否则跳苹果
                    
                    let amapUrl = URL(string: "iosamap://path?sourceApplication=XiaoZhi&dname=\(dest.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!)&dev=0&t=0")!
                    
                    if UIApplication.shared.canOpenURL(amapUrl) {
                        UIApplication.shared.open(amapUrl)
                    } else {
                        // 没装高德，跳苹果
                        let appleUrl = URL(string: "http://maps.apple.com/?daddr=\(dest.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!)")!
                        UIApplication.shared.open(appleUrl)
                    }
                }
                decisionHandler(.cancel)
                return
            }
            
            decisionHandler(.allow)
        }
    }
}
