//
//  AssistantMessageView2.swift
//  GPTalks
//
//  Created by Adswave on 2025/6/16.
//

import SwiftUI
import SwiftMarkdownView
import MarkdownUI
import ActivityIndicatorView
import AlertToast
import Toasts
//import LaTeXSwiftUI
import WKMarkdownView


struct AssistantMessageView2: View {
    @Environment(\.colorScheme) var colorScheme
    @StateObject var fontSettings = FontSettings()
    
    
    //@Environment(DialogueViewModel.self) private var viewModel //截长图时会崩溃 
    @Environment(\.presentToast) var presentToast
    
    @State var conversation: Conversation
    @Bindable var session: DialogueSession
    var isQuick: Bool = false
    @FocusState var focused: Bool
    
    @State var textContent = ""
    @State var codeContent = ""
    
    @State private var showContextMenu = false
    @State var isHovered = false
    @State var hoverxyz = false
    
    @State var canSelectText = false
    @State private var showLoadingIndicator: Bool = true
//    @Binding var isPresented: Bool

    @State private var isExpandedReasoning = true
    @State private var like = false
    @State private var unlike = false
    @Binding var showFeedback: Bool
    
    //var previewBtnTap: (Bool) -> Void
    @State private var showPreview: Bool = false
    //@State private var textHeight:CGFloat = 0.1
    
    @StateObject private var speechSynthesizer = SpeechSynthesizer()
    @State private var buttons  = [
        ButtonData(name:"复制"),
        ButtonData(name: "赞0"),
        ButtonData(name: "踩0"),
        ButtonData(name: "重试")
        
        /*
        ButtonData(name: "刷新"),
        ButtonData(name: "删除"), 
        ButtonData(name: "复制"),
        ButtonData(name: "播放"),
        ButtonData(name: "可见")
         */
    ]
    
    var conversationLike: Bool  {
        
        return UserDefaults.standard.bool(forKey: "\(conversation.id.uuidString)_like")
    }
    
    var conversationUnlike: Bool{
        
        
        return UserDefaults.standard.bool(forKey: "\(conversation.id.uuidString)_unlike")
    }
    
    
    
