//
//  UserMessageView2.swift
//  GPTalks
//
//  Created by Adswave on 2025/6/16.
//

import SwiftUI
import SwiftMarkdownView
import AlertToast
import MarkdownUI

extension String {
    /// 检测字符串中是否包含 URL
    var containsURL: Bool {
        guard let detector = try? NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue) else {
            return false
        }
        let matches = detector.matches(in: self, range: NSRange(location: 0, length: self.utf16.count))
        return !matches.isEmpty
    }

    /// 提取字符串中的所有 URL 和对应文本
    func extractURLs() -> [(text: String, url: String)] {
        guard let detector = try? NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue) else {
            return []
        }
        let matches = detector.matches(in: self, range: NSRange(location: 0, length: self.utf16.count))
        return matches.compactMap { match in
            guard let range = Range(match.range, in: self) else { return nil }
            let urlText = String(self[range])
            return (text: urlText, url: urlText)
        }
    }
}

struct SmartText: View {
    let content: String
    var linkColor: Color = .blue
    var underlineLinks: Bool = true

    var body: some View {
        if let attributedText = createAttributedText() {
            CustomText(attributedText)
        } else {
            CustomText(content)
        }
    }

    private func createAttributedText() -> AttributedString? {
        guard content.containsURL else { return nil }
        var attributedString = AttributedString(content)
        let urlTuples = content.extractURLs()

        for tuple in urlTuples {
            if let range = attributedString.range(of: tuple.text) {
                attributedString[range].link = URL(string: tuple.url)
                attributedString[range].foregroundColor = linkColor
                if underlineLinks {
                    attributedString[range].underlineStyle = .single
                }
            }
        }
        return attributedString
    }
}

struct UserMessageView2: View {
    //@Environment(DialogueViewModel.self) private var viewModel   //截长图时会崩溃
    
    @State private var isExpanded = false
    
    var conversation: Conversation
    var session: DialogueSession
    
    @FocusState var focused: Bool

    @State var isEditing: Bool = false
    @State var editingMessage: String = ""
    
    @State private var isHovered = false
    @State var hoverxyz = false
    
    @State var canSelectText = false

    var scrollToMessageTop: () -> Void?
    
    
    @StateObject private var speechSynthesizer = SpeechSynthesizer()
    @State private var buttons  = [
        ButtonData(name: "刷新"),
        ButtonData(name: "删除"),
        //ButtonData(name: "钉住"),
        ButtonData(name: "复制"),
        ButtonData(name: "播放")
    ]
    @State private var showButtons = true //展示一排操作按钮
    @State var isShowToast = false
    @State private var hintText: String?
    
    var showButtonsTop: Int {
        if !conversation.content.isEmpty && !conversation.imagePaths.isEmpty {
                return 5
            } else if !conversation.content.isEmpty && conversation.imagePaths.isEmpty {
                return 0
            } else if conversation.content.isEmpty && !conversation.imagePaths.isEmpty {
                return -35
            } else {
                return 0
            }
        }
    
