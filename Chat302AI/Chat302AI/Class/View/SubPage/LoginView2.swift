//
//  LoginView2.swift
//  Chat302AI
//
//  Created by Adswave on 2025/9/3.
//

import SwiftUI

struct LoginView2: View {
    
    @EnvironmentObject var config: AppConfiguration
    @Environment(\.dismiss) var dismiss
    
    
    // 存储提取的参数
    //@State private var apiKey: String = ""
    @Binding var apiKey : String
    @Binding var uid : String
    @Binding var username : String
    
    @State private var showProgressView = true
    
    let targetURL = URL(string: "https://302.ai/sso/login?app=302+AI+Studio&name=302+AI+Studio&icon=https://file.302.ai/gpt/imgs/5b36b96aaa052387fb3ccec2a063fe1e.png&weburl=https://302.ai/&redirecturl=https://www.baidu.com")!
    @State private var isLoading = false
    @State private var currentURL: URL?
    @State private var redirectHistory: [URL] = []
    
    
    var body: some View {
            VStack {
                
                // 顶部状态栏
                HStack {
                    if isLoading {
                        ProgressView()
                            .scaleEffect(0.8)
                        Text("加载中...")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    
                    Spacer()
                    
                    if let currentURL = currentURL {
                        Text(currentURL.host() ?? "")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                .padding(.horizontal)
                .padding(.vertical, 8)
                .background(Color.gray.opacity(0.1))
                 
                
//                WebView(
//                    url: URL(string: "https://302.ai/sso/login?app=302+AI+Studio&name=302+AI+Studio&icon=https://file.302.ai/gpt/imgs/5b36b96aaa052387fb3ccec2a063fe1e.png&weburl=https://302.ai/&redirecturl=https://302.ai")!,
//                    onMessageReceived: { message in
//                        
//                        print("\n----\n  onMessageReceived:\(message) \n------\n")
//                        
//                        if let dict = message as? [String: Any], let from = dict["from"] as? String, from == "auth", let data = dict["data"] as?  [String: Any] {
//                             
//                                let display_name = data["display_name"] as? String ?? "新的聊天"
//                                let display_url = data["display_url"] as? String ?? ""
//                                let uuid = data["uuid"] as? String ?? ""
//                                let description = data["description"] as? String ?? "你好"
//                             
//                            dismiss()
//                        }
//                    }
//                )
                
                
                WebViewWithURLTracking(
                    url: targetURL,
                    isLoading: $isLoading,
                    onRedirect: { url, type in
                        //handleRedirect(url: url, type: type)
                        
                        
                            currentURL = url
                            print("✅ 页面加载完成: \(url.absoluteString)")
                            
                            if url.absoluteString.contains("apikey") && url.absoluteString.contains("username") {
                                print("已获取到apikey")
                                
                                extractParameters(from: url.absoluteString)
                                
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                    dismiss()
                                }
                            }
                        
                        
                        
                    },
                    onPageLoad: { url in
                        currentURL = url
                        print("✅ 页面加载完成: \(url.absoluteString)")
                        
                        if url.absoluteString.contains("apikey") && url.absoluteString.contains("username") {
                            print("已获取到apikey")
                            
                            extractParameters(from: url.absoluteString)
                            
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                dismiss()
                            }
                        }
                    }
                )
                 
                
            }
        
            .onAppear{
                //clearAllCacheManually()
                
                //SafariWithURLTracking.clearSafariCache()
            }
        }
    
    
    
    
    private func clearAllCacheManually() {
        WebCacheManager.shared.clearAllWebCache {
            print("手动缓存清除完成")
            // 重新加载页面
            isLoading = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                // 这里可以通过改变URL来触发重新加载
                // 或者使用其他机制重新加载页面
            }
        }
    }
    
    
    
    // 提取参数
       func extractParameters(from urlString: String) {
           guard let url = URL(string: urlString),
                 let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
                 let queryItems = components.queryItems else {
               return
           }
           
//           for item in queryItems {
//               switch item.name {
//               case "apikey":
//                   apiKey = item.value ?? ""
//               case "uid":
//                   uid = item.value ?? ""
//                   config.uid = decodedString(str: uid)
//               case "username":
//                   username = item.value ?? ""
//                   config.username = username
//               default:
//                   break
//               }
//           }
           
       }
    
    func decodedString(str: String) -> String {
        guard let data = Data(base64Encoded: str),
              let string = String(data: data, encoding: .utf8) else {
            return "解码失败"
        }
        return string
    }
    
    
    
    func parseResponseData(from jsonString: String) -> PostMessageModel? {
        guard let jsonData = jsonString.data(using: .utf8) else {
            print("Failed to convert string to data")
            return nil
        }
        
        do {
            let decoder = JSONDecoder()
            let responseData = try decoder.decode(PostMessageModel.self, from: jsonData)
            return responseData
        } catch {
            print("JSON decoding error:", error)
            return nil
        }
    }
}
