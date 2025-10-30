//
//  PrivacyView.swift
//  Chat302AI
//
//  Created by Adswave on 2025/8/28.
//

import SwiftUI
import WebKit

struct PrivacyView: View {
    
    var url = "http://302.ai/legal/privacy/"
    @Environment(\.presentationMode) var presentationMode
    
    
    var body: some View {
        EnhancedWebView(urlString: url)
            .navigationTitle("隐私政策")
            .navigationBarTitleDisplayMode(.inline)
        
            .listStyle(.insetGrouped)
            .background(NavigationGestureRestorer()) //返回手势
    
    
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        HStack {
                            Image(systemName: "chevron.left")
                                .foregroundColor(Color(ThemeManager.shared.getCurrentColorScheme() == .dark ? .white : .init(hex: "#000")))
                        }
                    }
                }
            }
        
        .navigationBarBackButtonHidden(true)
         
        
    }
}

struct EnhancedWebView: UIViewRepresentable {
    let urlString: String
    @State private var isLoading = false
    
    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.navigationDelegate = context.coordinator
        return webView
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {
        if let url = URL(string: urlString) {
            let request = URLRequest(url: url)
            uiView.load(request)
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, WKNavigationDelegate {
        var parent: EnhancedWebView
        
        init(_ parent: EnhancedWebView) {
            self.parent = parent
        }
        
        func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
            // 页面开始加载
        }
        
        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            // 页面加载完成
        }
        
        func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
            // 页面加载失败
        }
    }
}