    var body: some View {
        
        
        ZStack{
            
            alternateUI
                .onHover { isHovered in
                    self.isHovered = isHovered
                }
                .sheet(isPresented: $isEditing) {
                    EditingView(editingMessage: $editingMessage, isEditing: $isEditing, session: session, conversation: conversation)
                }
#if !os(macOS)
                .sheet(isPresented: $canSelectText) {
                    TextSelectionView(content: conversation.content)
                }
//                .contextMenu {
//                    //长按弹窗
//                    MessageContextMenu(session: session, conversation: conversation, isExpanded: isExpanded,
//                                       editHandler: {
//                        session.setupEditing(conversation: conversation)
//                    }, toggleTextSelection: {
//                        canSelectText.toggle()
//                    }, toggleExpanded: {
//                        isExpanded.toggle()
//                    })
//                    .labelStyle(.titleAndIcon)
//                    .frame(maxWidth: .infinity,alignment: .trailing)
//                }
#else
                .toolbar {
                    ToolbarItem(placement: .keyboard) {
                        if (session.conversations.filter { $0.role == .user }.last)?.id == conversation.id {
                            editBtn
                        }
                    }
                }
#endif
        }
        .toast(isPresenting: $isShowToast){
               
            AlertToast(displayMode: .alert, type: .regular, title: hintText)
        }
        
        
        
    }
    
    
    // 判断是否为图片文件
    func isImageFile(_ path: String) -> Bool {
        let imageExtensions = ["jpg", "jpeg", "png", "gif", "bmp", "tiff", "webp"]
        let fileExtension = (path as NSString).pathExtension.lowercased()
        return imageExtensions.contains(fileExtension)
    }
    
    
    var alternateUI: some View {
        VStack(alignment: .trailing) {
            //隐藏头像了
            HStack(alignment: .top, spacing: 0) {
//                Spacer()
//                  
//                //头像
//                Text(AppConfiguration.shared.userAvatar)
//                    .frame(width: 22, height: 20)
//                    .padding(3)
//                    //.hidden()   //隐藏头像了 不要头像
//                    .overlay(
//                        RoundedRectangle(cornerRadius: 6)
//                            .stroke(Color.gray, lineWidth: 0.5)
//                    )
//#if !os(macOS)
//                    .padding(.top, 3)
//                    .offset(x:5)
//#else
////                    .offset(x:5,y:0)
//                    //.padding(.bottom, 3)
//#endif
            }
            .padding(1)
             
            VStack(alignment: .trailing, spacing: 6) {
                     
#if os(macOS)
                Text(isExpanded || conversation.content.count <= 300 ? conversation.content : String(conversation.content.prefix(300)) + "\n...")
                    .textSelection(.enabled)
#else
                
                
                Group {
                    if conversation.imagePaths.count > 0 {
                        ScrollViewReader { proxy in
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(alignment: .center, spacing: 15) {
                                    Spacer(minLength: conversation.imagePaths.count == 1 ? UIScreen.main.bounds.width-100 : UIScreen.main.bounds.width/CGFloat(conversation.imagePaths.count))
                                    
                                    ForEach(Array(conversation.imagePaths.enumerated()), id: \.element) { index, imagePath in
                                        
                                        if isImageFile(imagePath) {
                                            ImageView2(imageUrlPath: imagePath, imageSize: 80)
                                                .frame(width: 60, height: 63, alignment: .bottom)
                                                .clipShape(RoundedRectangle(cornerRadius: 10))
                                                .id(imagePath) // 为每个视图添加唯一的 ID
                                                .contextMenu {  // 每个图片单独的 contextMenu
                                                    
                                                    // 2.复制图按钮
                                                    Button(action: {
                                                        print("复制 tapped")
                                                        isShowToast = false
                                                        hintText = "已复制"
                                                    }) {
                                                        HStack {
                                                            Image("复制2")
                                                                .resizable()
                                                                .frame(width: 20, height: 20)
                                                            Text("复制")
                                                        }
                                                    }
                                                    
                                                    // 1. 分享按钮
                                                    Button(action: {
                                                        print("分享 tapped")
                                                        isShowToast = false
                                                        hintText = "分享,开发中"
                                                    }) {
                                                        HStack {
                                                            Image("分享")
                                                                .resizable()
                                                                .frame(width: 20, height: 20)
                                                            Text("分享")
                                                        }
                                                    }
                                                    
                                                    /*
                                                    // 4. 档案库按钮
                                                    Button(action: {
                                                        print("档案库 tapped")
                                                        isShowToast = false
                                                        hintText = "档案库,开发中"
                                                    }) {
                                                        HStack {
                                                            Image("档案库")
                                                                .resizable()
                                                                .frame(width: 20, height: 20)
                                                            Text("档案库")
                                                        }
                                                    }
                                                    
                                                    // 5. 知识库按钮
                                                    Button(action: {
                                                        print("知识库 tapped")
                                                        isShowToast = false
                                                        hintText = "知识库,开发中"
                                                    }) {
                                                        HStack {
                                                            Image("知识库")
                                                                .resizable()
                                                                .frame(width: 20, height: 20)
                                                            Text("知识库")
                                                        }
                                                    }*/
                                                }
                                        } else {
                                            FileThumbnailView(filePath: imagePath,pdfPath:conversation.pdfPath)
                                                .padding(5)
                                                .id(imagePath) // 为每个视图添加唯一的 ID
                                                /*.contextMenu {
                                                    Button(action: { print("知识库 tapped") }) {
                                                        HStack {
                                                            Image(systemName:"questionmark.folder")
                                                                .resizable()
                                                                .frame(width: 20, height: 20)
                                                            Text("暂无更多操作")
                                                        }
                                                    }
                                                }*/
                                        }
                                    }
                                }
                                .padding(.horizontal, 10)
                            }
                            .onAppear {
                                // 当视图出现时，滚动到第一个项目（最左边）
                                if let firstImagePath = conversation.imagePaths.first {
                                    withAnimation {
                                        proxy.scrollTo(firstImagePath, anchor: .leading)
                                    }
                                }
                            }
                            .onChange(of: conversation.imagePaths) { newValue in
                                // 当图片路径发生变化时，也滚动到最左边
                                if let firstImagePath = newValue.first {
                                    withAnimation {
                                        proxy.scrollTo(firstImagePath, anchor: .leading)
                                    }
                                }
                            }
                        }
                    }
                }
                
                
                Group {
                    
                    let content = conversation.content
                    if content.count > 50 {
                        //MessageMarkdownView(text: conversation.content)
                        Group{
                            if content.count < 200 && containsURL(content) {
                                CustomText(conversation.content)
                                    .foregroundStyle(Color.white)
                                    .textSelection(.enabled)
                                    .padding(12) // 将padding移到前面
                                    .background(
                                        conversation.content.isEmpty ? nil :
                                            RoundedRectangle(cornerRadius: 10)
                                            .fill(Color.init(hex: "#8E47F1"))
                                    )
                                    .hidden(conversation.content.isEmpty)
                                    .contextMenu {  // 每个图片单独的 contextMenu
                                        
                                        // 2.复制图按钮
                                        Button(action: { //print("复制 tapped")
                                            conversation.content.copyToPasteboard()
                                            isShowToast = true
                                            hintText = "已复制"
                                        }) {
                                            HStack {
                                                Image("复制2")
                                                    .resizable()
                                                    .frame(width: 20, height: 20)
                                                Text("复制".localized())
                                            }
                                        }
                                        
                                        // 1. 分享按钮
                                        Button(action: { print("编辑 tapped")
                                            
                                            //session.setupEditing(conversation: conversation)
                                            session.input = conversation.content
                                            session.inputImages = conversation.imagePaths
                                            self.focused = true
                                            
                                            //session.input = conversation.content
                                        }) {
                                            HStack {
                                                Image("编辑")
                                                    .resizable()
                                                    .frame(width: 20, height: 20)
                                                Text("编辑".localized())
                                            }
                                        }
                                        
                                        
                                        // 4. 档案库按钮
                                        Button(action: {
                                            print("重试 tapped")
                                            
                                            Task { @MainActor in
                                                await session.resend(from: conversation)
                                            }
                                            
                                        }) {
                                            HStack {
                                                Image("重试2")
                                                    .resizable()
                                                    .frame(width: 20, height: 20)
                                                Text("重试".localized())
                                            }
                                        }
                                        
                                    }
                            }else{
                                VStack(alignment: .trailing){
                                    VStack(alignment: .trailing){
                                        /*Markdown(conversation.content)
                                            .markdownTextStyle {
                                                FontSize(16)
                                                ForegroundColor(.white)
                                            }
                                            .codeBlockStyle(
                                                theme: .adaptiveTheme(for: .dark, fontSize: 16),
                                                fontSize: 16
                                            )
                                            .markdownCodeSyntaxHighlighter(.splash(theme: .adaptiveTheme(for: .dark, fontSize: 16)))*/
                                        
                                        SwiftMarkdownView(conversation.content)
                                            .codeBlockTheme(.github)
                                            .cornerRadius(10)
                                            .padding(10)
                                            .contentShape(RoundedRectangle(cornerRadius: 10))
                                            .offset(y:-5)
                                            .overlay(
                                                conversation.content.isEmpty ? nil : RoundedRectangle(cornerRadius: 10)
                                                    .stroke(Color.init(hex: "#8E47F1"), lineWidth: 5)
                                            )
                                            
                                            /*.background(
                                                conversation.content.isEmpty ? nil :
                                                    RoundedRectangle(cornerRadius: 10)
                                                    .fill(Color.init(hex: "#8E47F1"))
                                            )*/
                                    }
                                    
                                    CustomText(conversation.arguments)
                                        .foregroundStyle(.gray)
                                        .font(.footnote)
                                    
                                }
                                .offset(y:-10)
                            
                                .contextMenu {  // 每个图片单独的 contextMenu
                                    
                                    // 2.复制图按钮
                                    Button(action: { //print("复制 tapped")
                                        conversation.content.copyToPasteboard()
                                        isShowToast = true
                                        hintText = "已复制"
                                    }) {
                                        HStack {
                                            Image("复制2")
                                                .resizable()
                                                .frame(width: 20, height: 20)
                                            Text("复制".localized())
                                        }
                                    }
                                    
                                    // 1. 分享按钮
                                    Button(action: { print("编辑 tapped")
                                        
                                        //session.setupEditing(conversation: conversation)
                                        session.input = conversation.content
                                        session.inputImages = conversation.imagePaths
                                        self.focused = true
                                        
                                        //session.input = conversation.content
                                    }) {
                                        HStack {
                                            Image("编辑")
                                                .resizable()
                                                .frame(width: 20, height: 20)
                                            Text("编辑".localized())
                                        }
                                    }
                                    
                                    
                                    // 4. 档案库按钮
                                    Button(action: {
                                        print("重试 tapped")
                                        
                                        Task { @MainActor in
                                            await session.resend(from: conversation)
                                        }
                                        
                                    }) {
                                        HStack {
                                            Image("重试2")
                                                .resizable()
                                                .frame(width: 20, height: 20)
                                            Text("重试".localized())
                                        }
                                    }
                                    
                                }
                        }

                                
                        }
                    } else {
                        CustomText(conversation.content)
                            .foregroundStyle(Color.white)
                            .textSelection(.enabled)
                            .padding(12) // 将padding移到前面
                            .background(
                                conversation.content.isEmpty ? nil :
                                    RoundedRectangle(cornerRadius: 10)
                                    .fill(Color.init(hex: "#8E47F1"))
                            )
                            .hidden(conversation.content.isEmpty)
                        
                            .contextMenu {  // 每个图片单独的 contextMenu
                                
                                // 2.复制图按钮
                                Button(action: { //print("复制 tapped")
                                    conversation.content.copyToPasteboard()
                                    isShowToast = true
                                    hintText = "已复制"
                                }) {
                                    HStack {
                                        Image("复制2")
                                            .resizable()
                                            .frame(width: 20, height: 20)
                                        Text("复制".localized())
                                    }
                                }
                                
                                // 1. 分享按钮
                                Button(action: { print("编辑 tapped")
                                    
                                    //session.setupEditing(conversation: conversation)
                                    session.input = conversation.content
                                    session.inputImages = conversation.imagePaths
                                    self.focused = true
                                    
                                    //session.input = conversation.content
                                }) {
                                    HStack {
                                        Image("编辑")
                                            .resizable()
                                            .frame(width: 20, height: 20)
                                        Text("编辑".localized())
                                    }
                                }
                                
                                
                                // 4. 档案库按钮
                                Button(action: {
                                    print("重试 tapped")
                                    
                                    Task { @MainActor in
                                        await session.resend(from: conversation)
                                    }
                                    
                                }) {
                                    HStack {
                                        Image("重试2")
                                            .resizable()
                                            .frame(width: 20, height: 20)
                                        Text("重试".localized())
                                    }
                                }
                                
                            }
                        
                    }
                }
                .padding([.leading,.trailing],15)
                .offset(y:-5)
                 

                 
#endif
//                ForEach(conversation.imagePaths, id: \.self) { imagePath in
//                    ImageView2(imageUrlPath: imagePath, imageSize: imageSize)
//                }
//                .offset(x:-8,y:conversation.content.isEmpty ? -30 : 10)
                 
                
                
                
                
                
                
                
                // VStack2 - 根据状态显示或隐藏
                if showButtons && conversation.arguments.isEmpty {
                    ScrollView(.horizontal, showsIndicators: false) {
//                            HStack(spacing: 0) {
//                                ForEach(buttons.indices, id: \.self) { index in
//                                    Button(action: {
//                                        print("Button \(index) tapped")
//                                        buttonAction(index: index,con: conversation)
//                                    }) {
//                                        ZStack {
//                                            // 按钮背景（46×30，圆角15）
//                                            RoundedRectangle(cornerRadius: 8)
//                                                .frame(width: 32, height: 32)
//                                                .foregroundStyle(.background)
//                                                .overlay(
//                                                    RoundedRectangle(cornerRadius: 8)
//                                                        .stroke(Color.gray.opacity(0.5), lineWidth: 1)
//                                                )
//                                            // 图片（缩小显示，宽高20×20）
//                                            Image(buttons[index].name)
//                                                .resizable()
//                                                .renderingMode(.template)
//                                                .scaledToFit()
//                                                .foregroundColor(buttonBackgroundColor(for: index))
//                                                .frame(width: 30, height: 30)
//                                        }
//                                    }.frame(width: 44, height: 44)
//                                        .contentShape(Rectangle())
//                                }
//                            }
//                            .padding(.leading,UIScreen.main.bounds.width*0.4)//往右偏
                    }
                    .transition(.opacity)
                    .frame(height: 1)  // 调整高度 46
                    .padding(.leading,30)
                    .padding(.trailing,-20)
                    .offset(y:CGFloat(showButtonsTop))
                }
                 
            }
            
            
            
#if os(macOS)
            HStack {
                Spacer()
                
                messageContextMenu
                    .padding(.leading, 200) // Increase padding to enlarge the invisible hover area
                    .contentShape(Rectangle()) // Make the whole padded area hoverable
                    .onHover { isHovered in
                        hoverxyz = isHovered
                    }
                    .animation(.easeInOut(duration: 0.15), value: hoverxyz)
            }
            .padding(.top, -40)
            .padding(.bottom, 3)
            .padding(.horizontal, 18)
#endif
        }