    //private let buttonImageNames = ["刷新","删除","钉住","复制","播放"]
    @State private var showButtons = true //展示一排操作按钮
    @State var isShowToast = false
    @State private var hintText: String?
    @State private var codeFileName = "正在生成代码"
    
    
    var body: some View {
        ZStack{
            alternateUI
                .padding(.top,8)
            
            #if os(macOS)
            .onHover { isHovered in
                self.isHovered = isHovered
            }
            #else
            
            
            
            .sheet(isPresented: $canSelectText) {
                 
                if let message = ConversationMessage(jsonString: conversation.content) {
                    TextSelectionView(content: message.content)
                }else{
                    TextSelectionView(content: conversation.content)
                }
            }
            .contextMenu {
                //长按弹窗
                MessageContextMenu(session: session, conversation: conversation,
                toggleTextSelection: {
                    canSelectText.toggle()
                })
                .labelStyle(.titleAndIcon)
            }
            #endif
        }
        .toast(isPresenting: $isShowToast){
               
            AlertToast(displayMode: .alert, type: .regular, title: hintText)
        }
        
        .sheet(isPresented: $showPreview) {
            
            
            PreviewCode(msgContent: conversation.content)
            
        }
    }
    
    
    @ViewBuilder
    var alternateUI: some View {
        VStack(alignment: .trailing) {
            
            Spacer()
            
            //内容
            VStack(alignment: .center, spacing: 0) {
                
                Group {
                    if AppConfiguration.shared.isMarkdownEnabled {
                        Spacer().frame(height: 8)
                        
                        //回复中...
                        if session.isReplying && !AppConfiguration.shared.isWebSearch {
                            //解析JSON
                            if let message = ConversationMessage(jsonString: conversation.content) {
                                if AppConfiguration.shared.isR1Fusion || !message.reasoning.isEmpty {
                                    VStack{
                                        
                                        Group{
                                            if conversation.isReplying {
                                                HStack {
                                                    Text("已深度思考(\(message.timeCostString))秒")
                                                        .font(.system(size: fontSettings.fontSize-1))
                                                        .foregroundStyle(.secondary)
                                                    Image(systemName: conversation.expandedReasoning ? "chevron.up" : "chevron.down")
                                                        .foregroundColor(.gray)
                                                    Spacer()
                                                }
                                            }else{
                                                HStack {
                                                    HStack {
                                                        Image(systemName: "checkmark.circle.fill")
                                                            .foregroundColor(Color.init(hex: "#8E47F0"))
                                                        Text("思考完成")
                                                            .font(.system(size: fontSettings.fontSize-1))
                                                            .foregroundStyle(Color.init(hex: "#8E47F0"))
                                                        Image(systemName: conversation.expandedReasoning ? "chevron.up" : "chevron.down")
                                                            .foregroundColor(Color.init(hex: "#8E47F0"))
                                                        //Spacer()
                                                    }
                                                    .frame(height: 30)
                                                    .padding(.horizontal,6)
                                                    .background(Color.purple.opacity(0.2))
                                                    .cornerRadius(6)
                                                    Spacer()
                                                }
                                            }
                                        }
                                    }
                                    .offset(y:-6)
                                    .hidden(conversation.content.isEmpty)
                                    .contentShape(Rectangle())
                                    .onTapGesture {
                                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                            isExpandedReasoning.toggle()
                                            conversation.expandedReasoning.toggle()
                                            
                                            let data = Conversation.createConversationData(from: conversation, in: PersistenceController.shared.container.viewContext)
                                            
                                            data.sync(with: conversation)
                                        }
                                    }
                                    
                                    if isExpandedReasoning {
                                        
                                        
                                        if message.reasoning.count > 2000 {
                                            HStack{
                                                SwiftMarkdownView(message.reasoning)
                                                    .cornerRadius(10)
                                                    .padding([.top,.bottom], 15)
                                                    .padding([.leading], 13)
                                                    .padding(.trailing,5)
                                                    .contentShape(RoundedRectangle(cornerRadius: 10))
                                                    .frame(minHeight: 40)
                                                    .background(
                                                        RoundedRectangle(cornerRadius: 10)
                                                            .fill(Color.clear)
                                                    )
                                                Spacer(minLength: 0)
                                            }
                                        }else{
                                            Text(message.reasoning)
                                                .cornerRadius(10)
                                                .font(.system(size: fontSettings.fontSize-1))
                                                .padding(.top, 1)
                                                .padding(.bottom, 0)
                                                .foregroundStyle(.secondary)
                                                .padding([.leading, .trailing], 0)
                                                .contentShape(RoundedRectangle(cornerRadius: 10))
                                                .frame(minHeight: 40)
                                                .offset(y:-8)
                                                .foregroundStyle(.gray)
                                                .background(
                                                    RoundedRectangle(cornerRadius: 10)
                                                        .fill(Color.gray.opacity(0.01))
                                                )
                                                .transition(.asymmetric(
                                                    insertion: .opacity.combined(with: .move(edge: .leading)),
                                                    removal: .opacity
                                                ))
                                        }
                                    }
                                    
                                }
                                 
                                
                                HStack{
                                    //SwiftMarkdownView(message.content)
                                    Markdown(message.content)
                                        .markdownTextStyle {
                                            FontSize(fontSettings.fontSize)
                                        }
                                        .codeBlockStyle(
                                            theme: .adaptiveTheme(for: .light, fontSize: fontSettings.fontSize),
                                            fontSize: fontSettings.fontSize
                                        )
                                        .markdownCodeSyntaxHighlighter(.splash(theme: .adaptiveTheme(for: .light, fontSize: fontSettings.fontSize)))
                                    
                                        .id("md-\(fontSettings.fontSize)")  // 字体变化时强制重建
                                        .cornerRadius(10)
                                        .padding([.bottom], 5)
                                        .padding([.leading], 8)
                                        .padding(.trailing,5)
                                        .contentShape(RoundedRectangle(cornerRadius: 10))
                                        .frame(minHeight: message.content.isEmpty ? 0 : 40)
                                        .background(
                                            RoundedRectangle(cornerRadius: 10)
                                                .fill(Color.clear)
                                        )
                                        .hidden(message.content.isEmpty)
                                    Spacer()
                                }
                                
                                if conversation.isReplying {
                                    VStack{
                                        HStack{
                                            //加载中
                                            Spacer().frame(width: 10)
                                            ActivityIndicatorView(isVisible: $showLoadingIndicator, type: .opacityDots(count: 3, inset: 2))
                                                .frame(width: 30, height: 5)
                                                .offset(y:0)
                                                .foregroundStyle(.gray)
                                            Spacer()
                                        }
                                        Spacer().frame(height: 5)
                                    }
                                }
                                
                                let  formatName = detectCodeType(conversation.content)
                                if formatName != .unknown {
                                    Button(action: {
                                        // 按钮点击操作
                                        showPreview = true
                                    }) {
                                        HStack {
                                            Image("代码")
                                                .resizable()
                                                .frame(width: 35, height: 35)
                                            
                                            let filename = conversation.codeFileName != "" ? conversation.codeFileName : generateTimestampString()
                                            Text("\(filename).\(formatName)")
                                                .foregroundColor(.primary)
                                            Spacer()
                                            Image(systemName: "chevron.right")
                                                .foregroundColor(.gray)
                                        }
                                        .padding(12) // 增加内边距让按钮更易点击
                                        .frame(maxWidth: .infinity)
                                        .background(Color.gray.opacity(0.1)) // 浅灰色背景
                                        .cornerRadius(8) // 圆角
                                    }
                                    .padding(.horizontal, 2)
                                }
                            }else
                            {
                                //不解析JSON 取conversation.content
                                HStack {
                                    VStack(alignment:.leading){
                                        if checkForMathExpression(in: conversation.content) {
                                            HStack{
                                                //适用数学公式显示
                                                MarkdownView(convertLatexFormat( conversation.content))
                                                    .cornerRadius(10)
                                                    .padding([.top,.bottom], 15)
                                                    .padding([.leading], 13)
                                                    .padding(.trailing,5)
                                                    .contentShape(RoundedRectangle(cornerRadius: 10))
                                                    .frame(minHeight: 40)
                                                    .background(
                                                        RoundedRectangle(cornerRadius: 10)
                                                            .fill(Color.clear)
                                                    )
                                                
                                                Spacer(minLength: 0)
                                            }
                                            
                                        }else{
                                            if conversation.content.count > 3000 {
                                                HStack{
                                                    SwiftMarkdownView(conversation.content)
                                                        .cornerRadius(10)
                                                        .padding([.top,.bottom], 15)
                                                        .padding([.leading], 13)
                                                        .padding(.trailing,5)
                                                        .contentShape(RoundedRectangle(cornerRadius: 10))
                                                        .frame(minHeight: 40)
                                                        .background(
                                                            RoundedRectangle(cornerRadius: 10)
                                                                .fill(Color.clear)
                                                        )
                                                    Spacer(minLength: 0)
                                                }
                                                
                                            }else{
                                                HStack {
                                                    Markdown(conversation.content)
                                                    .frame(minWidth:100,minHeight:20)
                                                    .cornerRadius(10)
                                                    .font(.body)
                                                    .background(
                                                        RoundedRectangle(cornerRadius: 10)
                                                            .fill(Color.clear)
                                                    )
                                                    .contentShape(RoundedRectangle(cornerRadius: 10))
                                                    .hidden(conversation.content.isEmpty)
                                                    
                                                    .onTapGesture {
                                                        withAnimation {
                                                            //showButtons.toggle()
                                                        }
                                                    }
                                                
                                                Spacer()
                                            }
                                                
                                            }
                                            
                                            
                                            /*if conversation.content.count > 20 {
                                                if conversation.content.count > 3000 {
                                                    HStack{
                                                        SwiftMarkdownView(conversation.content)
                                                            .cornerRadius(10)
                                                            .padding([.top,.bottom], 15)
                                                            .padding([.leading], 13)
                                                            .padding(.trailing,5)
                                                            .contentShape(RoundedRectangle(cornerRadius: 10))
                                                            .frame(minHeight: 40)
                                                            .background(
                                                                RoundedRectangle(cornerRadius: 10)
                                                                    .fill(Color.clear)
                                                            )
                                                        Spacer(minLength: 0)
                                                    }
                                                }else{
                                                    HStack{
                                                        Markdown(conversation.content)
                                                            .markdownTextStyle {
                                                                FontSize(fontSettings.fontSize)
                                                            }
                                                            .codeBlockStyle(
                                                                theme: .adaptiveTheme(for: colorScheme, fontSize: fontSettings.fontSize),
                                                                fontSize: fontSettings.fontSize
                                                            )
                                                            .markdownCodeSyntaxHighlighter(.splash(theme: .adaptiveTheme(for: colorScheme, fontSize: fontSettings.fontSize)))
                                                        
                                                            .cornerRadius(10)
                                                            .contentShape(RoundedRectangle(cornerRadius: 10))
                                                            .frame(minHeight: 40)
                                                            .background(
                                                                RoundedRectangle(cornerRadius: 10)
                                                                    .fill(Color.clear)
                                                            )
                                                        Spacer(minLength: 0)
                                                    }
                                                }
                                             } else{
                                                HStack {
                                                    CustomText(conversation.content)
                                                        .frame(minWidth:100,minHeight:20)
                                                        .cornerRadius(10)
                                                        .font(.body)
                                                        .background(
                                                            RoundedRectangle(cornerRadius: 10)
                                                                .fill(Color.clear)
                                                        )
                                                        .contentShape(RoundedRectangle(cornerRadius: 10))
                                                        .hidden(conversation.content.isEmpty)
                                                        
                                                        .onTapGesture {
                                                            withAnimation {
                                                                //showButtons.toggle()
                                                            }
                                                        }
                                                    
                                                    Spacer()
                                                }
                                            }*/
                                        }
                                        //MARK: - 底部操作按钮
                                        if  conversation.arguments.isEmpty && !conversation.content.isEmpty{
                                            let btnCount = AppConfiguration.shared.previewOn ? 5 : 4
                                            HStack(spacing: 0){
                                                ScrollView(.horizontal, showsIndicators: false) {
                                                    HStack(spacing: 0) {
                                                        ForEach(0..<buttons.count, id: \.self) { index in
                                                            Button(action: {
                                                                print("Button \(index) tapped")
                                                                buttonAction(index: index,con: conversation)
                                                                
                                                            }) {
                                                                ZStack {
                                                                    // 按钮背景（46×30，圆角15）
                                                                    RoundedRectangle(cornerRadius: 8)
                                                                        .frame(width: 32, height: 32)
                                                                        //.foregroundStyle(Color.init(hex: "F9F9F9"))
                                                                        .foregroundStyle(Color.clear)
                                                                    // 图片（缩小显示，宽高20×20）
                                                                    if index == 1 {
                                                                        Image(conversationLike ? "赞1" : "赞0")
                                                                            .resizable()
                                                                            .scaledToFit()
                                                                            .frame(width: 30, height: 30)
                                                                    }
                                                                    else if index == 2 {
                                                                        Image(conversationUnlike ? "踩1" : "踩0")
                                                                            .resizable()
                                                                            .scaledToFit()
                                                                            .frame(width: 30, height: 30)
                                                                    } else {
                                                                        Image(buttons[index].name)
                                                                            .resizable()
                                                                            //.renderingMode(.template)
                                                                            .scaledToFit()
                                                                            //.foregroundColor(.clear)
                                                                            .frame(width: 30, height: 30)
                                                                    }
                                                                }
                                                                
                                                            }.frame(width: 44, height: 44)
                                                                .contentShape(Rectangle())
                                                        }
                                                        
                                                    }
                                                }
                                                
                                                .transition(.opacity)
                                                .padding(.top,0)
                                                .padding(.horizontal,10)
                                                .offset(x:-15)
                                                .frame(height: 46)
                                                
                                                Spacer()
                                                Menu {
                                                    // 1. 分享按钮
    //                                                    Button(action: {
    //                                                        print("分享 tapped")
    //                                                        hintText = "分享,开发中"
    //                                                        isShowToast.toggle()
    //                                                    }) {
    //                                                        HStack {
    //                                                            Image("分享")
    //                                                                .resizable()
    //                                                                .frame(width: 20, height: 20)
    //                                                            Text("分享".localized())
    //                                                        }
    //                                                    }
                                                    
                                                    // 2. 截图按钮
                                                    Button(action: {
                                                        print("截图 tapped")
                                                        
                                                        NotificationCenter.default.post(name: .screenSnapshot, object: nil)
                                                        
                                                    }) {
                                                        HStack {
                                                            Image("截图")
                                                                .resizable()
                                                                .frame(width: 20, height: 20)
                                                            Text("截图".localized())
                                                        }
                                                    }
                                                    
                                                    // 3. 选择文本按钮
                                                    Button(action: {
                                                        print("选择文本 tapped")
                                                        canSelectText.toggle()
                                                    }) {
                                                        HStack {
                                                            Image("选择文本")
                                                                .resizable()
                                                                .frame(width: 20, height: 20)
                                                            Text("选择文本".localized())
                                                        }
                                                    }
                                                    
                                                    // 4. 档案库按钮
    //                                                    Button(action: {
    //                                                        print("档案库 tapped")
    //                                                        hintText = "档案库,开发中"
    //                                                        isShowToast.toggle()
    //                                                    }) {
    //                                                        HStack {
    //                                                            Image("档案库")
    //                                                                .resizable()
    //                                                                .frame(width: 20, height: 20)
    //                                                            Text("档案库".localized())
    //                                                        }
    //                                                    }
    //
    //                                                    // 5. 知识库按钮
    //                                                    Button(action: {
    //                                                        print("知识库 tapped")
    //                                                        hintText = "知识库,开发中"
    //                                                        isShowToast.toggle()
    //                                                    }) {
    //                                                        HStack {
    //                                                            Image("知识库")
    //                                                                .resizable()
    //                                                                .frame(width: 20, height: 20)
    //                                                            Text("知识库".localized())
    //                                                        }
    //                                                    }
                                                } label: {
                                                    ZStack {
                                                        // 按钮背景（46×30，圆角15）
                                                        RoundedRectangle(cornerRadius: 8)
                                                            .frame(width: 32, height: 32)
                                                        //.foregroundStyle(.background)
                                                            //.foregroundStyle(Color.init(hex: "F9F9F9"))
                                                            .foregroundStyle(Color.clear)
                                                        // 图片（缩小显示，宽高20×20）
                                                        Image("更多")
                                                            .resizable()
                                                            //.renderingMode(.template)
                                                            .scaledToFit()
                                                            //.foregroundColor(.gray)
                                                            .frame(width: 30, height: 30)
                                                    }
                                                }
                                                    
                                            }
                                            .padding(0)
                                            
                                        }
                                        
                                    }
                                    .offset(y:5)
                                    .hidden(conversation.content.isEmpty)
                                    
                                }.offset(y:5)
                                
                                if conversation.isReplying {
                                    VStack{
                                        Spacer().frame(height: 5)
                                        HStack{
                                            //加载中
                                            Spacer().frame(width: 10)
                                            ActivityIndicatorView(isVisible: $showLoadingIndicator, type: .opacityDots(count: 3, inset: 2))
                                                .frame(width: 30, height: 5)
                                                .offset(y:0)
                                                .foregroundStyle(.gray)
                                            Spacer()
                                        }
                                        Spacer().frame(height: 5)
                                    }
                                }
                                
                                let  formatName = detectCodeType(conversation.content)
                                if formatName != .unknown {
                                    Button(action: {
                                        // 按钮点击操作
                                        showPreview = true
                                    }) {
                                        HStack {
                                            Image("代码")
                                                .resizable()
                                                .frame(width: 35, height: 35)
                                            
                                            let filename = conversation.codeFileName != "" ? conversation.codeFileName : generateTimestampString()
                                            Text("\(filename).\(formatName)")
                                                .foregroundColor(.primary)
                                            Spacer()
                                            Image(systemName: "chevron.right")
                                                .foregroundColor(.gray)
                                        }
                                        .padding(12) // 增加内边距让按钮更易点击
                                        .frame(maxWidth: .infinity)
                                        .background(Color.gray.opacity(0.1)) // 浅灰色背景
                                        .cornerRadius(8) // 圆角
                                    }
                                    .padding(.horizontal, 2)
                                }
                            }
                        }else{
                            if let message = ConversationMessage(jsonString: conversation.content) {
                                if AppConfiguration.shared.isR1Fusion || !message.reasoning.isEmpty {
                                    VStack{
                                        
                                        Group{
                                            if conversation.isReplying {
                                                HStack {
                                                    Text("已深度思考(\(message.timeCostString))秒")
                                                        .font(.system(size: fontSettings.fontSize-1))
                                                        .foregroundStyle(.secondary)
                                                    Image(systemName: conversation.expandedReasoning ? "chevron.up" : "chevron.down")
                                                        .foregroundColor(.gray)
                                                    Spacer()
                                                }
                                            }else{
                                                HStack {
                                                    HStack {
                                                        Image(systemName: "checkmark.circle.fill")
                                                            .foregroundColor(Color.init(hex: "#8E47F0"))
                                                        Text("思考完成")
                                                            .font(.system(size: fontSettings.fontSize-1))
                                                            .foregroundStyle(Color.init(hex: "#8E47F0"))
                                                        Image(systemName: conversation.expandedReasoning ? "chevron.up" : "chevron.down")
                                                            .foregroundColor(Color.init(hex: "#8E47F0"))
                                                        //Spacer()
                                                    }
                                                    .frame(height: 30)
                                                    .padding(.horizontal,6)
                                                    .background(Color.purple.opacity(0.2))
                                                    .cornerRadius(6)
                                                    Spacer()
                                                }
                                            }
                                        }
                                        
                                        
                                    }
                                    .offset(y:-6)
                                    .hidden(conversation.content.isEmpty)
                                    .contentShape(Rectangle())
                                    .onTapGesture {
                                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                            isExpandedReasoning.toggle()
                                            conversation.expandedReasoning.toggle()
                                            
                                            let data = Conversation.createConversationData(from: conversation, in: PersistenceController.shared.container.viewContext)
                                            
                                            data.sync(with: conversation)
                                        }
                                    }
                                    
                                    if isExpandedReasoning {
                                            
                                            
                                            Text(message.reasoning)
                                                .cornerRadius(10)
                                                .font(.system(size: fontSettings.fontSize-1))
                                                .padding(.top, 1)
                                                .padding(.bottom, 0)
                                                .foregroundStyle(.secondary)
                                                .padding([.leading, .trailing], 0)
                                                .contentShape(RoundedRectangle(cornerRadius: 10))
                                                .frame(minHeight: 40)
                                                .offset(y:-8)
                                                .foregroundStyle(.gray)
                                                .background(
                                                    RoundedRectangle(cornerRadius: 10)
                                                        .fill(Color.gray.opacity(0.01))
                                                )
                                                .transition(.asymmetric(
                                                    insertion: .opacity.combined(with: .move(edge: .leading)),
                                                    removal: .opacity
                                                ))
                                        
                                    }
                                    
                                }
                                
                                
                                HStack{
                                    //SwiftMarkdownView(message.content)
                                    Markdown(message.content)
                                        .markdownTextStyle {
                                            FontSize(fontSettings.fontSize)
                                        }
                                        .codeBlockStyle(
                                            theme: .adaptiveTheme(for: .light, fontSize: fontSettings.fontSize),
                                            fontSize: fontSettings.fontSize
                                        )
                                        .markdownCodeSyntaxHighlighter(.splash(theme: .adaptiveTheme(for: .light, fontSize: fontSettings.fontSize)))
                                    
                                        .id("md-\(fontSettings.fontSize)")  // 字体变化时强制重建
                                        .cornerRadius(10)
                                        .padding([.bottom], 5)
                                        .padding([.leading], 8)
                                        .padding(.trailing,5)
                                        .contentShape(RoundedRectangle(cornerRadius: 10))
                                        .frame(minHeight: message.content.isEmpty ? 0 : 40)
                                        .background(
                                            RoundedRectangle(cornerRadius: 10)
                                                .fill(Color.clear)
                                        )
                                        .hidden(message.content.isEmpty)
                                    Spacer()
                                }
                                
                                if conversation.isReplying {
                                    VStack{
                                        HStack{
                                            //加载中
                                            Spacer().frame(width: 10)
                                            ActivityIndicatorView(isVisible: $showLoadingIndicator, type: .opacityDots(count: 3, inset: 2))
                                                .frame(width: 30, height: 5)
                                                .offset(y:0)
                                                .foregroundStyle(.gray)
                                            Spacer()
                                        }
                                        Spacer().frame(height: 5)
                                    }
                                }
                            }else{
                                //不解析JSON  取值conversation.content
                                Group{
                                    VStack(alignment:.leading){
                                        if checkForMathExpression(in: conversation.content) {
                                            HStack{
                                                //适用数学公式显示
                                                MarkdownView(convertLatexFormat( conversation.content))
                                                    .cornerRadius(10)
                                                    .padding([.top,.bottom], 15)
                                                    .padding([.leading], 13)
                                                    .padding(.trailing,5)
                                                    .contentShape(RoundedRectangle(cornerRadius: 10))
                                                    .frame(minHeight: 40)
                                                    .background(
                                                        RoundedRectangle(cornerRadius: 10)
                                                            .fill(Color.clear)
                                                    )
                                                
                                                Spacer(minLength: 0)
                                            }
                                            
                                        }else{
                                            //if conversation.content.count > 20 {
                                            if conversation.content.count > 3000 {
                                                HStack{
                                                    SwiftMarkdownView(conversation.content)
                                                        .cornerRadius(10)
                                                        .padding([.top,.bottom], 15)
                                                        .padding([.leading], 13)
                                                        .padding(.trailing,5)
                                                        .contentShape(RoundedRectangle(cornerRadius: 10))
                                                        .frame(minHeight: 40)
                                                        .background(
                                                            RoundedRectangle(cornerRadius: 10)
                                                                .fill(Color.clear)
                                                        )
                                                    Spacer(minLength: 0)
                                                }
                                            }else{
                                                HStack{
                                                    Markdown(conversation.content)
                                                        .markdownTextStyle {
                                                            FontSize(fontSettings.fontSize)
                                                        }
                                                        .codeBlockStyle(
                                                            theme: .adaptiveTheme(for: colorScheme, fontSize: fontSettings.fontSize),
                                                            fontSize: fontSettings.fontSize
                                                        )
                                                        .markdownCodeSyntaxHighlighter(.splash(theme: .adaptiveTheme(for: colorScheme, fontSize: fontSettings.fontSize)))
                                                    
                                                        .cornerRadius(10)
                                                        .contentShape(RoundedRectangle(cornerRadius: 10))
                                                        .frame(minHeight: 40)
                                                        .background(
                                                            RoundedRectangle(cornerRadius: 10)
                                                                .fill(Color.clear)
                                                        )
                                                    Spacer(minLength: 0)
                                                }
                                            }
                                            /* } else{
                                             HStack {
                                             CustomText(conversation.content)
                                             .frame(minWidth:100,minHeight:20)
                                             .cornerRadius(10)
                                             .font(.body)
                                             .background(
                                             RoundedRectangle(cornerRadius: 10)
                                             .fill(Color.clear)
                                             )
                                             .contentShape(RoundedRectangle(cornerRadius: 10))
                                             .hidden(conversation.content.isEmpty)
                                             
                                             .onTapGesture {
                                             withAnimation {
                                             //showButtons.toggle()
                                             }
                                             }
                                             
                                             Spacer()
                                             }
                                             }*/
                                        }
                                        
                                        
                                    }
                                    
                                }
                                .offset(y:5)
                                .hidden(conversation.content.isEmpty)
                                
                                if conversation.isReplying {
                                    VStack{
                                        Spacer().frame(height: 5)
                                        HStack{
                                            //加载中
                                            Spacer().frame(width: 10)
                                            ActivityIndicatorView(isVisible: $showLoadingIndicator, type: .opacityDots(count: 3, inset: 2))
                                                .frame(width: 30, height: 5)
                                                .offset(y:0)
                                                .foregroundStyle(.gray)
                                            Spacer()
                                        }
                                        Spacer().frame(height: 5)
                                    }
                                }
                            }
                            //MARK: - 底部操作按钮
                            if  conversation.arguments.isEmpty && !conversation.content.isEmpty{
                                let btnCount = AppConfiguration.shared.previewOn ? 5 : 4
                                HStack(spacing: 0){
                                    ScrollView(.horizontal, showsIndicators: false) {
                                        HStack(spacing: 0) {
                                            ForEach(0..<buttons.count, id: \.self) { index in
                                                Button(action: {
                                                    print("Button \(index) tapped")
                                                    buttonAction(index: index,con: conversation)
                                                    
                                                }) {
                                                    ZStack {
                                                        // 按钮背景（46×30，圆角15）
                                                        RoundedRectangle(cornerRadius: 8)
                                                            .frame(width: 32, height: 32)
                                                        //.foregroundStyle(Color.init(hex: "F9F9F9"))
                                                            .foregroundStyle(Color.clear)
                                                        // 图片（缩小显示，宽高20×20）
                                                        if index == 1 {
                                                            Image(conversationLike ? "赞1" : "赞0")
                                                                .resizable()
                                                                .scaledToFit()
                                                                .frame(width: 30, height: 30)
                                                        }
                                                        else if index == 2 {
                                                            Image(conversationUnlike ? "踩1" : "踩0")
                                                                .resizable()
                                                                .scaledToFit()
                                                                .frame(width: 30, height: 30)
                                                        } else {
                                                            Image(buttons[index].name)
                                                                .resizable()
                                                            //.renderingMode(.template)
                                                                .scaledToFit()
                                                            //.foregroundColor(.clear)
                                                                .frame(width: 30, height: 30)
                                                        }
                                                    }
                                                    
                                                }.frame(width: 44, height: 44)
                                                    .contentShape(Rectangle())
                                            }
                                            
                                        }
                                    }
                                    
                                    .transition(.opacity)
                                    .padding(.top,0)
                                    .padding(.horizontal,10)
                                    .offset(x:-15)
                                    .frame(height: 46)
                                    
                                    Spacer()
                                    Menu {
                                        // 1. 分享按钮
                                        /*Button(action: {
                                         print("分享 tapped")
                                         hintText = "分享,开发中"
                                         isShowToast.toggle()
                                         }) {
                                         HStack {
                                         Image("分享")
                                         .resizable()
                                         .frame(width: 20, height: 20)
                                         Text("分享".localized())
                                         }
                                         }*/
                                        
                                        // 2. 截图按钮
                                        Button(action: {
                                            print("截图 tapped")
                                            
                                            NotificationCenter.default.post(name: .screenSnapshot, object: nil)
                                            
                                        }) {
                                            HStack {
                                                Image("截图")
                                                    .resizable()
                                                    .frame(width: 20, height: 20)
                                                Text("截图".localized())
                                            }
                                        }
                                        
                                        // 3. 选择文本按钮
                                        Button(action: {
                                            print("选择文本 tapped")
                                            canSelectText.toggle()
                                        }) {
                                            HStack {
                                                Image("选择文本")
                                                    .resizable()
                                                    .frame(width: 20, height: 20)
                                                Text("选择文本".localized())
                                            }
                                        }
                                        
                                        //4. 档案库按钮
                                        /*Button(action: {
                                         print("档案库 tapped")
                                         hintText = "档案库,开发中"
                                         isShowToast.toggle()
                                         }) {
                                         HStack {
                                         Image("档案库")
                                         .resizable()
                                         .frame(width: 20, height: 20)
                                         Text("档案库".localized())
                                         }
                                         }
                                         
                                         // 5. 知识库按钮
                                         Button(action: {
                                         print("知识库 tapped")
                                         hintText = "知识库,开发中"
                                         isShowToast.toggle()
                                         }) {
                                         HStack {
                                         Image("知识库")
                                         .resizable()
                                         .frame(width: 20, height: 20)
                                         Text("知识库".localized())
                                         }
                                         }*/
                                    } label: {
                                        ZStack {
                                            // 按钮背景（46×30，圆角15）
                                            RoundedRectangle(cornerRadius: 8)
                                                .frame(width: 32, height: 32)
                                            //.foregroundStyle(.background)
                                            //.foregroundStyle(Color.init(hex: "F9F9F9"))
                                                .foregroundStyle(Color.clear)
                                            // 图片（缩小显示，宽高20×20）
                                            Image("更多")
                                                .resizable()
                                            //.renderingMode(.template)
                                                .scaledToFit()
                                            //.foregroundColor(.gray)
                                                .frame(width: 30, height: 30)
                                        }
                                    }
                                    
                                }
                                .padding(0)
                                
                            }
                             
                            let  formatName = detectCodeType(conversation.content)
                            if formatName != .unknown {
                                Button(action: {
                                    // 按钮点击操作
                                    showPreview = true
                                }) {
                                    HStack {
                                        Image("代码")
                                            .resizable()
                                            .frame(width: 35, height: 35)
                                        
                                        let filename = conversation.codeFileName != "" ? conversation.codeFileName : generateTimestampString()
                                        Text("\(filename).\(formatName)")
                                            .foregroundColor(.primary)
                                        Spacer()
                                        Image(systemName: "chevron.right")
                                            .foregroundColor(.gray)
                                    }
                                    .padding(12) // 增加内边距让按钮更易点击
                                    .frame(maxWidth: .infinity)
                                    .background(Color.gray.opacity(0.1)) // 浅灰色背景
                                    .cornerRadius(8) // 圆角
                                }
                                .padding(.horizontal, 2)
                            }
                        }
                                                    
                        //预设提示词
                        if !conversation.arguments.isEmpty {
                            HStack{
                                CustomText(conversation.arguments)
                                    .foregroundStyle(.gray)
                                    .font(.footnote)
                                Spacer()
                            }.offset(y:7)
                        }
                        
                    } else {
                        CustomText(conversation.content)
                            .cornerRadius(10)
                        
                    }
                }
                .offset(x:0,y:conversation.arguments.isEmpty ? -26 : -17) //
                .textSelection(.enabled)
                 
                ForEach(conversation.imagePaths, id: \.self) { imagePath in
                    ImageView2(imageUrlPath: imagePath, imageSize: imageSize, showSaveButton: true)
                }
                 
            }
            .padding([.leading,.trailing],15)
             
            
#if os(macOS)
            HStack {
                Spacer()
                
                messageContextMenu
                    .padding(.leading, 200) // Increase padding to enlarge the invisible hover area
  //                  .background(Color.blue.opacity(0.1)) // Optional: Just to visualize the area during development
                    .contentShape(Rectangle()) // Make the whole padded area hoverable
                    .onHover { isHovered in
                        hoverxyz = isHovered
                    }
                    .animation(.easeInOut(duration: 0.15), value: hoverxyz)
            }
//            .padding(10)
            .padding(.top, -40)
            .padding(.bottom, 3)
            .padding(.horizontal, 18)
#endif
        }
        #if os(macOS)
        .padding(.horizontal, 8)
