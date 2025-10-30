//
//  AdvanceWebView.swift
//  Chat302AI
//
//  Created by Adswave on 2025/8/28.
//

import SwiftUI
import WebKit

struct AdvancedWebView: UIViewRepresentable {
    let url: URL
    
    func makeUIView(context: Context) -> WKWebView {
        return WKWebView()
    }
    
    func updateUIView(_ webView: WKWebView, context: Context) {
        let request = URLRequest(url: url)
        webView.load(request)
    }
}
 