        #if os(macOS)
        .padding(.horizontal, 8)
        #endif
        .frame(maxWidth: .infinity, alignment: .topLeading) // Align content to the top left
//        .background(conversation.content.localizedCaseInsensitiveContains(viewModel.searchText) ? .yellow.opacity(0.1) : .clear)
//        .background(session.conversations.firstIndex(where: { $0.id == conversation.id }) == session.editingIndex ? Color("niceColor").opacity(0.3) : .clear)
//        .animation(.default, value: conversation.content.localizedCaseInsensitiveContains(viewModel.searchText))
        
        
        
        
    }
    
    
    
    func containsURL(_ string: String) -> Bool {
           let detector = try? NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue)
           let matches = detector?.matches(in: string, options: [], range: NSRange(location: 0, length: string.utf16.count))
           
           return matches?.isEmpty == false
       }
    
    var messageContextMenu: some View {
        HStack {
            if hoverxyz {
                MessageContextMenu(session: session, conversation: conversation, isExpanded: isExpanded,
                editHandler: {
                    session.setupEditing(conversation: conversation)
                }, toggleTextSelection: {
                    withAnimation {
                        canSelectText.toggle()
                    }
                }, toggleExpanded: {
                    isExpanded.toggle()
                    withAnimation {
                        scrollToMessageTop()
                    }
                })
            } else {
                Image(systemName: "ellipsis")
                    .frame(width: 17, height: 17)
            }

        }
        .contextMenuModifier(isHovered: $isHovered)
    }
    
    var editBtn: some View {
        Button("") {
            session.setupEditing(conversation: conversation)
        }
        .frame(width: 0, height: 0)
        .hidden()
        .keyboardShortcut("e", modifiers: .command)
        .padding(4)
    }

    private var imageSize: CGFloat {
        #if os(macOS)
        300
        #else
        UIScreen.main.bounds.width/3.5  //325
        #endif
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
    
    
    func buttonAction(index:Int,con:Conversation) {
        
        if index == 0 {
            //重新生成
            Task { @MainActor in
                await session.resend(from: con)
            }
        }
        
        if index == 1 {
            //删除
            session.removeConversation(con)
        }
        
        if index == 2 {
            //钉住
            //session.addToTopConversation(con)
            
        }
        
        if index == 2 {
            //复制
            con.content.copyToPasteboard()
            hintText = "已复制"
            isShowToast.toggle()
            // 3秒
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                isShowToast = false
                hintText = nil
            }
        }
        
        if index == 3 {
            //播放内容
            let buttonName = buttons[index].name
            
            if buttonName == "播放" {
                if speechSynthesizer.isSpeaking {
                    speechSynthesizer.stop() // 停止播放
                } else {
                    speechSynthesizer.speak(con.content){
                        // 播放完成后的回调（可选）
                        print("播放完成")
                    }
                }
            } else {
                print("点击了：\(buttonName)")
            }
        }
    }
    
    
    
    
    
    
}