//        .background(.background.tertiary)
        .background(isQuick ? .regularMaterial :  (colorScheme == .dark ? .ultraThickMaterial : .ultraThinMaterial))
        .background(conversation.content.localizedCaseInsensitiveContains(viewModel.searchText) ? .yellow.opacity(0.4) : .clear)
        #else
        //.background(conversation.content.localizedCaseInsensitiveContains(viewModel.searchText) ? .yellow.opacity(0.1) : .clear)
        //.background(colorScheme == .dark ? Color.gray.opacity(0.12) : Color.gray.opacity(0.05))
        //.background(Color.gray.opacity(0.01))  //背景色
        #endif
//        .animation(.default, value: conversation.content.localizedCaseInsensitiveContains(viewModel.searchText))
        
        .frame(maxWidth: .infinity, alignment: .topLeading)
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
    
    
    
    // 生成 "年_月_日_时_分_秒_毫秒" 格式的字符串
       func generateTimestampString() -> String {
           let date = Date()
           let calendar = Calendar.current
           
           // 获取各个时间组件
           let year = calendar.component(.year, from: date)
           let month = calendar.component(.month, from: date)
           let day = calendar.component(.day, from: date)
           let hour = calendar.component(.hour, from: date)
           let minute = calendar.component(.minute, from: date)
           let second = calendar.component(.second, from: date)
           
           // 获取毫秒
           let nanosecond = calendar.component(.nanosecond, from: date)
           let millisecond = nanosecond / 1_000_000
           
           // 格式化为两位数，确保月份、日期等显示为 01, 02 而不是 1, 2
           return String(format: "%04d%02d%02d%02d%02d%02d%03d%02d",//"%04d_%02d_%02d_%02d_%02d_%02d_%03d",
                        year, month, day, hour, minute, second, millisecond,millisecond)
           
            
       }
    
    
    // 分割 markdown 字符串的方法（保留完整格式）
    func splitMarkdownContent(_ markdownString: String) {
        textContent = ""
        codeContent = ""
        
        // 使用正则表达式匹配完整的代码块（包括 ``` 标记）
        let codeBlockPattern = "```[a-zA-Z]*\\n[\\s\\S]*?```"
        
        do {
            let regex = try NSRegularExpression(pattern: codeBlockPattern, options: [])
            let nsString = markdownString as NSString
            let matches = regex.matches(in: markdownString, options: [], range: NSRange(location: 0, length: nsString.length))
            
            var currentIndex = 0
            
            for match in matches {
                let matchRange = match.range
                
                // 添加代码块之前的文字内容
                if currentIndex < matchRange.location {
                    let textRange = NSRange(location: currentIndex, length: matchRange.location - currentIndex)
                    let text = nsString.substring(with: textRange)
                    if !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                        textContent += text + "\n"
                    }
                }
                
                // 提取完整的代码块（包括 ``` 标记）
                let code = nsString.substring(with: matchRange)
                codeContent += code + "\n\n"
                
                currentIndex = matchRange.location + matchRange.length
            }
            
            // 添加最后一段文字内容
            if currentIndex < nsString.length {
                let textRange = NSRange(location: currentIndex, length: nsString.length - currentIndex)
                let text = nsString.substring(with: textRange)
                if !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    textContent += text
                }
            }
            
        } catch {
            print("正则表达式错误: \(error)")
            // 使用简单的分割方法作为备选
            simpleSplitMarkdown(markdownString)
        }
    }
    
    // 备用的简单分割方法（保留完整格式）
    func simpleSplitMarkdown(_ markdownString: String) {
        let components = markdownString.components(separatedBy: "```")
        
        for (index, component) in components.enumerated() {
            if index % 2 == 0 {
                // 偶数索引是文字内容
                if !component.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    textContent += component
                }
            } else {
                // 奇数索引是代码内容（保留完整格式）
                codeContent += "```" + component + "```\n\n"
            }
        }
    }
    
    
    /// 判断 markdown 字符串是否包含代码块
    func markdownContainsCode(_ markdownString: String) -> Bool {
        // 方法1: 使用正则表达式检测代码块
        let codeBlockPattern = "[\\s\\S]*?"
        do {
            let regex = try NSRegularExpression(pattern: codeBlockPattern, options: [])
            let range = NSRange(location: 0, length: markdownString.utf16.count)
            let matches = regex.matches(in: markdownString, options: [], range: range)
            return !matches.isEmpty
        } catch {
            // 方法2: 简单的字符串检测（备选方案）
            return markdownString.contains("```")
        }
    }
    
    
    /// 计算代码块的数量
    func countCodeBlocks(_ markdownString: String) -> Int {
        let codeBlockPattern = "[\\s\\S]*?"
        
        do {
            let regex = try NSRegularExpression(pattern: codeBlockPattern, options: [])
            let range = NSRange(location: 0, length: markdownString.utf16.count)
            let matches = regex.matches(in: markdownString, options: [], range: range)
            return matches.count
        } catch {
            // 简单的计数方法
            return markdownString.components(separatedBy: "```").count / 2
        }
    }
    
    
    
    /// 检测代码块中使用的编程语言
    func detectCodeLanguages(_ markdownString: String) -> [String] {
        var languages: [String] = []
        // 匹配代码块开头的语言标识
        let languagePattern = "```([a-zA-Z][a-zA-Z0-9]*)"
        
        do {
            let regex = try NSRegularExpression(pattern: languagePattern, options: [])
            let range = NSRange(location: 0, length: markdownString.utf16.count)
            let matches = regex.matches(in: markdownString, options: [], range: range)
            
            for match in matches {
                if match.numberOfRanges > 1 {
                    let languageRange = match.range(at: 1)
                    if let swiftRange = Range(languageRange, in: markdownString) {
                        let language = String(markdownString[swiftRange])
                        languages.append(language)
                    }
                }
            }
        } catch {
            print("语言检测错误: \(error)")
        }
        
        // 如果没有检测到具体语言，但有代码块，则标记为未知
        if languages.isEmpty && markdownContainsCode(markdownString) {
            languages.append("unknown")
        }
        
        return languages
    }
    
    
    
    
    
    private func  removeAntThinking(str:String) -> String {
        
        var cleanString = str.replacingOccurrences(of: "<antThinking>.*?</antThinking>", with: "", options: .regularExpression)
        
        //cleanString = cleanString.replacingOccurrences(of: "<antArtifact.*?>", with: "", options: .regularExpression)
        
        cleanString = cleanString.replacingOccurrences(
            of: "<antArtifact[^>]*>",
            with: "```svg\n",
            options: .regularExpression
        )
        
        cleanString = cleanString.replacingOccurrences(
            of: "</antArtifact>",
            with: "```",
            options: .regularExpression
        )
        
        return cleanString;
    }
    
    
    // 按钮背景色逻辑
       private func buttonBackgroundColor(for index: Int) -> Color {
           let button = buttons[index]
           if button.name == "播放" {
               return speechSynthesizer.isSpeaking ? .blue : .gray
           } else {
               return .gray
           }
       }
    
    
    struct TextWidthPreferenceKey: PreferenceKey {
        static var defaultValue: CGFloat = 0
        
        static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
            value = nextValue()
        }
    }
    
    //MARK: 底部button action
    func buttonAction(index:Int,con:Conversation) {
        
        //buttons index
        
        if index == 0 {
            //复制
            
            if !con.content.isEmpty {
                 
                if let message = ConversationMessage(jsonString: conversation.content) {
                    message.content.copyToPasteboard()
                }else{
                    con.content.copyToPasteboard()
                }
            }
            
            hintText = "已复制"
            isShowToast.toggle()
            // 3秒
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                isShowToast = false
                hintText = nil
            }
        }
        
        if index == 1 {
            //点赞/取消赞
            like.toggle()
            conversation.like.toggle()
            
            UserDefaults.standard.set(conversation.like, forKey: "\(conversation.id.uuidString)_like")
            UserDefaults.standard.synchronize()
            
             //为什么就是无法保存
            //PersistenceController.shared.updateLikeStatusOnly(forId: con.id, isLiked: like)
             
            if let idx = session.conversations.firstIndex(of: con) {
                session.replaceConversation(at: idx, with: conversation)
                //session.conversations[idx] = conversation
            }
                 
            
            //Conversation.createConversationData(from: conversation, in: PersistenceController.shared.container.viewContext).sync(with: conversation)
            
//            if let idx = session.conversations.firstIndex(of: con) {
//                session.conversations[idx] = conversation
//
//                session.save()
//            }
            
            
//            like.toggle()
//            conversation.like.toggle()
//            
//            let data = Conversation.createConversationData(from: conversation, in: PersistenceController.shared.container.viewContext)
//            
//            data.sync(with: conversation)
//            session.save()
            
        }
        
        if index == 2 {
            //踩一踩
            //session.addToTopConversation(con)
             
            unlike.toggle()
            conversation.unlike.toggle()
            showFeedback = true
             
            //PersistenceController.shared.updateUnLikeStatusOnly(forId: con.id, isUnLiked: unlike)
             
            UserDefaults.standard.set(conversation.unlike, forKey: "\(conversation.id.uuidString)_unlike")
            UserDefaults.standard.synchronize()
            
            if let idx = session.conversations.firstIndex(of: con) {
                session.replaceConversation(at: idx, with: conversation)
                //session.conversations[idx] = conversation
            }
        }
        
        
        
        
        if index == 3 {
             
            if let idx = session.conversations.firstIndex(of: con) {
                if idx == 0 {
                    let toast = ToastValue(
                        message: "请重新输入要发送的内容"
                    )
                    presentToast(toast)
                    return
                }
                
                if session.conversations.count > 1 {
                    let conversation = session.conversations[idx-1]
                    if conversation.role == .assistant {
                        let toast = ToastValue(
                            message: "请重新输入要发送的内容"
                        )
                        presentToast(toast)
                        return
                    }
                }
            }
            //重新生成
            Task { @MainActor in
                await session.resend(from: con)
            }
        }
        
        
        /*
        if index == 3 {
            //播放内容
            let buttonName = buttons[index].name
            
            if buttonName == "播放" {
                if speechSynthesizer.isSpeaking {
                    speechSynthesizer.stop() // 停止播放
                } else {
                    if let message = ConversationMessage(jsonString: conversation.content) {
                        speechSynthesizer.speak(message.content){
                            // 播放完成后的回调（可选）
                            print("播放完成")
                        }
                    }else{
                        speechSynthesizer.speak(conversation.content){
                            // 播放完成后的回调（可选）
                            print("播放完成")
                        }
                    }
                }
            } else {
                print("点击了：\(buttonName)")
            }
        }
        
        if index == 4 {
            //previewBtnTap(true)
            
            showPreview = true
            
        }
        */
    }
    
    func convertLatexFormat(_ text: String) -> String {
        do {
            let pattern = #"\\(\((.*?)\\)|\\\[(.*?)\\\]|\\[(.*?)\\]|\\[\\s*([^\\](.*?)\\s*\\]|\\$(.*?)\\$)"#
            let regex = try NSRegularExpression(pattern: pattern)
            
            var result = text
            let range = NSRange(text.startIndex..., in: text)
            
            regex.enumerateMatches(in: text, range: range) { match, _, _ in
                guard let match = match else { return }
                
                var formula: String?
                for i in 1..<match.numberOfRanges {
                    let range = match.range(at: i)
                    if range.location != NSNotFound, let substringRange = Range(range, in: text) {
                        formula = String(text[substringRange])
                        break
                    }
                }
                
                guard let formula = formula else { return }
                
                let replacement: String
                if formula.contains("\n") {
                    replacement = "$$\(formula)$$"
                } else if match.range(at: 4).location != NSNotFound {
                    replacement = "$\(formula)$"
                } else {
                    replacement = "$$\(formula)$$"
                }
                
                if let matchRange = Range(match.range, in: result) {
                    result.replaceSubrange(matchRange, with: replacement)
                }
            }
            
            return result
        } catch {
            print("正则表达式错误: \(error)")
            return text
        }
    }
    
    /// 从字符串中提取所有被 "+302ai+" 包围的部分
    func extractTexts(from text: String) -> [String] {
        // 1. 用 "+302ai+" 分割字符串
        let components = text.components(separatedBy: "+302ai+")
        // 2. 过滤掉空字符串
        return components.filter { !$0.isEmpty }
    }
    
    
    var messageContextMenu: some View {
        HStack {
            if hoverxyz {
                 
                MessageContextMenu(session: session, conversation: conversation,
                                   toggleTextSelection: { canSelectText.toggle() })
            } else {
                Image(systemName: "ellipsis")
                    .frame(width: 17, height: 17)
            }
        }
        .contextMenuModifier(isHovered: $isHovered)
    }
    
    private var imageSize: CGFloat {
        #if os(macOS)
        300
        #else
        325
        #endif
    }
    
    
    // 更精确的数学表达式检测方法
        func checkForMathExpression(in string: String) -> Bool {
            // 1. 检查完整的数学表达式模式
//            let fullExpressionPattern = #"(?x)(?:^|\s|\(|\[)([-+]?\d*\.?\d+(?:\s*[-+*/%^]\s*[-+]?\d*\.?\d+)+)(?:\s|$|\)|\]|,|;)"#
//            
//            if let _ = string.range(of: fullExpressionPattern, options: .regularExpression) {
//                return true
//            }
            
            // 2. 检查带有变量的数学表达式
//            let variableExpressionPattern = #"(?x)(?:^|\s|\(|\[)([a-zA-Z]+\s*=\s*[-+]?\d*\.?\d+(?:\s*[-+*/%^]\s*[-+]?\d*\.?\d+|\w)+)(?:\s|$|\)|\]|,|;)"#
//            
//            if let _ = string.range(of: variableExpressionPattern, options: .regularExpression) {
//                return true
//            }
            
            // 3. 检查数学函数调用
            let mathFunctionPattern = #"(?x)(?:^|\s|\(|\[)((sin|cos|tan|log|ln|sqrt|exp)\s*\(\s*[-+]?\d*\.?\d+|\w\s*\))(?:\s|$|\)|\]|,|;)"#
            
            if let _ = string.range(of: mathFunctionPattern, options: .regularExpression) {
                return true
            }
            
            // 4. 检查数学常数
            let mathConstantPattern = #"(?x)(?:^|\s|\(|\[)(π|pi|e)(?:\s|$|\)|\]|,|;)"#
            
            if let _ = string.range(of: mathConstantPattern, options: .regularExpression) {
                return true
            }
            
            return false
        }
    
}
  

