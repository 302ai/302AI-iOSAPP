//
//  SigninView.swift
//  Chat302AI
//
//  Created by Adswave on 2025/7/22.
//

import SwiftUI

struct LoginView3: View {
    
    @EnvironmentObject var config: AppConfiguration
    
    //@State private var currentURL: URL? = URL(string: "https://302.ai/authentication/ZGVuZnVuQGZveG1haWwuY29tOkpTYlh1Y3lhOm1q?app=302+AI+Studio&name=302+AI+Studio&icon=https://file.302.ai/gpt/imgs/5b36b96aaa052387fb3ccec2a063fe1e.png&weburl=https://302.ai/&redirecturl=https://dash.302.ai&login_type=10086")
    @State private var currentURL: URL? = URL(string: "https://302.ai/sso/login?app=302+AI+Studio&name=302+AI+Studio&icon=https://file.302.ai/gpt/imgs/5b36b96aaa052387fb3ccec2a063fe1e.png&weburl=https://302.ai/&redirecturl=https://dash.302.ai&login_type=10086")
    
    
    //https://dash.302.ai/sso/login?app=302+AI+Studio&name=302+AI+Studio&icon=https://file.302.ai/gpt/imgs/5b36b96aaa052387fb3ccec2a063fe1e.png&weburl=https://302.ai/&redirecturl=https://dash.302.ai
    @Environment(\.dismiss) var dismiss
    
    // 存储提取的参数
    //@State private var apiKey: String = ""
    @Binding var apiKey : String
    @Binding var uid : Int
    @Binding var username : String
    
    
    @State private var showProgressView = true
    
    
    let targetURL = URL(string: "https://302.ai/sso/login?app=302+AI+Studio&name=302+AI+Studio&icon=https://file.302.ai/gpt/imgs/5b36b96aaa052387fb3ccec2a063fe1e.png&weburl=https://302.ai/&redirecturl=https://dash.302.ai&login_type=10086")!
    @State private var isLoading = false
    //@State private var currentURL: URL?
    @State private var redirectHistory: [URL] = []
    
    
    var body: some View {
            VStack {
                /*
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
                 
                WebViewWithURLTracking(
                    url: targetURL,
                    isLoading: $isLoading,
                    onRedirect: { url, type in
                        //handleRedirect(url: url, type: type)
                    },
                    onPageLoad: { url in
                        currentURL = url
                        print("✅ 页面加载完成: \(url.absoluteString)")
                        
                        if url.absoluteString.contains("apikey") && url.absoluteString.contains("username") {
                            print("已获取到apikey")
                            
                            extractParameters(from: url.absoluteString)
                            dismiss()
                        }
                    }
                )*/
                 
                
                SafariWithURLTracking(url: currentURL!, currentURL: $currentURL)
                    .onChange(of: currentURL) { oldValue, newValue in
                        
                        print("\n\n oldValue:\(oldValue!.absoluteString)-----\n\n newValue:\(newValue!.absoluteString)")
                        
                        if (newValue != oldValue) {
                            if let redirectUrl = newValue?.absoluteString {
                                if redirectUrl.contains("apikey") && redirectUrl.contains("username") {
                                    extractParameters(from: redirectUrl)
                                    dismiss()
                                }else{
                                    dismiss()
                                }
                            }
                        }
                    }
                
                
//                UIWebViewWithRedirect(url: URL(string:"https://dash.302.ai/sso/login?app=302+AI+Studio&name=302+AI+Studio&icon=https://file.302.ai/gpt/imgs/5b36b96aaa052387fb3ccec2a063fe1e.png&weburl=https://302.ai/&redirecturl=https://file.302.ai/gpt/imgs/5b36b96aaa052387fb3ccec2a063fe1e.png")!, onRedirect: { url in
//                    if let redirectUrl = url?.absoluteString {
//                        if redirectUrl.contains("apikey") && redirectUrl.contains("username") {
//                            extractParameters(from: redirectUrl)
//                            dismiss()
//                        }
//                    }
//                })
                
                
            }
        
            .onAppear{
                //clearAllCacheManually()
                
                //SafariWithURLTracking.clearSafariCache()
            }
            //.frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    
    
    /*
     WebViewWithURLTracking(url: URL(string: "https://dash.302.ai/sso?app=302+AI+Studio&name=302+AI+Studio&icon=https://file.302.ai/gpt/imgs/5b36b96aaa052387fb3ccec2a063fe1e.png&weburl=https://302.ai/")!, currentURL: $currentURL)
     .onChange(of: currentURL) { oldValue, newValue in
     
     if (newValue != oldValue) {
     if let redirectUrl = newValue?.absoluteString {
     if redirectUrl.contains("apikey") && redirectUrl.contains("username") {
     extractParameters(from: redirectUrl)
     
     dismiss()
     }
     }
     }
     }*/
    
    
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
 