struct FileThumbnailView: View {
    let filePath: String
    let pdfPath: String?
    @State private var fileSize: Int64 = 0
    //@State private var fileSizeString: String = "0kb"
    @State private var fileName: String = ""
    
    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 0) {
                // 文件图标
                    // 文件图标 - 对 iWork 文件使用特殊处理
                    if isIWorkFile(filePath) {
                        iWorkIconView()
                            .padding(.trailing,5)
                    } else {
                        Image(systemName: getFileIcon())
                            .resizable()
                            .scaledToFit()
                            .frame(width: 36, height: 40)
                            .foregroundColor(getFileIconColor())
                    }
                
                
                VStack(alignment: .leading, spacing: 0) {
                    // 文件名
                    Text(optimizedFileNameSmart())
                        .font(.system(size: 14))
                        .lineLimit(1)
                        .foregroundColor(.primary)
                    
                    // 文件大小
                    Text(formatFileSize(fileSize))
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                }
                .padding(.leading,3)
                
                Spacer()
            }
            .padding(.horizontal,5)
            .padding(.vertical,10)
            .background(Color.gray.opacity(0.1))
            .cornerRadius(10)
        }
        .frame(width: 185,height:80)
        .onAppear {
            loadFileInfo()
        }
    }
    
    // 优化文件名显示：开头4字 + ... + 结尾4字 + 扩展名
        private func optimizedFileName() -> String {
            let fileExtension = (filePath as NSString).pathExtension
            let baseName = (fileName as NSString).deletingPathExtension
            
            // 如果文件名很短，直接显示全名
            if baseName.count <= 12 {
                return fileName
            }
            
            // 获取开头4个字符
            let start = String(baseName.prefix(4))
            
            // 获取结尾4个字符
            let end = String(baseName.suffix(4))
            
            // 组合成优化后的文件名
            return "\(start)…\(end).\(fileExtension)"
        }
        
        // 或者使用更智能的版本，考虑中文字符
        private func optimizedFileNameSmart() -> String {
            let fileExtension = (filePath as NSString).pathExtension
            let baseName = (fileName as NSString).deletingPathExtension
            
            // 如果文件名很短，直接显示全名
            if baseName.count <= 10 {
                return fileName
            }
            
            // 处理中文字符（每个中文字符算1个长度单位）
            var startChars = ""
            var endChars = ""
            var startCount = 0
            var endCount = 0
            
            // 收集开头字符
            for char in baseName {
                if startCount >= 4 { break }
                startChars.append(char)
                startCount += 1
            }
            
            // 收集结尾字符
            for char in baseName.reversed() {
                if endCount >= 4 { break }
                endChars = String(char) + endChars
                endCount += 1
            }
            
            return "\(startChars)…\(endChars).\(fileExtension)"
        }
    
    // 判断是否为 iWork 文件
    private func isIWorkFile(_ path: String) -> Bool {
        let iWorkExtensions = ["pages", "numbers", "key", "keynote"]
        let fileExtension = (path as NSString).pathExtension.lowercased()
        return iWorkExtensions.contains(fileExtension)
    }

    // iWork 文件专用图标视图
    private func iWorkIconView() -> some View {
        let fileExtension = (filePath as NSString).pathExtension.lowercased()
        
        var iconName: String
        var iconColor: Color
        
        switch fileExtension {
        case "pages":
            iconName = "doc.richtext"
            iconColor = .red
        case "numbers":
            iconName = "number.square"
            iconColor = .green
        case "key", "keynote":
            iconName = "play.rectangle.fill"
            iconColor = .orange
        default:
            iconName = "doc"
            iconColor = .blue
        }
        
        return Image(systemName: iconName)
            .resizable()
            .scaledToFit()
            .frame(width: 40, height: 40)
            .foregroundColor(iconColor)
    }
    
    
    
    private func getFileIcon() -> String {
        let fileExtension = (filePath as NSString).pathExtension.lowercased()
        
        switch fileExtension {
        // Apple iWork 文件类型
        case "pages":
            return "doc.richtext"
        case "numbers":
            return "tablecells"
        case "key":
            return "doc.richtext.fill"
        case "keynote":
            return "play.rectangle"
            
        // Microsoft Office 文件类型
        case "pdf":
            return "doc.text"
        case "doc", "docx":
            return "doc.fill"
        case "xls", "xlsx":
            return "tablecells"
        case "ppt", "pptx":
            return "rectangle.portrait"
            
        // 文本文件
        case "txt":
            return "text.alignleft"
        case "rtf":
            return "doc.richtext"
            
        // 压缩文件
        case "zip", "rar", "7z":
            return "archivebox"
            
        // 音频文件
        case "mp3", "wav", "aac", "flac":
            return "music.note"
            
        // 视频文件
        case "mp4", "mov", "avi", "mkv":
            return "play.rectangle"
            
        // 代码文件
        case "swift", "js", "html", "css", "py", "java":
            return "chevron.left.slash.chevron.right"
            
        default:
            return "doc"
        }
    }
    
    private func getFileIconColor() -> Color {
        let fileExtension = (filePath as NSString).pathExtension.lowercased()
        
        switch fileExtension {
        // Apple iWork 文件类型 - 使用官方应用颜色
        case "pages":
            return .red // Pages 的红色
        case "numbers":
            return .green // Numbers 的绿色
        case "key", "keynote":
            return .orange // Keynote 的橙色
            
        // Microsoft Office 文件类型
        case "doc", "docx":
            return .blue
        case "xls", "xlsx":
            return .green
        case "ppt", "pptx":
            return .orange
        case "pdf":
            return .red
            
        // 其他文件类型
        case "zip", "rar", "7z":
            return .gray
        case "mp3", "wav", "aac":
            return .purple
        case "mp4", "mov", "avi":
            return .blue
        case "swift":
            return .orange
            
        default:
            return .blue
        }
    }
    
    private func formatFileSize(_ size: Int64) -> String {
        let formatter = ByteCountFormatter()
        formatter.allowedUnits = [.useKB, .useMB, .useGB]
        formatter.countStyle = .file
        return formatter.string(fromByteCount: size)
    }
    
    private func loadFileInfo() {
        // 从文件路径获取文件名
        fileName = (filePath as NSString).lastPathComponent
        
        // 获取文件大小
        if let attributes = try? FileManager.default.attributesOfItem(atPath: filePath) {
            fileSize = attributes[.size] as? Int64 ?? 0
        }else{
            if let path = pdfPath {
                getFileSize(from: URL(string: path)) { fSize in
                    fileSize = fSize ?? 0
                }
            }
            
        }
        
//        func getLocalFileSize(at url: URL) -> Int64? {
//            do {
//                let attributes = try FileManager.default.attributesOfItem(atPath: url.path)
//                return attributes[.size] as? Int64
//            } catch {
//                print("获取文件大小失败: \(error)")
//                return nil
//            }
//        }
        
        
    }
}


