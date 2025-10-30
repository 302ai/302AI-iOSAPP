//
//  RechargeAgreement.swift
//  Chat302AI
//
//  Created by Adswave on 2025/9/18.
//

import SwiftUI
import WebKit

import SwiftUI
 
 
 
// 包装 WKWebView 使其能在 SwiftUI 中使用
//struct AgreementWebView: UIViewRepresentable {

struct LocalWebView: UIViewRepresentable {
    let htmlFileName: String
    
    func makeUIView(context: Context) -> WKWebView {
        return WKWebView()
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {
        // 加载本地HTML文件
        if let htmlPath = Bundle.main.path(forResource: htmlFileName, ofType: "html"),
           let htmlString = try? String(contentsOfFile: htmlPath, encoding: .utf8) {
            
            // 获取本地文件的基础URL（用于处理相对路径资源）
            let baseURL = URL(fileURLWithPath: Bundle.main.bundlePath)
            uiView.loadHTMLString(htmlString, baseURL: baseURL)
        } else {
            // 如果文件不存在，显示错误信息
            let errorHTML = "<html><body><h1>文件加载失败</h1><p>无法找到 \(htmlFileName).html 文件</p></body></html>"
            uiView.loadHTMLString(errorHTML, baseURL: nil)
        }
    }
}