struct NetworkImageView: View {
    let url: URL
    
    var body: some View {
        GeometryReader { geometry in
            AsyncImage(url: url) { phase in
                Group {
                    if let image = phase.image {
                        image
                            .resizable()
                            //.scaledToFit()
                            .scaledToFill()
                    } else if phase.error != nil {
                        // 错误状态
                        placeholderView
                    } else {
                        // 加载中
                        placeholderView
                    }
                }
                .frame(width: geometry.size.width, height: geometry.size.height)
                .aspectRatio(contentMode: .fill)
            }
        }
    }
    
    private var placeholderView: some View {
        Image("applogo")
            .resizable()
            .scaledToFit()
            .frame(width: 18, height: 18)
            .padding(5)
            .foregroundColor(Color("niceColorLighter"))
            .overlay(
                RoundedRectangle(cornerRadius: 6)
                    .stroke(Color.gray, lineWidth: 0.5)
            )
            .padding(.top, 3)
    }
}



extension String {
    /// 智能分割 Markdown，确保每段尽量接近 `targetChunkSize`，且不破坏语法
    func splitMarkdownSmartly(
        targetChunkSize: Int = 3000,
        maxChunkSize: Int = 4000 // 允许略微超过 target
    ) -> [String] {
        let paragraphs = self.components(separatedBy: "\n\n")
        var chunks: [String] = []
        var currentChunk = ""

        for paragraph in paragraphs {
            let paragraphWithSeparator = paragraph + "\n\n"

            // 情况1：当前段落直接加入后仍小于 maxChunkSize
            if currentChunk.count + paragraphWithSeparator.count <= maxChunkSize {
                currentChunk += paragraphWithSeparator
            }
            // 情况2：当前段落单独超过 maxChunkSize，需要进一步拆分
            else if paragraphWithSeparator.count > maxChunkSize {
                let subChunks = splitLongParagraph(
                    paragraph,
                    maxChunkSize: targetChunkSize
                )
                for subChunk in subChunks {
                    if currentChunk.count + subChunk.count > maxChunkSize, !currentChunk.isEmpty {
                        chunks.append(currentChunk)
                        currentChunk = ""
                    }
                    currentChunk += subChunk + "\n\n"
                }
            }
            // 情况3：当前段落无法加入，先存当前块，再开新块
            else {
                if !currentChunk.isEmpty {
                    chunks.append(currentChunk)
                }
                currentChunk = paragraphWithSeparator
            }
        }

        if !currentChunk.isEmpty {
            chunks.append(currentChunk.trimmingCharacters(in: .whitespacesAndNewlines))
        }

        return chunks
    }