func getFileSize(from url: URL?, completion: @escaping (Int64?) -> Void) {
    
    if url == nil {
        completion(0)
        return
    }
    
    
    var request = URLRequest(url: url!)
    request.httpMethod = "HEAD"  // 只请求头部信息，不下载内容
    
    let task = URLSession.shared.dataTask(with: request) { _, response, _ in
        if let httpResponse = response as? HTTPURLResponse,
           let contentLength = httpResponse.value(forHTTPHeaderField: "Content-Length"),
           let fileSize = Int64(contentLength) {
            completion(fileSize)
        } else {
            completion(nil)
        }
    }
    task.resume()
}



func getFileSizeString(from url: URL, completion: @escaping (String?) -> Void) {
    var request = URLRequest(url: url)
    request.httpMethod = "HEAD"
    
    let task = URLSession.shared.dataTask(with: request) { _, response, _ in
        if let httpResponse = response as? HTTPURLResponse,
           let contentLength = httpResponse.value(forHTTPHeaderField: "Content-Length"),
           let fileSizeBytes = Int64(contentLength) {
            
            // 转换为KB并格式化显示
            let fileSizeKB = Double(fileSizeBytes) / 1024.0
            let formattedSize: String
            
            if fileSizeKB < 1024 {
                // 显示KB，保留2位小数
                formattedSize = String(format: "%.2f KB", fileSizeKB)
            } else {
                // 大于1024KB时显示MB
                let fileSizeMB = fileSizeKB / 1024.0
                formattedSize = String(format: "%.2f MB", fileSizeMB)
            }
            
            completion(formattedSize)
        } else {
            completion(nil)
        }
    }
    task.resume()
}




// 判断是否为图片文件的辅助函数（增加 iWork 文件类型排除）
func isImageFile(_ path: String) -> Bool {
    let imageExtensions = ["jpg", "jpeg", "png", "gif", "bmp", "tiff", "webp", "heic"]
    let fileExtension = (path as NSString).pathExtension.lowercased()
    
    // 排除 iWork 和其他文档类型
    let documentExtensions = ["pages", "numbers", "key", "keynote", "pdf", "doc", "docx", "xls", "xlsx", "ppt", "pptx", "txt", "rtf"]
    
    return imageExtensions.contains(fileExtension) && !documentExtensions.contains(fileExtension)
}
