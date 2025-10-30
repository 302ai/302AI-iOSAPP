//
//  PreviewCode.swift
//  GPTalks
//
//  Created by Adswave on 2025/5/23.
//

import SwiftUI
import WebKit
import SwiftMarkdownView
import AlertToast

enum CodeType: String, CaseIterable {
    case html = "html"
    case svg = "SVG"
    case javascript = "JavaScript"
    case python = "Python"
    case unknown = "Unknown"
    
    var icon: String {
        switch self {
        case .html: return "chevron.left.slash.chevron.right"
        case .svg: return "square.fill.on.square.fill"
        case .javascript: return "curlybraces"
        case .python: return "p.square.fill"
        case .unknown: return "questionmark.square.fill"
        }
    }
    
    var color: Color {
        switch self {
        case .html: return .orange
        case .svg: return .blue
        case .javascript: return .yellow
        case .python: return .green
        case .unknown: return .gray
        }
    }
}


struct PreviewCode: View {
    var msgContent: String
    @State private var showPreview = true
    
    var svgCode: String = ""
    
    
    enum Tab: String, CaseIterable {
            case preview = "预览"
            case code = "代码"
        }
    @State private var selectedTab: Tab = .code
    @State var runCodeResponse: String = "正在执行代码"
    @EnvironmentObject var fontSettings: FontSettings
    @Environment(\.dismiss) var dismiss
    
    @State var extractCode: String = ""
    
    @State var isShowToast = false
    // 提示文本（可选）
    @State private var hintText: String?
        