    /// 对超长段落进一步拆分（按句子或安全位置）
    private func splitLongParagraph(
        _ paragraph: String,
        maxChunkSize: Int
    ) -> [String] {
        guard paragraph.count > maxChunkSize else {
            return [paragraph]
        }

        var chunks: [String] = []
        var remainingText = paragraph

        while remainingText.count > maxChunkSize {
            // 查找安全分割点（如最近的换行符、句号、代码块结束等）
            let splitIndex = findSafeSplitIndex(
                text: remainingText,
                maxLength: maxChunkSize
            )

            let chunk = String(remainingText.prefix(splitIndex))
            chunks.append(chunk)
            remainingText = String(remainingText.dropFirst(splitIndex))
        }

        if !remainingText.isEmpty {
            chunks.append(remainingText)
        }

        return chunks
    }

    /// 在 `maxLength` 附近查找安全分割点
    private func findSafeSplitIndex(
        text: String,
        maxLength: Int
    ) -> Int {
        let searchRange = maxLength - 200 ..< min(maxLength + 200, text.count)
        let searchEnd = text.index(text.startIndex, offsetBy: searchRange.upperBound)
        let searchStart = text.index(text.startIndex, offsetBy: searchRange.lowerBound)
        let searchSubstring = text[searchStart..<searchEnd]

        // 优先查找代码块结束 ```
        if let codeBlockEnd = searchSubstring.range(of: "```") {
            return text.distance(from: text.startIndex, to: codeBlockEnd.upperBound)
        }
        // 其次查找段落换行 \n
        else if let lastNewLine = searchSubstring.range(of: "\n", options: .backwards) {
            return text.distance(from: text.startIndex, to: lastNewLine.upperBound)
        }
        // 最后查找句子结束（.?!）
        else if let sentenceEnd = searchSubstring.range(
            of: "[.!?]",
            options: .regularExpression
        ) {
            return text.distance(from: text.startIndex, to: sentenceEnd.upperBound)
        }
        // 实在找不到，按 maxLength 硬分割
        else {
            return maxLength
        }
    }
}
