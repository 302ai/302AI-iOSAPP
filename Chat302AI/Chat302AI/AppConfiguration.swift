//
//  AppConfiguration.swift
//  GPTalks
//
//  Created by Zabir Raihan on 10/11/2023.
//

import SwiftUI
import OpenAI

class AppConfiguration: ObservableObject {
    
    static let shared = AppConfiguration()
     
    @AppStorage("savedEmail") var savedEmail = ""
    @AppStorage("savedPhone") var savedPhone = ""
    @AppStorage("savedPassword") var savedPassword = ""
    
    
    @AppStorage("configuration.isShowClearContext") var isShowClearContext: Bool = false //显示清除上下文
    @AppStorage("configuration.isLogin")    var isLogin:  Bool = false {
        
        didSet {
            // 在这里设置断点
            print("isLogin 被改变: \(oldValue) -> \(isLogin)")
            // 查看调用堆栈
//            for symbol in Thread.callStackSymbols {
//                print(symbol)
//            }
        }
    }
    @AppStorage("configuration.uid")        var uid:      Int = 0
    @AppStorage("configuration.username")   var username: String = ""
    @AppStorage("configuration.userToken")   var userToken: String = ""    
    
    
    
    @AppStorage("configuration.isAutoScrollToBottom") var autoScrollToBottom: Bool = true //自动滚到底部
    @AppStorage("configuration.isAutoTracelessSession") var autoTracelessSession: Bool = false //默认使用无痕会话
    @AppStorage("titleGenerated") var titleGenerated = "first"  //标题生成:第一次会话 first/every
    
    @AppStorage("configuration.isWebSearch") var isWebSearch: Bool = false //联网搜索
    /*
     jina（默认）
     search1api
     tavily
     exa
     bochaai
     */
    @AppStorage("configuration.searchType") var searchType: String = "jina" //搜索服务商
    // 计算属性，方便获取和设置枚举值
    var currentSearchType: SearchEngineType {
        get {
            return SearchEngineType(rawValue: searchType) ?? .jina
        }
        set {
            searchType = newValue.rawValue
            objectWillChange.send() // 通知视图更新
        }
    }
    
    @AppStorage("configuration.isDeepSearch") var isDeepSearch: Bool = false //深度搜索
    @AppStorage("configuration.isR1Fusion") var isR1Fusion: Bool = false //推理模式
    @AppStorage("configuration.isPreviewOn") var previewOn: Bool = false //开启预览
    
    /// common
    @AppStorage("configuration.isMarkdownEnabled") var isMarkdownEnabled: Bool = true
    @AppStorage("configuration.isAutoGenerateTitle") var isAutoGenerateTitle: Bool = true
    @AppStorage("configuration.customPromptOn") var isCustomPromptOn: Bool = false  //自定义提示词 开
    @AppStorage("configuration.customPromptContent") var customPromptContent: String = "有什么可以帮你的吗"
    
    @AppStorage("configuration.autoResume") var autoResume: Bool = true
    
    @AppStorage("configuration.preferredChatService") var preferredChatService: Provider = .openai
    @AppStorage("configuration.preferredImageService") var preferredImageService: Provider = .openai
    @AppStorage("configuration.userAvatar") var userAvatar: String = "😀 "
    
    // params
    @AppStorage("configuration.contextLength") var contextLength = 10
    @AppStorage("configuration.temperature") var temperature: Double = 0.5
    @AppStorage("configuration.useTools") var useTools: Bool = true
    @AppStorage("configuration.systemPrompt") var systemPrompt: String = "你是一个乐于助人的助手"//"You are a helpful assistant."
        
    @AppStorage("configuration.artifactsPromptsOn") var artifactsPromptsOn: Bool = false
    @AppStorage("configuration.fileParseOn") var fileParseOn: Bool = true  //链接解析
    @AppStorage("configuration.apiHost") var apiHost = ""  //链接解析
    @AppStorage("configuration.region") var appStoreRegion = ""  //用户地区
    @AppStorage("configuration.modifiedHost") var modifiedHost = 0  //用户修改过域名
    
    /// openAI
    //@AppStorage("configuration.OAIKey") var OAIkey = " "   //api.siliconflow.cn
    
    //@AppStorage("configuration.OAIKey") var OAIkey = " "  //api.302.ai
    @AppStorage("configuration.OAIKey") var OAIkey = ""  {
        
        didSet {
            // 在这里设置断点
            print("OAIkey 被改变: \(oldValue) -> \(OAIkey)")
             
        }
    }
    
    @AppStorage("configuration.OAImodel") var OAImodel: Model = .gpt4o
    @AppStorage("configuration.AI302ChatModel") var chatModel = "deepseek-chat"
    @AppStorage("configuration.AI302TitleModel") var titleModel = "deepseek-chat"
    
    
    @AppStorage("configuration.isModerated") var isModerated = false
    @AppStorage("configuration.OAIImageModel") var OAIImageModel: Model = .dalle3
    @AppStorage("configuration.OAIColor") var OAIColor: ProviderColor = .greenColor
    
    
    /// custom
    @AppStorage("configuration.Ckey") var Ckey = ""
    @AppStorage("configuration.Chost") var Chost: String = ""
    @AppStorage("configuration.Cmodel") var Cmodel: Model = .customChat
    @AppStorage("configuration.CImageModel") var CImageModel: Model = .dalle3
    @AppStorage("configuration.CColor") var CColor: ProviderColor = .orangeColor
    
    @AppStorage("configuration.customChatModel") var customChatModel: String = ""
    @AppStorage("configuration.customImageModel") var customImageModel: String = ""
    @AppStorage("configuration.customVisionModel") var customVisionModel: String = ""
    
}