    var body: some View {
        
        
        VStack {
            //Spacer(minLength: 20)
            
            HStack{
                
//                SegmentedControl(
//                    items: Tab.allCases,
//                    selectedItem: $selectedTab,
//                    titleProvider: { $0.rawValue }
//                )
//                .frame(width: 150)
//                .padding()
                
                Button(action: {
                    dismiss()
                }) {
                    HStack {
                        Image(systemName: "chevron.left")
                            .foregroundColor(Color(ThemeManager.shared.getCurrentColorScheme() == .dark ? .white : .init(hex: "#000")))
                    }
                }.padding(.leading,20)
                
                Spacer()
                 
                Button {
                    extractCode.copyToPasteboard()
                    
                    isShowToast = true
                    hintText = "已复制".localized()
                    
                    
                } label: {
                    Image("复制")
                        .renderingMode(.template)
                        .foregroundColor(Color(ThemeManager.shared.getCurrentColorScheme() == .dark ? .white : .init(hex: "#000")))
                }
                .frame(width: 40, height: 40)

                Button {
                    
                    if selectedTab == .code {
                        selectedTab = .preview
                    }else{
                        selectedTab = .code
                    }
                    
                } label: {
                    Image("可见2")
                        .renderingMode(.template)
                        .foregroundColor(Color(ThemeManager.shared.getCurrentColorScheme() == .dark ? .white : .init(hex: "#000")))
                }
                .frame(width: 40, height: 40)
                .padding(.trailing,20)
            }
            .frame(height: 60)
            .toast(isPresenting: $isShowToast){
                  
                AlertToast(displayMode: .alert, type: .regular, title: hintText)
            }
            
            
            ZStack {
                
                if selectedTab == .preview{
                 
                    ScrollView{
                        if let msg = ConversationMessage(jsonString: msgContent) {
                                let codeType =  detectCodeType(msg.content)
                            let extractCode2 = combineIntelligently(from: msg.content)
                            if codeType == .svg || codeType == .html{
                                
                                SVGWebView(inputText:extractCode2)
                                    .frame(width:UIScreen.main.bounds.width-40,height:UIScreen.main.bounds.height-250)
                                    .cornerRadius(10)  // 先设置圆角
                                    .overlay(          // 再用 overlay 添加带圆角的边框
                                        RoundedRectangle(cornerRadius: 10)
                                            .stroke(Color.gray, lineWidth: 0.5)
                                    )
                            }else{
                                VStack{
                                    HStack{
                                        Spacer()
                                        Image("applogo")
                                            .resizable()
                                            .frame(width: 40,height:40)
                                        Text("302.AI")
                                            .font(.title)
                                        Spacer()
                                    }
                                    
                                    Text("实时预览功能(Beta)")
                                        .font(.body)
                                        .foregroundStyle(.gray)
                                }
                                .frame(width:UIScreen.main.bounds.width-40,height:UIScreen.main.bounds.height-250)
                                .padding(8)
                                .cornerRadius(10)  // 先设置圆角
                                .overlay(          // 再用 overlay 添加带圆角的边框
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(Color.gray, lineWidth: 0.5)
                                )
                            }
                            
                        }else if !msgContent.isEmpty {
                            let codeType =  detectCodeType(msgContent)
                            
                            let extractCode2 = combineIntelligently(from: msgContent)
                            if codeType == .svg || codeType == .html{
                                
                                let extractCodeArr = extractCompleteCodeBlocks(from: msgContent)
                                ForEach(extractCodeArr, id: \.self) { item in
                                    let c = combineIntelligently(from: item)
                                    
                                    SVGWebView(inputText: c)
                                        .frame(width:UIScreen.main.bounds.width-40,height:UIScreen.main.bounds.height-200)
                                        .cornerRadius(10)  // 先设置圆角
                                        .overlay(          // 再用 overlay 添加带圆角的边框
                                            RoundedRectangle(cornerRadius: 10)
                                                .stroke(Color.gray, lineWidth: 0.5)
                                        )
                                    
                                }
                                
                            }else{
                                VStack{
                                    HStack{
                                        Spacer()
                                        Image("applogo")
                                            .resizable()
                                            .frame(width: 40,height:40)
                                        Text("302.AI")
                                            .font(.title)
                                        Spacer()
                                    }
                                    
                                    Text("实时预览功能(Beta)")
                                        .font(.body)
                                        .foregroundStyle(.gray)
                                }
                                .frame(width:UIScreen.main.bounds.width-40,height:UIScreen.main.bounds.height-250)
                                .padding(8)
                                .cornerRadius(10)  // 先设置圆角
                                .overlay(          // 再用 overlay 添加带圆角的边框
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(Color.gray, lineWidth: 0.5)
                                )
                            }
                            
                        }else{
                            VStack{
                                HStack{
                                    Spacer()
                                    Image("applogo")
                                        .resizable()
                                        .frame(width: 40,height:40)
                                    Text("302.AI")
                                        .font(.title)
                                    Spacer()
                                }
                                
                                Text("实时预览功能(Beta)")
                                    .font(.body)
                                    .foregroundStyle(.gray)
                            }
                            .frame(width:UIScreen.main.bounds.width-40,height:UIScreen.main.bounds.height-250)
                            .padding(8)
                            .cornerRadius(10)  // 先设置圆角
                            .overlay(          // 再用 overlay 添加带圆角的边框
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color.gray, lineWidth: 0.5)
                            )
                        }
                        
                        
                    }
                    
                    
                    
                } else{
                    
                    ScrollView {
                        if let msg = ConversationMessage(jsonString: msgContent) {
                            let codeType =  detectCodeType(msg.content)
                            let extractCodeArr = extractCompleteCodeBlocks(from: msg.content)
                            
                            //combineIntelligently(from: msg.content)
                            
                            
                            ForEach(extractCodeArr, id: \.self) { item in
                                
                                SwiftMarkdownView(item)
                                    .markdownFontSize(fontSettings.fontSize)
                                    .id("md-\(fontSettings.fontSize)")  // 字体变化时强制重建
                                    .frame(width:UIScreen.main.bounds.width-40)
                                    .cornerRadius(10)  // 先设置圆角
                                    .overlay(          // 再用 overlay 添加带圆角的边框
                                        RoundedRectangle(cornerRadius: 10)
                                            .stroke(Color.gray, lineWidth: 0.5)
                                    )
                            }
                            
//                            switch codeType {
//                            case .svg:
//                                let codeContent = extractSVG(from: msg.content)
//                                //extractCode = codeContent
//                                //SwiftMarkdownView("```xml\n" + "\(codeContent)" + "```")
//                                
//                                ForEach(extractCodeArr, id: \.self) { item in
//                                    SwiftMarkdownView(item)
//                                        .markdownFontSize(fontSettings.fontSize)
//                                        .id("md-\(fontSettings.fontSize)")  // 字体变化时强制重建
//                                        .frame(width:UIScreen.main.bounds.width-40,height:UIScreen.main.bounds.height-250)
//                                        .cornerRadius(10)  // 先设置圆角
//                                        .overlay(          // 再用 overlay 添加带圆角的边框
//                                            RoundedRectangle(cornerRadius: 10)
//                                                .stroke(Color.gray, lineWidth: 0.5)
//                                        )
//                                }
//                            case .html:
//                                let codeContent = extractHTMLFromMarkdown(msg.content)
//                                let content2 = "```java\n" + "\(codeContent ?? "")"
//                                //SwiftMarkdownView(content2)
//                                SwiftMarkdownView(extractCode2)
//                                    .markdownFontSize(fontSettings.fontSize)
//                                    .id("md-\(fontSettings.fontSize)")  // 字体变化时强制重建
//                                    .frame(width:UIScreen.main.bounds.width-40)
//                                    .cornerRadius(10)  // 先设置圆角
//                                    .padding(5)
//                                    .overlay(          // 再用 overlay 添加带圆角的边框
//                                        RoundedRectangle(cornerRadius: 10)
//                                            .stroke(Color.gray, lineWidth: 0.5)
//                                    )
//                            case .javascript:
//                                let codeContent = extractJavascript(msg.content)
//                                let content2 = "```java\n" + "\(codeContent ?? "")"
//                                //SwiftMarkdownView(content2)
//                                SwiftMarkdownView(extractCode2)
//                                    .markdownFontSize(fontSettings.fontSize)
//                                    .id("md-\(fontSettings.fontSize)")  // 字体变化时强制重建
//                                    .frame(width:UIScreen.main.bounds.width-40)
//                                    .frame(minHeight: 200)
//                                    .cornerRadius(10)  // 先设置圆角
//                                    .padding(5)
//                                    .overlay(          // 再用 overlay 添加带圆角的边框
//                                        RoundedRectangle(cornerRadius: 10)
//                                            .stroke(Color.gray, lineWidth: 0.5)
//                                    )
//                            case .python:
//                                let codeContent = extractPython(msg.content)
//                                
//                                let content2 = "```java\n" + "\(codeContent ?? "")"
//                                //SwiftMarkdownView(content2)
//                                SwiftMarkdownView(extractCode2)
//                                    .markdownFontSize(fontSettings.fontSize)
//                                    .id("md-\(fontSettings.fontSize)")  // 字体变化时强制重建
//                                    .frame(minHeight: 200)
//                                    .frame(width:UIScreen.main.bounds.width-40)
//                                    .cornerRadius(10)  // 先设置圆角
//                                    .padding(5)
//                                    .overlay(          // 再用 overlay 添加带圆角的边框
//                                        RoundedRectangle(cornerRadius: 10)
//                                            .stroke(Color.gray, lineWidth: 0.5)
//                                    )
//                            default:
//                                //SwiftMarkdownView("```java\n" + "\(msg.content)")
//                                SwiftMarkdownView(extractCode2)
//                                    .markdownFontSize(fontSettings.fontSize)
//                                    .id("md-\(fontSettings.fontSize)")  // 字体变化时强制重建
//                                    .frame(minHeight: 200)
//                                    .frame(width:UIScreen.main.bounds.width-40)
//                                    .cornerRadius(10)  // 先设置圆角
//                                    .padding(5)
//                                    .overlay(          // 再用 overlay 添加带圆角的边框
//                                        RoundedRectangle(cornerRadius: 10)
//                                            .stroke(Color.gray, lineWidth: 0.5)
//                                    )
//                            }
                        }else if (!msgContent.isEmpty) {
                            let codeType =  detectCodeType(msgContent)
                            //let extractCode2 = combineIntelligently(from: msgContent)
                            let extractCodeArr = extractCompleteCodeBlocks(from: msgContent)
                            ForEach(extractCodeArr, id: \.self) { item in
                                SwiftMarkdownView(item)
                                    .markdownFontSize(fontSettings.fontSize)
                                    .id("md-\(fontSettings.fontSize)")  // 字体变化时强制重建
                                    .frame(width:UIScreen.main.bounds.width-40)
                                    .cornerRadius(10)  // 先设置圆角
                                    .overlay(          // 再用 overlay 添加带圆角的边框
                                        RoundedRectangle(cornerRadius: 10)
                                            .stroke(Color.gray, lineWidth: 0.5)
                                    )
                            }
                             
//                            switch codeType {
//                            case .svg:
//                                let codeContent = extractSVG(from: msgContent)
//                                 
//                                SwiftMarkdownView("```xml\n" + "\(codeContent)" + "```")
//                                    .markdownFontSize(fontSettings.fontSize)
//                                    .id("md-\(fontSettings.fontSize)")  // 字体变化时强制重建
//                                    .frame(width:UIScreen.main.bounds.width-40)
//                                    .cornerRadius(10)  // 先设置圆角
//                                    .overlay(          // 再用 overlay 添加带圆角的边框
//                                        RoundedRectangle(cornerRadius: 10)
//                                            .stroke(Color.gray, lineWidth: 0.5)
//                                    )
//                            case .html:
//                                let codeContent = extractHTMLFromMarkdown(msgContent)
//                                let content2 = "```java\n" + "\(codeContent ?? "")"
//                                
//                                //SwiftMarkdownView(content2)
//                                SwiftMarkdownView(extractCode2)
//                                    .markdownFontSize(fontSettings.fontSize)
//                                    .id("md-\(fontSettings.fontSize)")  // 字体变化时强制重建
//                                    .frame(width:UIScreen.main.bounds.width-40)
//                                    .cornerRadius(10)  // 先设置圆角
//                                    .padding(5)
//                                    .overlay(          // 再用 overlay 添加带圆角的边框
//                                        RoundedRectangle(cornerRadius: 10)
//                                            .stroke(Color.gray, lineWidth: 0.5)
//                                    )
//                            case .javascript:
//                                let codeContent = extractJavascript(msgContent)
//                                let content2 = "```java\n" + "\(codeContent ?? "")"
//                                //SwiftMarkdownView(content2)
//                                SwiftMarkdownView(extractCode2)
//                                    .markdownFontSize(fontSettings.fontSize)
//                                    .id("md-\(fontSettings.fontSize)")  // 字体变化时强制重建
//                                    .frame(width:UIScreen.main.bounds.width-40)
//                                    .frame(minHeight: 200)
//                                    .cornerRadius(10)  // 先设置圆角
//                                    .padding(5)
//                                    .overlay(          // 再用 overlay 添加带圆角的边框
//                                        RoundedRectangle(cornerRadius: 10)
//                                            .stroke(Color.gray, lineWidth: 0.5)
//                                    )
//                            case .python:
//                                let codeContent = extractPython(msgContent)
//                                let content2 = "```java\n" + "\(codeContent ?? "")"
//                                //SwiftMarkdownView(content2)
//                                SwiftMarkdownView(extractCode2)
//                                    .markdownFontSize(fontSettings.fontSize)
//                                    .id("md-\(fontSettings.fontSize)")  // 字体变化时强制重建
//                                    .frame(minHeight: 200)
//                                    .frame(width:UIScreen.main.bounds.width-40)
//                                    .cornerRadius(10)  // 先设置圆角
//                                    .padding(5)
//                                    .overlay(          // 再用 overlay 添加带圆角的边框
//                                        RoundedRectangle(cornerRadius: 10)
//                                            .stroke(Color.gray, lineWidth: 0.5)
//                                    )
//                            default:
//                                
////                                SwiftMarkdownView("```java\n" + "\(msgContent)")
////                                    .markdownFontSize(fontSettings.fontSize)
////                                    .id("md-\(fontSettings.fontSize)")  // 字体变化时强制重建
////                                    .frame(minHeight: 200)
////                                    .frame(width:UIScreen.main.bounds.width-40)
////                                    .cornerRadius(10)  // 先设置圆角
////                                    .padding(5)
////                                    .overlay(          // 再用 overlay 添加带圆角的边框
////                                        RoundedRectangle(cornerRadius: 10)
////                                            .stroke(Color.gray, lineWidth: 0.5)
////                                    )
//                                VStack{
//                                    HStack{
//                                        Spacer()
//                                        Image("applogo")
//                                            .resizable()
//                                            .frame(width: 40,height:40)
//                                        Text("302.AI")
//                                            .font(.title)
//                                        Spacer()
//                                    }
//                                    
//                                    Text("实时预览功能(Beta)")
//                                        .font(.body)
//                                        .foregroundStyle(.gray)
//                                }
//                                .frame(width:UIScreen.main.bounds.width-40,height:UIScreen.main.bounds.height-250)
//                                .padding(8)
//                                .cornerRadius(10)  // 先设置圆角
//                                .overlay(          // 再用 overlay 添加带圆角的边框
//                                    RoundedRectangle(cornerRadius: 10)
//                                        .stroke(Color.gray, lineWidth: 0.5)
//                                )
//
//                                
//                            }
                        }else{
                            
//                            let htmlContent = "```xml\n" + msgContent + "```"
//                            SwiftMarkdownView(htmlContent)
//                                .frame(width:UIScreen.main.bounds.width-40,height:UIScreen.main.bounds.height-250)
//                                .cornerRadius(10)  // 先设置圆角
//                                .overlay(          // 再用 overlay 添加带圆角的边框
//                                    RoundedRectangle(cornerRadius: 10)
//                                        .stroke(Color.gray, lineWidth: 0.5)
//                                )
                            
                            
                            VStack{
                                
                                Text(msgContent)
                                Spacer()
                            }.frame(width:UIScreen.main.bounds.width-40,height:UIScreen.main.bounds.height-250)
                                .padding(8)
                                .cornerRadius(10)  // 先设置圆角
                                .overlay(          // 再用 overlay 添加带圆角的边框
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(Color.gray, lineWidth: 0.5)
                                )
                        }

                        
                        
                    }
                                        
                }
                
            }.background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.gray.opacity(0.01))
            )
            
            
            Spacer()
        }
        .task {
            if let msg = ConversationMessage(jsonString: msgContent){
                let codeType = detectCodeType(msg.content)
                if codeType == .python {
                    
                    let code = extractPython(msg.content)
                    NetworkManager.shared.executeCode(language: "python3", code: code ?? "") { result in
                        switch result {
                        case .success(let response):
                            if response.code == 0 {
                                runCodeResponse = response.data.stdout
                            } else {
                                runCodeResponse = response.msg
                            }
                        case .failure(let error):
                            runCodeResponse = error.localizedDescription
                        }
                        
                    }
                }
                if  codeType == .javascript{
                    let code = extractJavascript(msg.content)
                    NetworkManager.shared.executeCode(language: "nodejs", code: code ?? "") { result in
                        //runCodeResponse = response
                        
                        switch result {
                        case .success(let response):
                            if response.code == 0 {
                                runCodeResponse = response.data.stdout
                            } else {
                                runCodeResponse = response.msg
                            }
                        case .failure(let error):
                            runCodeResponse = error.localizedDescription
                        }
                    }
                }
            }
        }
        
        .onAppear {
            UIPasteboard.general.string = ""
            UIPasteboard.general.items = []
            
            if let msg = ConversationMessage(jsonString: msgContent) {
                extractCode = combineIntelligently(from: msg.content)
            }else{
                extractCode = combineIntelligently(from: msgContent)
            }
            
        }
    }
    
    
    func combineIntelligently(from text: String) -> String {
        let codeBlocksByLang = extractCompleteCodeBlocksByLanguage(from: text)
        
        if codeBlocksByLang.count == 1, let language = codeBlocksByLang.keys.first {
            // 只有一种语言，直接合并
            return combineByLanguageToMarkdown(from: text)[language] ?? ""
        } else {
            // 多种语言，使用通用格式
            return combineAllToSingleMarkdownBlock(from: text, language: "mixed")
        }
    }
    
    
    func combineByLanguageToMarkdown(from text: String) -> [String: String] {
        let codeBlocksByLang = extractCompleteCodeBlocksByLanguage(from: text)
        var result: [String: String] = [:]
        
        for (language, blocks) in codeBlocksByLang {
            let codeContents = blocks.map { block in
                // 从完整代码块中提取纯代码内容
                extractCodeFromBlock(block)
            }
            
            let combinedCode = codeContents.joined(separator: "\n\n")
            result[language] = "```\(language)\n\(combinedCode)\n```"
        }
        
        return result
    }

    func extractCodeFromBlock(_ codeBlock: String) -> String {
        let lines = codeBlock.components(separatedBy: "\n")
        guard lines.count >= 3 else { return codeBlock }
        
        // 去掉第一行 (```language) 和最后一行 (```)
        return Array(lines[1..<(lines.count-1)]).joined(separator: "\n")
    }
    
    func extractCompleteCodeBlocksByLanguage(from text: String) -> [String: [String]] {
        // 匹配完整的代码块，包括语言标识
        let pattern = "```(\\w+)\\n(.*?\\n)```"
        
        var result: [String: [String]] = [:]
        
        do {
            let regex = try NSRegularExpression(pattern: pattern, options: .dotMatchesLineSeparators)
            let nsString = text as NSString
            let matches = regex.matches(in: text, options: [], range: NSRange(location: 0, length: nsString.length))
            
            for match in matches {
                let languageRange = match.range(at: 1)
                let fullRange = match.range(at: 0) // 整个代码块
                
                let language = nsString.substring(with: languageRange)
                let completeCodeBlock = nsString.substring(with: fullRange)
                
                if result[language] == nil {
                    result[language] = []
                }
                result[language]?.append(completeCodeBlock)
            }
            
        } catch {
            print("正则表达式错误: \(error)")
        }
        
        return result
    }
    
    func combineAllToSingleMarkdownBlock(from text: String, language: String = "text") -> String {
        let codeContents = extractCodeContents(from: text)
        
        if codeContents.isEmpty {
            return "```\(language)\n// 没有找到代码块\n```"
        }
        
        let combinedCode = codeContents.joined(separator: "\n\n")
        return "```\(language)\n\(combinedCode)\n```"
    }

    // 提取纯代码内容（不包含 Markdown 标记）
    func extractCodeContents(from text: String) -> [String] {
        let pattern = "```\\w+\\n(.*?)\\n```"
        
        do {
            let regex = try NSRegularExpression(pattern: pattern, options: .dotMatchesLineSeparators)
            let nsString = text as NSString
            let matches = regex.matches(in: text, options: [], range: NSRange(location: 0, length: nsString.length))
            
            return matches.map { match in
                let range = match.range(at: 1)
                return nsString.substring(with: range)
            }
            
        } catch {
            print("正则表达式错误: \(error)")
            return []
        }
    }
    
    
    func extractCompleteCodeBlocks(from text: String) -> [String] {
        // 匹配完整的 ```language\ncode\n``` 格式
        let pattern = "```\\w+\\n.*?\\n```"
        
        do {
            let regex = try NSRegularExpression(pattern: pattern, options: .dotMatchesLineSeparators)
            let nsString = text as NSString
            let matches = regex.matches(in: text, options: [], range: NSRange(location: 0, length: nsString.length))
            
            return matches.map { match in
                let range = match.range(at: 0) // 获取整个匹配范围
                return nsString.substring(with: range)
            }
            
        } catch {
            print("正则表达式错误: \(error)")
            return []
        }
    }
    
    
    func extractJavascript(_ markdown: String) -> String? {
        // 查找 ```html 和 ``` 之间的内容
        if let startRange = markdown.range(of: "```javascript\n"),
           let endRange = markdown.range(of: "\n```", range: startRange.upperBound..<markdown.endIndex) {
            let htmlContent = String(markdown[startRange.upperBound..<endRange.lowerBound])
            return htmlContent
        }
        return nil
    }
    
    func extractPython(_ markdown: String) -> String? {
        
            // 定义匹配 Python 代码块的正则表达式
            let pattern = "```python\\n([\\s\\S]*?)\\n```"
            
            guard let regex = try? NSRegularExpression(pattern: pattern) else {
                return nil
            }
            
            // 查找第一个匹配项
            if let match = regex.firstMatch(in: markdown, range: NSRange(markdown.startIndex..., in: markdown)) {
                // 提取匹配到的代码范围
                let matchRange = match.range(at: 1)
                if let swiftRange = Range(matchRange, in: markdown) {
                    // 返回提取的代码字符串，并去除首尾空白
                    return String(markdown[swiftRange]).trimmingCharacters(in: .whitespacesAndNewlines)
                }
            }
            
            return nil
        
        // 查找 ```html 和 ``` 之间的内容
//        if let startRange = markdown.range(of: "```python\n"),
//           let endRange = markdown.range(of: "\n```", range: startRange.upperBound..<markdown.endIndex) {
//            let htmlContent = String(markdown[startRange.upperBound..<endRange.lowerBound])
//            return htmlContent
//        }
//        return nil
    }
    
    
    func extractSVG(from text: String) -> String {
        
        // 正则表达式匹配 SVG 标签及其内容
               let pattern = "<svg[^>]*>(.|\\n)*?</svg>"
               
               do {
                   let regex = try NSRegularExpression(pattern: pattern, options: .caseInsensitive)
                   let range = NSRange(location: 0, length: text.utf16.count)
                   
                   if let match = regex.firstMatch(in: text, options: [], range: range) {
                       let matchedRange = match.range
                       if let swiftRange = Range(matchedRange, in: text) {
                           return String(text[swiftRange])
                       }
                   }
               } catch {
                   print("正则表达式错误: \(error.localizedDescription)")
                   return error.localizedDescription
               }
        return ""
    }
    
    
    private func processMarkdownContent(_ text: String) -> String {
           // 1. 替换HTML特殊字符
           var processed = text
               .replacingOccurrences(of: "<", with: "&lt;")
               .replacingOccurrences(of: ">", with: "&gt;")
           
           // 2. 确保代码块有正确换行
           processed = processed.replacingOccurrences(of: "```html", with: "\n```html\n")
           
           return processed
       }

    func extractSvgCode(from text: String) -> String {
        // 正则表达式匹配 SVG 标签及其内容
               let pattern = "```xml[^>]*>(.|\\n)*?```"
               
               do {
                   let regex = try NSRegularExpression(pattern: pattern, options: .caseInsensitive)
                   let range = NSRange(location: 0, length: text.utf16.count)
                   
                   if let match = regex.firstMatch(in: text, options: [], range: range) {
                       let matchedRange = match.range
                       if let swiftRange = Range(matchedRange, in: text) {
                           return String(text[swiftRange])
                       }
                   }
               } catch {
                   print("正则表达式错误: \(error.localizedDescription)")
                   return ""
               }
        return ""
    }
    
    func extractHTMLFromMarkdown(_ markdown: String) -> String? {
        // 查找 ```html 和 ``` 之间的内容
        if let startRange = markdown.range(of: "```html\n"),
           let endRange = markdown.range(of: "\n```", range: startRange.upperBound..<markdown.endIndex) {
            let htmlContent = String(markdown[startRange.upperBound..<endRange.lowerBound])
            return htmlContent
        }
        return nil
    }
     
     
}


