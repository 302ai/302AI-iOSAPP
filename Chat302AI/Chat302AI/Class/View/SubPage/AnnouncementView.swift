//
//  AnnouncementView.swift
//  Chat302AI
//
//  Created by Adswave on 2025/8/28.
//

import SwiftUI
import WebKit

struct AnnouncementWebView: UIViewRepresentable {
    let htmlContent: String
    let title: String
    
    func makeUIView(context: Context) -> WKWebView {
        return WKWebView()
    }
    
    func updateUIView(_ webView: WKWebView, context: Context) {
        let htmlString = """
        <!DOCTYPE html>
        <html>
        <head>
            <meta name="viewport" content="width=device-width, initial-scale=1.0">
            <style>
                body {
                    font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", sans-serif;
                    padding: 20px;
                    line-height: 1.6;
                    color: #333;
                    max-width: 100%;
                    word-wrap: break-word;
                }
                h1 {
                    font-size: 24px;
                    font-weight: bold;
                    margin-bottom: 20px;
                    text-align: center;
                    color: #000;
                }
                img {
                    max-width: 100%;
                    height: auto;
                }
                p {
                    margin-bottom: 16px;
                }
                div {
                    margin-bottom: 16px;
                }
            </style>
        </head>
        <body>
            <h1>\(title)</h1>
            \(htmlContent)
        </body>
        </html>
        """
        
        webView.loadHTMLString(htmlString, baseURL: nil)
    }
}



struct AnnouncementView: View {
    
    @StateObject private var languageManager = LanguageManager.shared
    @State private var articleData: ArticleData?
    @State private var isLoading = true
    @State private var errorMessage: String?
    @Environment(\.presentationMode) var presentationMode
    
    // 计算属性：根据当前语言获取显示的内容
    private var displayTitle: String {
        guard let articleData = articleData else { return "" }
        return articleData.getTitle(for: languageManager.currentLanguage)
    }
    
    private var displayContent: String {
        guard let articleData = articleData else { return "" }
        return articleData.getContent(for: languageManager.currentLanguage)
    }
    
    var body: some View {
            VStack {
                // 语言显示和切换
                /*HStack {
                    Text("当前语言: \(languageManager.currentLanguageDescription)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    Menu {
                        ForEach(languageManager.availableLanguages(), id: \.self) { language in
                            Button {
                                languageManager.setLanguage(language)
                            } label: {
                                HStack {
                                    Text(languageManager.displayName(for: language))
                                    if language == languageManager.currentLanguage {
                                        Image(systemName: "checkmark")
                                    }
                                }
                            }
                        }
                    } label: {
                        HStack {
                            Image(systemName: "globe")
                            Text("切换语言")
                        }
                        .font(.caption)
                        .padding(8)
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(8)
                    }
                }
                .padding(.horizontal)
                .padding(.top)*/
                
                if isLoading {
                    ProgressView("加载中...")
                        .scaleEffect(1.2)
                } else if let errorMessage = errorMessage {
                    VStack(spacing: 20) {
                        Image(systemName: "exclamationmark.triangle")
                            .font(.system(size: 50))
                            .foregroundColor(.orange)
                        
                        Text("加载失败")
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        Text(errorMessage)
                            .font(.body)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                        
                        Button("重新加载") {
                            isLoading = true
                            self.errorMessage = ""
                            loadDataFromAPI()
                        }
                        .buttonStyle(.borderedProminent)
                        .padding()
                    }
                } else if let articleData = articleData {
                    // WebView 显示内容
                    AnnouncementWebView(
                        htmlContent: displayContent,
                        title: displayTitle
                    )
                }
            }
            .navigationBarBackButtonHidden(true)
            .listStyle(.insetGrouped)
            .background(NavigationGestureRestorer()) //返回手势
            .navigationTitle("公告详情".localized())
            .navigationBarTitleDisplayMode(.inline)
    
    
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
            .onAppear {
                loadDataFromAPI()
            }
            .onChange(of: languageManager.currentLanguage) { _ in
                // 语言切换时刷新显示
                if articleData != nil {
                    // 这里可以添加刷新逻辑，如果需要的话
                }
            }
        
    }
    
    private func loadDataFromAPI() {
        guard let url = URL(string: "https://dash-api.302.ai/proxy/announcements") else {
            self.errorMessage = "无效的URL地址"
            self.isLoading = false
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.timeoutInterval = 30
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                self.isLoading = false
                
                if let error = error {
                    self.errorMessage = "网络请求失败: \(error.localizedDescription)"
                    return
                }
                
                guard let httpResponse = response as? HTTPURLResponse else {
                    self.errorMessage = "无效的服务器响应"
                    return
                }
                
                guard (200...299).contains(httpResponse.statusCode) else {
                    self.errorMessage = "服务器错误: HTTP \(httpResponse.statusCode)"
                    return
                }
                
                guard let data = data else {
                    self.errorMessage = "没有接收到数据"
                    return
                }
                
                do {
                    let response = try JSONDecoder().decode(AnnouncementAPIResponse.self, from: data)
                    
                    if response.code == 0 {
                        self.articleData = response.data
                    } else {
                        self.errorMessage = response.msg
                    }
                } catch {
                    print("解析错误: \(error)")
                    if let jsonString = String(data: data, encoding: .utf8) {
                        print("接收到的数据: \(jsonString)")
                    }
                    self.errorMessage = "数据解析失败"
                }
            }
        }.resume()
    }
}






// 主响应模型
struct AnnouncementAPIResponse: Codable {
    let code: Int
    let msg: String
    let data: ArticleData
}

// 文章数据模型
struct ArticleData: Codable {
    let id: Int
    let modifiedOn: Int
    let title: String
    let enTitle: String
    let jpTitle: String
    let content: String
    let enContent: String
    let jpContent: String
    let expiredOn: Int
    
    enum CodingKeys: String, CodingKey {
        case id
        case modifiedOn = "modified_on"
        case title
        case enTitle = "en_title"
        case jpTitle = "jp_title"
        case content
        case enContent = "en_content"
        case jpContent = "jp_content"
        case expiredOn = "expired_on"
    }
    
    // 根据语言获取标题
    func getTitle(for language: String) -> String {
        switch language {
        case "en":
            return enTitle
        case "ja":
            return jpTitle
        case "zh-Hans":
            return title
        default:
            return title // 默认中文
        }
    }
    
    // 根据语言获取内容
    func getContent(for language: String) -> String {
        switch language {
        case "en":
            return enContent
        case "ja":
            return jpContent
        case "zh-Hans":
            return content
        default:
            return content // 默认中文
        }
    }
}