struct SegmentedControl<Element: Hashable>: View {
    let items: [Element]
    @Binding var selectedItem: Element
    let titleProvider: (Element) -> String
    
    // 自定义样式
    var activeColor: Color = .purple
    var inactiveColor: Color = .gray
    var backgroundColor: Color = .clear
    var cornerRadius: CGFloat = 8
    var padding: CGFloat = 4
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach(items, id: \.self) { item in
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        selectedItem = item
                    }
                }) {
                    Text(titleProvider(item))
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(selectedItem == item ? .white : inactiveColor)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                        .contentShape(Rectangle())
                }
                .background(
                    selectedItem == item ? activeColor : backgroundColor
                )
            }
        }
        .background(
            RoundedRectangle(cornerRadius: cornerRadius)
                .fill(backgroundColor)
                .overlay(
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .stroke(inactiveColor, lineWidth: 1)
                )
        )
        .cornerRadius(cornerRadius)
        .padding(padding)
    }
}

 
struct MyWebView: UIViewRepresentable {
    let htmlString: String
    
    func makeUIView(context: Context) -> WKWebView {
        return WKWebView()
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {
        uiView.loadHTMLString(htmlString, baseURL: nil)
    }
}

struct SVGWebView: View {
    let inputText: String
    @State private var svgData: String?
    @State private var htmlData: String?
    @State private var jsData: String?
    @State private var pythonData: String?
    
    
    @State private var codeType : CodeType?
    
    var body: some View {
        
        Group {
            
            if  (svgData != nil) {
                MyWebView(htmlString: createHTMLPage(svgContent: svgData ?? ""))
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if (htmlData != nil){
                MyWebView(htmlString:  htmlData ?? "")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                Text("没有可预览的数据")
                    .foregroundColor(.gray)
            }
             
        }
        .onAppear {
            if let msg = ConversationMessage(jsonString: inputText) {
                 
                
                print("msg!.content: \(msg.content)")
                let result = detectCodeType(msg.content)
                // 使用 switch 处理检测结果
                switch result {
                case .html:
                    codeType = .html
                    htmlData = extractHTMLFromMarkdown(inputText)
                case .svg:
                    
                    codeType = .svg
                    extractSVG(from: msg.content)
                    
                case .javascript:
                    codeType = .javascript
                     
                    jsData = extractSingleJavaScriptCode(from: inputText)
                    
                case .python:
                    codeType = .python
                case .unknown:
                    codeType = .unknown
                }
                        
            }else{
                
                let result = detectCodeType(inputText)
                // 使用 switch 处理检测结果
                switch result {
                case .html:
                    codeType = .html
                    htmlData = extractHTMLFromMarkdown( inputText)
                case .svg:
                    
                    codeType = .svg
                    extractSVG(from: inputText)
                    
                case .javascript:
                    codeType = .javascript
                    
                    jsData = extractSingleJavaScriptCode(from: inputText)
                    
                case .python:
                    codeType = .python
                case .unknown:
                    codeType = .unknown
                }
                
                
            }
        }
    }
    
    func extractSingleJavaScriptCode(from text: String) -> String? {
        let pattern = "```javascript\\n([\\s\\S]*?)\\n```"
        
        guard let regex = try? NSRegularExpression(pattern: pattern) else {
            return nil
        }
        
        // 修正后的正确写法
        if let match = regex.firstMatch(in: text, range: NSRange(text.startIndex..., in: text)) {
            let matchRange = match.range(at: 1)
            if let swiftRange = Range(matchRange, in: text) {
                return String(text[swiftRange])
            }
        }
        
        return nil
    }
    
    func extractHTMLFromMarkdown(_ markdown: String) -> String? {
        // 查找 ```html 和 ``` 之间的内容
        if let startRange = markdown.range(of: "```html\n"),
           let endRange = markdown.range(of: "\n```", range: startRange.upperBound..<markdown.endIndex) {
            let htmlContent = String(markdown[startRange.upperBound..<endRange.lowerBound])
            return htmlContent
        }
        return nil
    }
    
    
    func extractSVG(from text: String) {
        // 正则表达式匹配 SVG 标签及其内容
               let pattern = "<svg[^>]*>(.|\\n)*?</svg>"
               
               do {
                   let regex = try NSRegularExpression(pattern: pattern, options: .caseInsensitive)
                   let range = NSRange(location: 0, length: text.utf16.count)
                   
                   if let match = regex.firstMatch(in: text, options: [], range: range) {
                       let matchedRange = match.range
                       if let swiftRange = Range(matchedRange, in: text) {
                           svgData = String(text[swiftRange])
                       }
                   }
               } catch {
                   print("正则表达式错误: \(error.localizedDescription)")
               }
    }
    
    private func createHTMLPage(svgContent: String) -> String {
        """
        <!DOCTYPE html>
        <html>
        <head>
            <meta name="viewport" content="width=device-width, initial-scale=1.0">
            <style>
                body { margin: 0; padding: 0; display: flex; justify-content: center; align-items: center; }
                svg { max-width: 100%; height: auto; }
            </style>
        </head>
        <body>
            \(svgContent)
        </body>
        </html>
        """
    }
}




func detectCodeType(_ code: String) -> CodeType {
    let trimmedCode = code.trimmingCharacters(in: .whitespacesAndNewlines)
    
    
    // HTML 检测
    let htmlPattern = "```html"//"<[a-z][\\s\\S]*?>"
    if code.contains(htmlPattern){//trimmedCode.range(of: htmlPattern, options: .regularExpression) != nil {
        return .html
    }
    
    // SVG 检测（优先于 HTML 检测）
    let svgPatterns = [
        "<svg[\\s\\S]*?>[\\s\\S]*<\\/svg>"
//        "<svg[\\s\\S]*?\\/>",
//        "viewBox=\"[^\"]*\"",
//        "d=\"[^\"]*\"",  // 路径数据
//        "<path\\s",
//        "<circle\\s",
//        "<rect\\s",
//        "<polygon\\s"
    ]
    if svgPatterns.contains(where: { trimmedCode.range(of: $0, options: .regularExpression) != nil }) {
        return .svg
    }
    
    
    
    // JavaScript 检测
    let jsPatterns = [
        "```javascript",
        "function\\s+[a-zA-Z_$][0-9a-zA-Z_$]*\\s*\\([^)]*\\)\\s*\\{[^}]*\\}",
        "const\\s+|let\\s+|var\\s+",
        "=>\\s*\\{",
        "console\\.log\\("
    ]
    if jsPatterns.contains(where: { trimmedCode.range(of: $0, options: .regularExpression) != nil }) {
        return .javascript
    }
    
    
    let pythonPatterns = "```python"
    if trimmedCode.contains(pythonPatterns) {
        return .python
    }
    
    // Python 检测
//    let pythonPatterns = [
//        "^\\s*def\\s+[a-zA-Z_][a-zA-Z0-9_]*\\s*\\([^)]*\\):",
//        "^\\s*class\\s+[a-zA-Z_][a-zA-Z0-9_]*\\s*:",
//        "^\\s*import\\s+|^\\s*from\\s+",
//        "^\\s*print\\s*\\(",
//        "^\\s*if\\s+.+:",
//        "^\\s*for\\s+.+\\s+in\\s+.+:"
//    ]
//    if pythonPatterns.contains(where: { trimmedCode.range(of: $0, options: .regularExpression) != nil }) {
//        return .python
//    }
    
    return .unknown
}

//func isHtml(code:String) -> String{
//    // 检测常规 HTML 标签
//        let tagPattern = "<[a-z][\\s\\S]*?>"
//        
//        // 检测 Markdown 代码块中的 HTML
//        let markdownHtmlPattern = "```html\\n[\\s\\S]*?```"
//        
//        // 检测 DOCTYPE 声明
//        //let doctypePattern = "<!DOCTYPE html>"
//        
//        // 检测完整的 HTML 结构
//        let fullHtmlPattern = "<html[\\s\\S]*?>[\\s\\S]*<\\/html>"
//        
//        return code.range(of: tagPattern, options: .regularExpression) != nil || code.range(of: markdownHtmlPattern, options: .regularExpression) != nil || code.range(of: doctypePattern, options: .regularExpression) != nil || code.range(of: fullHtmlPattern, options: .regularExpression) != nil
//}
 
