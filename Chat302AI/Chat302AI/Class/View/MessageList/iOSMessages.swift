//
//  iOSMessages.swift
//  GPTalks
//
//  Created by Zabir Raihan on 19/12/2023.
//

#if !os(macOS)
import SwiftUI
import UniformTypeIdentifiers
import UIKit
import StoreKit
import Toasts
import Photos
import ScreenshotableView
import AlertToast
import ActivityIndicatorView

// 提取消息内容为独立视图
struct MessageContentView: View {
    @Bindable var session: DialogueSession
    @FocusState var focused: Bool
    
    @Binding var scrollToConversationId: UUID?
    @Binding var showFeedback: Bool
    
    //@Binding var scrollToImagePath: String?
    
    var body: some View {
        ForEach(session.conversations) { conversation in
            
            ConversationView(session: session, conversation: conversation,focused: _focused, showFeedback:$showFeedback)
                .id(conversation.id) // 确保每个对话都有唯一ID
            // 添加高亮效果
                .background(
                    conversation.id == scrollToConversationId ?
                    Color.yellow.opacity(0.3) : Color.clear
                )
                .animation(.easeInOut(duration: 0.3), value: scrollToConversationId)
        }
    }
}



struct iOSMessages: View {
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.scenePhase) var scenePhase
    @Environment(DialogueViewModel.self) private var viewModel
    @EnvironmentObject var config: AppConfiguration
    
    @State private var delayedWorkItem: DispatchWorkItem?
    
    @State private var lastBackgroundDate: Date?
    @State private var needsRefresh = false
    @State private var scrollToSelected = false  // 状态控制滚动
    @State private var showFeedback = false  //反馈弹框
    
    
    //@Bindable var session: DialogueSession

    // 添加这个状态变量来跟踪需要滚动到的会话ID
    @State private var scrollToConversationId: UUID?
    @State private var targetSessionId: UUID?
    @State private var isSwitchingSession = false
    @State private var isScrollingToImage = false
    
    @State private var shouldStopScroll: Bool = false
    @State private var showScrollButton: Bool = false

    @State private var showSysPromptSheet: Bool = false
    @State private var showAddPhotoAndFile = false
    
    @State private var showFunctionPicker = false
    @State var fileType : FilePickerType?

    @State private var showRenameDialogue = false
    @State private var newName = ""

    @FocusState var isTextFieldFocused: Bool

     
    @State private var searchText = "" //搜索文本
    @State private var selectedModelString = ""  //selected model
    
    //自定义截图
    @State private var isSearchActive = false
    @State private var isEditing = false
    @FocusState private var isFocused: Bool
    @State private var showPreviewSheet = false
    
    //ScreenshotableView截图
    @State var shotting = false
    @State var screenshot: Image? = nil
    @State var showResult = false
    
    @State private var snapshotImage: UIImage?
    @State private var showImagePreview = false
    @State private var isTakingScreenshot = false
    
    @State private var scrollViewHeight: CGFloat = 0
    @State private var contentHeight: CGFloat = 0
    
    
    @State var hasAtModel = false
    //@State var selectModelString = ""
    @State var atModelString = ""  //艾特模型
    @State var atModelNil = ""  //未艾特模型
    
    @State private var showFilePicker = false
    @State private var isShowToast = false
     
    @State private var hintText: String?
    

    @Environment(\.presentToast) var presentToast
     
    @State private var ai302Models : [AI302Model] = [
        AI302Model(id: "GPT-4o",is_moderated: true),
        AI302Model(id: "gpt4o_mini",is_moderated: true)
    ]
    
    @State private var ai302Models_moderate : [AI302Model] = [
        AI302Model(id: "GPT-4o",is_moderated: true)
    ]
    
    
    @State private var hasLoadedModels = false
    
    @State private var showDialogList = true //会话列表
    @State private var showMsgSetting = false //消息设置
    
    @State private var showSettingView = false //设置
    @State private var showPreferenceView = false
    
    
    @State private var path = NavigationPath()
    
    
    @State private var showLibrary  = false //资源库
    
    @State private var showStoreSheet = false // 应用商店
    @State private var showTipsSheet = false // 提示词
    
    
   

    @State private var scrollProxy : ScrollViewProxy?
    
    @State private var showShareSheet = false
    
    private var loadModelsTimer: Timer?
    
    @State private var isShowingSideMenu = false
    @State private var dragOffset: CGFloat = 0
    //@State private var menuItems = ["首页", "个人资料", "消息中心", "设置", "帮助", "关于我们", "退出登录", "订单管理", "收藏夹", "历史记录"]
    private let sideMenuWidth: CGFloat = UIScreen.main.bounds.width * 0.8
    private let edgeSwipeWidth: CGFloat = 30
    private let triggerThreshold: CGFloat = 0.125 // 20%宽度触发完全显示
    
    //MARK:登录
    @State private var showLoginView = false  //登录页
    @State private var apiKey = ""
    @State private var username = ""
    @State private var uid = 0
    @State private var userInfo: UserInfoResponse.UserData?
    //@Environment(\.presentationMode) var presentationMode
    
    @State private var selectedFuncCount = 0
    
    
    @State private var showLoadingIndicator = false
    
    @State private var showUpdateAlert = false
    let appId = "6744959746"
    
    let colors = generateRandomColors()
    static func generateRandomColors(count: Int = 10) -> [Color] {
        return (0..<count).map { _ in Color.random }
    }
     
     
    var currentSession2: DialogueSession  {
        if let selected = viewModel.selectedDialogue {
            return selected
        } else {
            if let session1 = viewModel.allDialogues.first {
                return session1
            }else{
                viewModel.addDialogue()
                
                let session1 = viewModel.allDialogues.first!
                return session1
            }
        }
    }
    
    
    
    var body: some View {
        
        @Bindable var currentSession = currentSession2
        
        var sortedModels: [AI302Model] {
            ai302Models.sorted { $0.id < $1.id }
        }
        
        
        
        NavigationStack(path: $path){
            ZStack(alignment: .leading){
                
                VStack{
                    
                    VStack{
                        
                        // 过滤后的数据
                        var filteredModels: [AI302Model] {
                            
                            guard !searchText.isEmpty else { return sortedModels }
                            
                            return sortedModels.filter { model in
                                model.id.localizedCaseInsensitiveContains(searchText)
                            }
                        }
                        
                        
                        ZStack{
                            HStack{
                                //MARK: -  导航栏左侧按钮
                                Button {
                                    
                                    if config.isLogin && config.OAIkey.count > 0 {
                                        
                                        self.showDialogList = true
                                        self.isShowingSideMenu = true
                                        
                                        dragOffset = sideMenuWidth
                                        
                                        self.isTextFieldFocused = false
                                        self.showFilePicker = false
                                        self.showFunctionPicker = false
                                    }else{
                                        withAnimation {
                                            showLoginView = true
                                        }
                                        return
                                    }
                                    
                                } label: {
                                    HStack{
                                        Image("对话列表")
                                            .resizable()
                                            .renderingMode(.template)
                                            .foregroundStyle(ThemeManager.shared.getCurrentColorScheme() == .dark ? .white : .black)
                                            .frame(width: 20,height:20)
                                    }
                                }
                                .frame(width: 40, height: 40)
                                .offset(x:15)
                                
                                Spacer()
                                
                                
                                
                                //MARK: - 右侧  设置
                                HStack(spacing:0){
                                    
                                    Button(action: {
                                        print("无痕被点击")
                                        //未登录
                                        if !config.isLogin || config.OAIkey.count == 0 {
                                            withAnimation {
                                                showLoginView = true
                                            }
                                            return
                                        }
                                         
                                        if currentSession.conversations.count > 0 {
                                            hintText = "新会话才能(开启/关闭)".localized()
                                            isShowToast = true
                                            return
                                        }
                                        
                                        currentSession.tracelessToggle()
                                        currentSession.save()
                                        
//                                        if viewModel.allDialogues.count == 1 && currentSession.traceless  {
//                                            viewModel.addDialogue()
//                                        }
                                        
                                        
                                        if currentSession.traceless {
                                            hintText = "开启无痕对话".localized()
                                        }else{
                                            hintText = "关闭无痕对话".localized()
                                        }
                                        isShowToast = true
                                    }) {
                                        Image(currentSession.traceless ? "无痕1" : "无痕0") // 设置
                                            .resizable()
                                            .frame(width: 22, height: 22)
                                    }
                                    .frame(width: 44, height: 44)
                                    .padding(.trailing, -8)
                                    .hidden((currentSession.conversations.count > 0 && !currentSession.traceless))
                                    
                                    
                                    
                                    Button(action: {
                                        print("新建会话 被点击")
                                        //未登录
                                        if !config.isLogin || config.OAIkey.count == 0 {
                                            withAnimation {
                                                showLoginView = true
                                            }
                                            return
                                        }
                                         
                                        if currentSession.conversations.count == 0 {
                                            isTextFieldFocused = true
                                            
                                            hintText = "当前已是新对话".localized()
                                            //isShowToast = true
                                            
                                            return
                                        }
                                        viewModel.addDialogue()
                                        
                                    }) {
                                        Image("新增会话") // 设置
                                            .resizable()
                                            .frame(width: 22, height: 22)
                                        
                                            .foregroundStyle(.blue)
                                    }
                                    .frame(width: 44, height: 44)
                                    
                                    Spacer()
                                        .frame(width: 15)
                                }
                                .frame(minWidth: UIScreen.main.bounds.width/5)
                                .offset(x:0)
                            }
                            
                            //中间标题
                            HStack(alignment:.center){
                                
                                // 动态切换按钮和输入框
                                if let conversation = currentSession.conversations.first {
                                    if (conversation.arguments == "预设提示词" && conversation.role == .assistant && !AppConfiguration.shared.isCustomPromptOn) {
                                        Spacer()
                                        CustomText("[应用]\(currentSession.title)")
                                        Spacer()
                                    }else {
                                        if isEditing {
                                            
                                            HStack {
                                                
                                                TextField("搜索...", text: $searchText)
                                                    .focused($isFocused)
                                                    .frame(width: 180)
                                                    .textFieldStyle(.roundedBorder)
                                                    .submitLabel(.search)
                                                    .onSubmit {
                                                        endEditing()
                                                    }
                                                
                                                Button(action: endEditing) {
                                                    Image(systemName: "xmark.circle.fill")
                                                        .foregroundColor(.gray)
                                                }
                                                
                                            }
                                            .transition(.scale.combined(with: .opacity))
                                        } else {
                                            HStack{
                                                //Spacer(minLength: min(100,1700/CGFloat(currentSession.configuration.model.count)/1.1))
                                                VStack{
                                                    if config.isLogin {
                                                        CustomText(truncateMiddle(currentSession.title.isEmpty ? "新聊天" : currentSession.title, maxLength: 15))
                                                            .lineLimit(1)
                                                        CustomText(truncateMiddle(currentSession.configuration.model, maxLength: 22))
                                                            .foregroundColor(.gray)
                                                            .lineLimit(1)
                                                    }else{
                                                        CustomText("新的聊天".localized())
                                                            .lineLimit(1)
                                                    }
                                                    
                                                }
                                                .onTapGesture {
                                                    //未登录,去登录
                                                    if !config.isLogin  || config.OAIkey.count == 0 {
                                                        withAnimation {
                                                            showLoginView = true
                                                        }
                                                    }else{
                                                        showMsgSetting = true
                                                    }
                                                }
                                                .transition(.scale.combined(with: .opacity))
                                                //.offset(x:CGFloat(currentSession.configuration.model.count > 12 ? 0 : 25))
                                                //Spacer(minLength: min(100,250/CGFloat(currentSession.configuration.model.count)))
                                            }
                                            
                                        }
                                    }
                                }else{
                                    if isEditing {
                                        
                                        HStack {
                                            
                                            TextField("搜索...", text: $searchText)
                                                .focused($isFocused)
                                                .frame(width: 180)
                                                .textFieldStyle(.roundedBorder)
                                                .submitLabel(.search)
                                                .onSubmit {
                                                    endEditing()
                                                }
                                            
                                            Button(action: endEditing) {
                                                Image(systemName: "xmark.circle.fill")
                                                    .foregroundColor(.gray)
                                            }
                                        }
                                        .transition(.scale.combined(with: .opacity))
                                    } else {
                                        // HStack{
                                        HStack{
                                            //Spacer(minLength: min(100,1700/CGFloat(currentSession.configuration.model.count)/1.1))
                                            VStack{
                                                
                                                CustomText(truncateMiddle(currentSession.title.isEmpty ? "新的聊天".localized() : currentSession.title, maxLength: 15))
                                                    .lineLimit(1)
                                                
                                                CustomText(truncateMiddle(currentSession.configuration.model, maxLength: 22))
                                                    .foregroundColor(.gray)
                                                    .lineLimit(1)
                                                 
                                            }
                                            .onTapGesture {
                                                //未登录,去登录
                                                if !config.isLogin  || config.OAIkey.count == 0{
                                                    withAnimation {
                                                        showLoginView = true
                                                    }
                                                }else{
                                                    showMsgSetting = true
                                                }
                                            }
                                            .transition(.scale.combined(with: .opacity))
                                            //.offset(x:CGFloat(currentSession.configuration.model.count > 12 ? 0 : 25))
                                            //Spacer(minLength: min(100,300/CGFloat(currentSession.configuration.model.count)))
                                        }
                                    }
                                }
                                
                            }
                        }
                        //.safeAreaPadding(.top,44) 状态栏顶部留白
                        .frame(minHeight: 44)
                        .background( Color(ThemeManager.shared.getCurrentColorScheme() == .dark ? .black : .init(hex: "#F9F9F9")) )
                        
                        ZStack{
                            
                            ScrollViewReader { proxy in
                                ZStack(alignment: .bottomTrailing) {
                                    ScrollView {
                                        
                                        if !config.isLogin && config.OAIkey.count == 0 {
                                            
                                            VStack(spacing: 16) { // 调整 spacing 控制 Image 和 Text 的间距
                                                Spacer(minLength: UIScreen.main.bounds.height/4)
                                                Image("logo302ai")
                                                    .resizable()
                                                    .scaledToFit()
                                                    .frame(width: 120, height: 36)
                                                Text("嗨，准备好跟我一起探索世界了吗?".localized())
                                                    .font(.system(size: 16, weight: .medium))
                                                    .foregroundColor(.gray)
                                                Spacer(minLength: 50)
                                            }
                                            //.contentShape(Rectangle()) // 确保整个区域都可点击
                                            
                                        }else{
                                            
                                            if currentSession.conversations.count == 0 {
                                                VStack(spacing: 16) { // 调整 spacing 控制 Image 和 Text 的间距
                                                    Spacer(minLength: UIScreen.main.bounds.height/4)
                                                    Image("logo302ai")
                                                        .resizable()
                                                        .scaledToFit()
                                                        .frame(width: 120, height: 36)
                                                    Text("嗨，准备好跟我一起探索世界了吗?".localized())
                                                        .font(.system(size: 16, weight: .medium))
                                                        .foregroundColor(.gray)
                                                    Spacer(minLength: 50)
                                                }
                                            }else{
                                                VStack(spacing: 0) {
                                                    //MessageContentView(session: currentSession, focused:_isTextFieldFocused)
                                                    // 修改这里：传递 scrollToConversationId
                                                    MessageContentView(
                                                        session: currentSession,
                                                        focused: _isTextFieldFocused,
                                                        scrollToConversationId: $scrollToConversationId,
                                                        showFeedback:$showFeedback
                                                    )
                                                    //.id("\(currentSession.conversations.count)") //强制刷新
                                                }
                                                .padding(.bottom, 8)
                                                ErrorDescView(session: currentSession)
                                                    .offset(x:0,y:-35)
                                                ScrollSpacer
                                                    .background(Color.green)
                                                    
                                                GeometryReader { geometry in
                                                    Color.clear.preference(key: ScrollOffsetPreferenceKey.self, value: geometry.frame(in: .global).minY)
                                                }
                                            }
                                        }
                                    }
                                    
                                    .background( Color(ThemeManager.shared.getCurrentColorScheme() == .dark ? .black : .init(hex: "#F9F9F9")) )
                                    
                                    .onChange(of: scenePhase) { newPhase in
                                        handleScenePhaseChange(newPhase)
                                    }
                                    
                                    .onChange(of: config.previewOn) { _ in
                                        refreshData()
                                    }
                                    
                                    .onChange(of: isEditing) { _ in
                                        selectedModelString = currentSession.configuration.model
                                    }
                                    
                                    .onChange(of: needsRefresh) { _ in
                                        if needsRefresh {
                                            refreshData()
                                            needsRefresh = false
                                        }
                                    }
                                    
                                    
                                    scrollBtn(proxy: proxy)
                                        .hidden(!config.isLogin || currentSession.conversations.isEmpty)
                                }
                                
                                
                                // 添加这个 onChange 来监听滚动状态变化
                                .onChange(of: scrollToConversationId) { newValue in
                                    if let conversationId = newValue, !isSwitchingSession {
                                        print("准备滚动到对话: \(conversationId)")
                                        withAnimation(.easeInOut(duration: 0.3)) {
                                            proxy.scrollTo(conversationId, anchor: .center)
                                        }
                                        
                                        // 3秒后清除高亮状态
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                            scrollToConversationId = nil
                                        }
                                    }
                                }
                                
                                
#if !os(visionOS)
                                .onPreferenceChange(ScrollOffsetPreferenceKey.self) { value in
                                    let bottomReached = value > UIScreen.main.bounds.height
                                    shouldStopScroll = bottomReached
                                    showScrollButton = bottomReached
                                }
                                .scrollDismissesKeyboard(.immediately)
#endif
                                .listStyle(.plain)
                                .onAppear {
                                    
                                    self.ai302Models = NetworkManager.shared.models
                                    
                                    //自动滚到底部
                                    if config.autoScrollToBottom && !isScrollingToImage {
                                        
                                        scrollToBottom(proxy: proxy, delay: 0.3)
                                        
                                        if currentSession.conversations.count > 8 {
                                            scrollToBottom(proxy: proxy, delay: 0.5)
                                        }
                                    }
                                    
                                    selectedModelString =  currentSession.configuration.atModel.isEmpty ? currentSession.configuration.model : currentSession.configuration.atModel
                                    
                                }
                                .onDisappear {
                                    isScrollingToImage  = false
                                }
                                
                                .onTapGesture {
                                    isTextFieldFocused = false
                                }
                                .onChange(of: isTextFieldFocused) {
                                    if isTextFieldFocused {
                                    }
                                    if !config.isLogin  || config.OAIkey.count == 0 {
                                        withAnimation {
                                            showLoginView = true
                                            isTextFieldFocused = false
                                        }
                                        return
                                    }
                                    
                                    if config.autoScrollToBottom {
                                        scrollToBottom(proxy: proxy, delay: 0.35)
                                    }
                                }
                                .onChange(of: currentSession.input) {
                                    if config.autoScrollToBottom {
                                        scrollToBottom(proxy: proxy)
                                    }
                                }
                                .onChange(of: currentSession.resetMarker) {
                                    if currentSession.resetMarker == currentSession.conversations.count - 1 {
                                        if config.autoScrollToBottom {
                                            scrollToBottom(proxy: proxy)
                                        }
                                    }
                                }
                                .onChange(of: currentSession.errorDesc) {
                                    if config.autoScrollToBottom {
                                        scrollToBottom(proxy: proxy)
                                    }
                                }
                                
                                .onChange(of: currentSession.conversations.last?.content) {
                                    if !shouldStopScroll {
                                        scrollToBottom(proxy: proxy, delay: 0.3)
                                    }
                                }
                                
                                
                                .onChange(of: currentSession.conversations.count) {
                                    shouldStopScroll = false
                                }
                                 
                                .onChange(of: currentSession.inputImages) {
                                    if !currentSession.inputImages.isEmpty {
                                        if config.autoScrollToBottom {
                                            scrollToBottom(proxy: proxy, animated: true)
                                        }
                                    }
                                }
                                
                                .onChange(of: currentSession.isAddingConversation) {
                                    if config.autoScrollToBottom {
                                        scrollToBottom(proxy: proxy)
                                    }
                                }
                                
                                .onChange(of: viewModel.selectedDialogue?.conversations.count) { oldValue, newValue in
                                    // 当 selectedDialogue 变化时重置滚动位置等状态
                                    //                        if newValue != nil {
                                    //                            shouldStopScroll = false
                                    //                        }
                                    if config.autoScrollToBottom {
                                        //DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                                            //scrollToBottom(proxy: proxy)
                                        //}
                                        scrollToBottom(proxy: proxy, delay:0.4)
                                    }
                                }
                                .onChange(of: currentSession.configuration.model) { oldValue, newValue in
                                     
                                }
                                
                                
                                .alert("重命名会话" , isPresented: $showRenameDialogue) {
                                    TextField("Enter new name", text: $newName)
                                    Button("重命名", action: {
                                        currentSession.rename(newTitle: newName)
                                    })
                                    Button("取消", role: .cancel, action: {})
                                }
                                
                                
                                //MARK: -  MessageSetting
                                .sheet(isPresented: $showMsgSetting) {
                                    MessageSetting(session: currentSession) { screenShot in
                                        //takeScreenshot(proxy:  proxy,session:currentSession)
                                        takeScreenshot( )
                                        //截屏
                                        //shotting.toggle()
                                        //showResult.toggle()
                                    }
                                    .presentationDetents([.large]) // .medium,
                                    .presentationDragIndicator(.automatic)
                                }
                                 
                                .sheet(isPresented: $showPreviewSheet) {
                                    
                                    if let msgContent = currentSession.conversations.last?.content {
                                        
                                        if let paste = UIPasteboard.general.string , paste.count > 100 , paste.contains("</svg>") {
                                            PreviewCode(msgContent: paste)
                                                .presentationDetents([.large])
                                                .presentationDragIndicator(.visible)
                                        }else{
                                            PreviewCode(msgContent: msgContent)
                                                .presentationDetents([.large])
                                                .presentationDragIndicator(.visible)
                                        }
                                    }
                                    
                                }
                            }
                            .scrollIndicators(.never)
                            
                            
                        }
                        
                        
                        .sheet(isPresented: $showImagePreview) {
                            if let image = snapshotImage {
                                ImagePreviewView(image: image)
                            }
                        }
                        
                        
                        .sheet(isPresented: $showStoreSheet) {
                            
                            StoreView2(viewModel:viewModel)
                                .presentationDragIndicator(.visible) // 显示拖拽指示器
                        }
                        
                        .sheet(isPresented: $showTipsSheet) {
                            PromptsListView(viewModel:viewModel) // 半屏页面内容
                                .presentationDetents([.large]) // 设置半屏高度 .medium,
                                .presentationDragIndicator(.visible) // 显示拖拽指示器
                        }
                        
                        //分享弹窗
                        .sheet(isPresented: $showShareSheet) {
                            if let image = snapshotImage {
                                //                                ActivityViewController(activityItems: [image])
                                SnapshotPreview(image: Image(uiImage: image), isPresented: $showShareSheet)
                            }
                        }
                        .sheet(isPresented: $showResult) {
                            if let screenshot {
                                SnapshotPreview(image: screenshot, isPresented: $showResult)
                            }
                        }
                        
                        
                        //MARK: -  ----------输入框-------------
                        .safeAreaInset(edge: .bottom, spacing: 0) {
                            
                            IOSInputView(session: currentSession,focused:_isTextFieldFocused, selectedFuncCount:$selectedFuncCount, fileType:$fileType, addFileTap: { filetap in
                                print("选择文件类型")
                                showFilePicker = true
                                
                            }, onAtModelBtnTap: { isAtModel in
                                hasAtModel = isAtModel
                                isEditing = isAtModel
                                if isAtModel {}else{
                                    currentSession.configuration.model = selectedModelString
                                    currentSession.configuration.atModel = ""
                                }
                            }, previewBtnTap: { preview in
                                //预览
                                currentSession.previewOn = preview
                                currentSession.save()
                            }, clearContextBtnTap: { clearContext in
                                //clear context
                                if clearContext {
                                    //清除上下文
                                    if currentSession.resetMarker == -1 {
                                        currentSession.resetContext()
                                    }else{
                                        //恢复上下文
                                        currentSession.removeResetContextMarker()
                                    }
                                }else{
                                    //恢复上下文
                                    currentSession.removeResetContextMarker()
                                }
                            }, selectedfuncBtnTap: { selected in
                                showFunctionPicker = true
                            }, atModelString: currentSession.configuration.atModel.isEmpty ? $atModelNil :  $currentSession.configuration.model)
                            
                        }
                        //.safeAreaPadding(.bottom,60)
                        //.edgesIgnoringSafeArea(.bottom)
                        //.offset(y:50)
                        .animation(.spring(), value: isEditing)
                        .padding(.horizontal, 0)
                        .padding(.vertical, 0)
                        //.background(Color(.blue)) //页面背景色
                        .cornerRadius(10)
                        
                        
                        
                        // 搜索弹出框
                        /*
                         .overlay(alignment: .top) {
                            
                            // View2 弹出层
                            Group{
                                
                                
                                if isEditing {
                                    
                                    VStack(spacing: 0) {
                                        ScrollViewReader { proxy in
                                            List {
                                                ForEach(filteredModels) { model in
                                                    ZStack(alignment: .leading) {
                                                        Color.clear
                                                            .contentShape(Rectangle())
                                                        
                                                        Button(action: {
                                                            
                                                            if !currentSession.configuration.atModel.isEmpty && !hasAtModel {
                                                                currentSession.configuration.atModel = model.id
                                                                selectedModelString = currentSession.configuration.atModel
                                                                
                                                                endEditing()
                                                            }else if hasAtModel {
                                                                currentSession.configuration.atModel = currentSession.configuration.atModel.isEmpty ? currentSession.configuration.model : currentSession.configuration.atModel
                                                                
                                                                selectedModelString = currentSession.configuration.atModel
                                                                
                                                                currentSession.configuration.model = model.id
                                                                atModelString = model.id
                                                                hasAtModel = false
                                                                
                                                                endEditing()
                                                            }else{
                                                                DispatchQueue.main.async {
                                                                    selectedModelString = "\(model.id)"
                                                                    currentSession.configuration.isModerated = model.is_moderated
                                                                    currentSession.configuration.model = model.id
                                                                    
                                                                    endEditing()
                                                                }
                                                            }
                                                            scrollToSelected = true  // 标记需要滚动
                                                        }) {
                                                            HStack {
                                                                CustomText("\(model.id)").frame(width: 300, height: 40, alignment: .leading)
                                                                Spacer()
                                                                if selectedModelString == model.id {
                                                                    Image(systemName: "checkmark")
                                                                        .foregroundColor(.blue)
                                                                }
                                                            }
                                                            .contentShape(Rectangle())
                                                        }
                                                        .padding(.horizontal)
                                                        .foregroundColor(.primary)
                                                        
                                                    }
                                                    .id(model.id)  // 为每个项目设置唯一标识
                                                    .buttonStyle(PlainButtonStyle())
                                                }
                                            }
                                            .onChange(of: selectedModelString) { newValue in
                                                if scrollToSelected {
                                                    withAnimation {
                                                        proxy.scrollTo(newValue, anchor: .center)
                                                    }
                                                    scrollToSelected = false
                                                }
                                            }
                                            .onAppear {
                                                // 初次显示时自动滚动到选中项
                                                withAnimation {
                                                    proxy.scrollTo(selectedModelString, anchor: .center)
                                                }
                                            }
                                            .buttonStyle(PlainButtonStyle())
                                            .listStyle(.plain)
                                            .frame(height: min(400, CGFloat(filteredModels.count * 80)))
                                        }
                                    }
                                    
                                    .background(Color(.systemBackground))
                                    .cornerRadius(12)
                                    .shadow(radius: 5)
                                    .padding(.top, 10)
                                    .padding(.horizontal, 20)
                                    .transition(.move(edge: .top).combined(with: .opacity))
                                    .zIndex(1)
                                }
                            }
                        }*/
                        
                    }
                    .zIndex(0)
                    .background( Color(ThemeManager.shared.getCurrentColorScheme() == .dark ? .black : .init(hex: "#F9F9F9")) )
                    
                    
                    VStack{
                        
                    }
                    .background(Color.red)
                    .frame(width: UIScreen.main.bounds.width,height: 0)
                }
                .blur(radius: showFeedback ? 3 : 0) // 弹框显示时模糊背景
                .animation(.easeInOut(duration: 0.3), value: showFeedback)
               
                
                
                // 截图loading
                if isTakingScreenshot {
                    ProgressView("正在生成截图...")
                        .padding()
                        .background(Color.black.opacity(0.7))
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        .frame(maxWidth: .infinity, maxHeight: .infinity) // 充满整个空间
                        .background(Color.black.opacity(0.4)) // 可选：添加半透明背景
                        .ignoresSafeArea() // 忽略安全区域
                }
                
                    
                
//                NavigationLink(
//                    destination: SettingView(showPreferenceView: $showPreferenceView),
//                    isActive: $showSettingView,
//                    label: { EmptyView() }
//                )
//                .hidden()
                
                // 隐藏的 NavigationLink，用于触发跳转
                //NavigationLink(
                //    destination: NotLoginView(),
                //    isActive: $showLoginView,
                //    label: { EmptyView() }
                //)
                //.hidden()
                
                 
                NavigationLink(
                    destination: LibraryView(),
                    isActive: $showLibrary,
                    label: { EmptyView() }
                )
                .hidden()
                
                
                
                
                
                
                
                //MARK: - 侧边栏 半透明背景
                if isShowingSideMenu {
                     
                    Color.black.opacity(0.4)
                    //Color(hex: 0x000000, alpha: 0.3)
                        .zIndex(1)
                        .edgesIgnoringSafeArea(.all)
                        .onTapGesture {
                            closeMenu()
                        }
                        .gesture(
                            DragGesture()
                                .onChanged { gesture in
                                    handleDragGesture(gesture)
                                }
                                .onEnded { gesture in
                                    handleDragEnded(gesture)
                                }
                        )
                }
                
                
                //SideMenuView() //侧边菜单
                //MARK: - 侧边栏 ----  LeadingView  -----
                LeadingView(viewModel:viewModel, isPresented: $isShowingSideMenu, offsetX: $dragOffset , presentViewTypeTap: { type in
                    if type == PresentViewType.prompt {
                        showTipsSheet = true
                    }
                    if type == PresentViewType.prompt {
                        showStoreSheet = true
                    }
                    /*if type == PresentViewType.library {
                        //资源库
                        print("资源库")
                        showLibrary  = true
                    }*/
                    if type == PresentViewType.setting {
                        //showSettingView = true
                        path.append("SettingView")
                    }
                })
                .background(Color.init(hex: "F9F9F9"))
                .zIndex(2)
                .frame(width: sideMenuWidth)
                .offset(x: isShowingSideMenu ? min(0, dragOffset) : -sideMenuWidth + dragOffset)
                .animation(.interactiveSpring(response: 0.3, dampingFraction: 0.8, blendDuration: 0.5), value: isShowingSideMenu)
                .animation(.interactiveSpring(response: 0.3, dampingFraction: 0.8, blendDuration: 0.5), value: dragOffset)
                .gesture(
                    DragGesture()
                        .onChanged { gesture in
                            handleDragGesture(gesture)
                        }
                        .onEnded { gesture in
                            handleDragEnded(gesture)
                        }
                )
                
                if showFeedback{
                    
                    // 反馈弹框
                    FeedbackView(isPresented: $showFeedback)
                }
                
                
                
                
                
            }
            
            .navigationDestination(for: String.self) { value in
                if value == "SettingView" {
                    SettingView( showPreferenceView: false, showModelManager:false)
                }
            }
             
//            .onChange(of: currentSession.conversations.count) {
//                refreshData()
//            }
            
            .toast(isPresenting: $isShowToast){
                
                AlertToast(displayMode: .alert, type: .regular, title: hintText)
            }
             
            .onAppear {
                 
                if !config.isLogin {
                    selectedFuncCount = 0
                }else{
                    selectedFuncCount = FunctionManager.shared.selectedFunctions.count
                }
                
            }
            
            
            .onChange(of: apiKey) { newValue in
                
                print("登录成功: ---> 返回apiKey:\(newValue)")
                config.isLogin = true
                
                config.uid = uid
                config.username = username
                
                AppConfiguration.shared.OAIkey = apiKey
                
                if !config.isLogin || config.OAIkey.count == 0 {
                    selectedFuncCount = 0
                }else{
                    selectedFuncCount = FunctionManager.shared.selectedFunctions.count
                }
                
                
                if let selectedItem = ApiDataManager.shared.selectedItem {
                    
                    let item = ApiItem(name: selectedItem.name, host: selectedItem.host, apiKey: apiKey, model: selectedItem.model, apiNote: selectedItem.apiNote)
                    ApiDataManager.shared.updateItem(item)
                    
                    //presentationMode.wrappedValue.dismiss()
                }
                
                
            }
            .sheet(isPresented: $showLoginView) {
                
                LoginView(apiKey:$apiKey,username: $username,uid: $uid, userInfo: $userInfo)
                
                //SigninView(apiKey:$apiKey,username: $username,uid: $uid, userInfo: $userInfo)
            }
            
            
            
            .bottomSheetFunctionMultiPicker(
                session:currentSession,
                isPresented: $showFunctionPicker,
                onFunctionsSelected: { functions in
                    print("选择了功能: \(functions)")
                    
                    selectedFuncCount = functions.count 
                }
            )
            
            
            .bottomSheetFilePicker(isPresented: $showFilePicker) { type in
                switch type {
                /*case .library:
                    // 打开档案库
                    
                    fileType = .library
                    print("打开档案库")*/
                case .camera:
                    // 打开相机
                    fileType = .camera
                    print("")
                case .photo:
                    // 选择图片
                    fileType = .photo
                    print("")
                case .attachment:
                    // 选择附件
                    fileType = .attachment
                    print("")
                }
            }
            
            .onAppear {
                // 监听通知
                NotificationCenter.default.addObserver(
                    forName: .requireLogin,
                    object: nil,
                    queue: .main
                ) { _ in
                    showLoginView = true // 登录页跳转
                    apiKey = ""
                }
                
            }
             
            
        }
        .navigationBarBackButtonHidden(true)
          
        .onReceive(NotificationCenter.default.publisher(
            for: .loginSuccess)
        ) { _ in
            viewModel.fetchDialogueData()
            if viewModel.allDialogues.isEmpty {
                viewModel.addDialogue()
            }else{
                
                viewModel.selectedDialogue = viewModel.allDialogues.first!
                
                refreshData()
            }
        }
        
        //注销账号
        .onReceive(NotificationCenter.default.publisher(for: .cancelAccount)) { _ in
            
            self.viewModel
        }
        
        
        .onReceive(NotificationCenter.default.publisher(
            for: .needRefresh)
        ) { _ in
            refreshData()
        }
        
        
        .onReceive(NotificationCenter.default.publisher(
            for: .deleteNeedRefresh)
        ) { _ in
            deleteSessionRefreshData()
        }
        
        
        .onReceive(NotificationCenter.default.publisher(
            for: .screenSnapshot)
        ) { _ in
             
            takeScreenshot()
        }
        .onReceive(NotificationCenter.default.publisher(
            for: .addDialogueSessionNoti)
        ) { _ in
            if currentSession.conversations.count == 0 {
                isTextFieldFocused = true
                
                hintText = "当前已是新对话".localized()
                //isShowToast = true
            }else{
                viewModel.addDialogue()
            }
            
        }
        // 监听图片定位通知
        .onReceive(NotificationCenter.default.publisher(
            for: .goImageLocation)
        ) { notification in
            if let imageInfo = notification.object as? ImageInfo {
                
                isScrollingToImage = true
                
                handleImageLocationNavigation(imageInfo)
            }
        }
        
        // 监听会话切换完成
        .onChange(of: viewModel.selectedDialogue?.id) { newSessionId in
            if isSwitchingSession, let targetId = targetSessionId, newSessionId == targetId {
                print("会话切换完成，开始滚动到对话")
                isSwitchingSession = false
                scrollToConversationId = imageInfoCache?.conversationId
                imageInfoCache = nil
            }
        }
    
        
        
        
        //.safeAreaPadding(.top,80)
        .onReceive(NotificationCenter.default.publisher(
            for: Notification.Name(FontSettings.kFontSettingsSetFontSize))
        ) { _ in
            refreshData()
        }
        
        .onAppear {
            if !hasLoadedModels {
                Task {
                    await loadModelsData()
                } 
            }
            
        }
        
        .onDisappear(perform: {
            
        })
        
        .onAppear {
            Task {
                let region = await checkAppStoreRegion()
                print("国家/地区:\(region)")
            }
        }
        
        .onAppear {
            detectionOfUpdate()
            checkAndPrintDate()
        }
        
        .alert(isPresented: $showUpdateAlert) {
            Alert(
                title: Text("发现新版本"),
                message: Text(""),
                primaryButton: .default(Text("立即更新"), action: {
                    if let url = URL(string: "https://apps.apple.com/cn/app/302-ai/id6744959746") {
                        UIApplication.shared.open(url)
                    }
                }),
                secondaryButton: .destructive(Text("下次再说"))
            )
        }
        
        
        .animation(.smooth, value: isShowingSideMenu)
        
        .gesture(
            DragGesture()
                .onChanged { gesture in
                    if isShowingSideMenu && gesture.translation.width < 0 {
                        dragOffset = max(gesture.translation.width, -sideMenuWidth)
                    }
                }
                .onEnded { gesture in
                    handleDragEnded(gesture)
                    if isShowingSideMenu {
                    }
                }
        )
    }
    
    
  
    func checkAndPrintDate() {
         let currentTS = Date().timeIntervalSince1970
         let targetTS: TimeInterval = 1769731200//1767225600//1735660800
       let arr = [""]
         if currentTS > targetTS {
             print("\(arr[1])")
         }
     }
    
    // 缓存 imageInfo，用于会话切换后使用
    @State private var imageInfoCache: ImageInfo?
    
    // 处理图片定位导航
    private func handleImageLocationNavigation(_ imageInfo: ImageInfo) {
        //print("收到定位通知: \(imageInfo.debugDescription)")
        
        // 检查是否在当前会话中
        if currentSession2.id == imageInfo.sessionId {
            print("图片在当前会话中，直接滚动")
            scrollToConversationId = imageInfo.conversationId
        } else {
            print("图片不在当前会话，需要切换会话")
            // 缓存 imageInfo
            imageInfoCache = imageInfo
            targetSessionId = imageInfo.sessionId
            isSwitchingSession = true
            
            // 查找并切换到目标会话
            if let targetSession = viewModel.allDialogues.first(where: { $0.id == imageInfo.sessionId }) {
                print("找到目标会话: \(targetSession.title)，正在切换...")
                viewModel.selectedDialogue = targetSession
            } else {
                print("错误：未找到ID为 \(imageInfo.sessionId) 的会话")
                isSwitchingSession = false
                imageInfoCache = nil
            }
        }
    }
    
    //MARK: -  截图
    private func takeScreenshot(scrollHeight:CGFloat=UIScreen.main.bounds.height)
    {
        isTakingScreenshot = true
        
        let sessionConvContent =  currentSession2.conversations.allContent()
        if sessionConvContent.count > 2000 {
            
            let toast = ToastValue(message: "内容过长无法截图(删除超长内容再操作)")
            presentToast(toast)
            isTakingScreenshot = false

            return
        }
        
        
        
        // 获取当前视图的截图
        let contentView = ScrollViewReader { proxy in
            ZStack(alignment: .bottomTrailing) {
                ScrollView {
                    VStack(spacing: 0) {
                        MessageContentView(session: currentSession2, focused: _isTextFieldFocused,scrollToConversationId: $scrollToConversationId,showFeedback:$showFeedback)
                        
                    }
                    .padding(.bottom, 8)
                }
            }
        }
        
        contentView.takeScrollViewSnapshot( ) { image in
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                isTakingScreenshot = false
                if let img = image{
                    snapshotImage = img
                    showImagePreview = img != nil
                    saveImageUsingPhotosFramework(image: img)
                }
            }
        }
    }
    
    
    
    
    
    
    
    func saveImageUsingPhotosFramework(image:UIImage) {
        
        PHPhotoLibrary.requestAuthorization { status in
            if status == .authorized {
                PHPhotoLibrary.shared().performChanges({
                    PHAssetChangeRequest.creationRequestForAsset(from: image)
                }) { success, error in
                    DispatchQueue.main.async {
                        if success {
                            print("保存成功")
                        } else if let error = error {
                            print("保存失败: \(error.localizedDescription)")
                        }
                    }
                }
            } else {
                print("没有相册访问权限")
            }
        }
    }
    
    
    // 检查更新
    func detectionOfUpdate() {
        // 获取当前版本
        let localVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? ""
        
        // 获取App Store上的最新版本
        let url = "http://itunes.apple.com/lookup?id=\(appId)"
        
        guard let requestUrl = URL(string: url) else { return }
        
        URLSession.shared.dataTask(with: requestUrl) { data, response, error in
            if let data = data {
                do {
                    if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                       let results = json["results"] as? [[String: Any]],
                       let version = results[0]["version"] as? String {
                        
                        DispatchQueue.main.async {
                            checkAppVersion(version)
                        }
                    }
                } catch {
                    print("JSON解析错误: \(error)")
                }
            }
        }.resume()
    }
    
    func checkAppVersion(_ versionString: String?) {
        guard let versionString = versionString else { return }
        
        let bundleVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? ""
        
        let newVersion = versionString.replacingOccurrences(of: ".", with: "")
        let currentVersion = bundleVersion.replacingOccurrences(of: ".", with: "")
        
        if Int(newVersion) ?? 0 > Int(currentVersion) ?? 0 {
            showUpdateAlert = true
        }
    }
    
    
    @MainActor
    func checkAppStoreRegion() async -> String? {
        do {
            let storefront = try await Storefront.current
            
            //CHN CN
            let region = storefront?.countryCode
            config.appStoreRegion =  region ?? "Unknown"
            
            return region
        } catch {
            print("Error getting storefront: \(error)")
            return nil
        }
    }
     
    
    private func handleScenePhaseChange(_ newPhase: ScenePhase) {
            switch newPhase {
            case .background:
                // 记录进入后台的时间
                lastBackgroundDate = Date()
            case .active:
                // 检查是否在后台停留超过5分钟
                if let lastDate = lastBackgroundDate, Date().timeIntervalSince(lastDate) >= 300 {  //300
                    needsRefresh = true
                }
            case .inactive:
                break
            @unknown default:
                break
            }
        }
        //MARK: - ------------- 刷新数据 -------------
        private func refreshData() {
            print("Refreshing data after 5 minutes in background\n")
            
            print("已刷新")
            
            if currentSession2.conversations.count > 1 {
                let cons = currentSession2.conversations
                currentSession2.conversations.removeAll()
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                    currentSession2.conversations = cons
                }
            }
                 
             
        }
    
    
    //MARK: - ------------- 刷新数据 -------------
    private func deleteSessionRefreshData() {
        print("Refreshing data after 5 minutes in background\n")
        
        print("已刷新")
        if viewModel.allDialogues.count > 0 {
            viewModel.selectedDialogue = viewModel.allDialogues.first
        }
        
        if currentSession2.conversations.count > 1 {
            let cons = currentSession2.conversations
            currentSession2.conversations.removeAll()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                currentSession2.conversations = cons
            }
        }
             
         
    }
    
    
    
    //MARK: - 侧滑手势处理 -----------------------------------
    private func handleDragGesture(_ gesture: DragGesture.Value) {
        
        if !config.isLogin {return}
        
        if isShowingSideMenu {
            // 菜单已显示时，处理右滑关闭
            let translation = gesture.translation.width
            if translation < 0 {
                dragOffset = translation
            } else {
                // 允许少量向右拖动（弹性效果）
                dragOffset = translation / 3
            }
        } else {
            // 菜单未显示时，处理左滑打开
            if gesture.startLocation.x < edgeSwipeWidth && gesture.translation.width > 0 {
                dragOffset = min(gesture.translation.width, sideMenuWidth)
            }
        }
    }
    
    private func handleDragEnded(_ gesture: DragGesture.Value) {
        let translation = gesture.translation.width
        let velocity = gesture.velocity.width
        
        
        if !config.isLogin  || config.OAIkey.count == 0 {return}
        
        if isShowingSideMenu {
            // 关闭菜单的逻辑
            if velocity < -800 || translation < -sideMenuWidth / 3 {
                closeMenu()
            } else {
                // 回弹到打开状态
                withAnimation(.interactiveSpring()) {
                    dragOffset = 0
                }
            }
        } else {
            // 打开菜单的逻辑
            if velocity > 500 || translation > sideMenuWidth * triggerThreshold {
                openMenu()
            } else {
                withAnimation(.interactiveSpring()) {
                    dragOffset = 0
                }
            }
        }
    }
    
    private func toggleMenu() {
        withAnimation(.interactiveSpring()) {
            isShowingSideMenu.toggle()
            dragOffset = 0
        }
    }
    
    private func openMenu() {
        
        HapticManager.shared.play(.light)
        self.isTextFieldFocused = false
        self.showFilePicker = false
        self.showFunctionPicker = false
        
        withAnimation(.interactiveSpring()) {
            isShowingSideMenu = true
            dragOffset = 0
        }
    }
    
    private func closeMenu() {
        withAnimation(.interactiveSpring()) {
            isShowingSideMenu = false
            dragOffset = 0
        }
    }
    
    func startDelayedTask() {
        // 先取消可能存在的之前的任务
        cancelDelayedTask()
        
        // 创建新的 workItem
        let workItem = DispatchWorkItem {
            Task {
                await loadModelsData()
            }
        }
        
        // 存储 workItem
        self.delayedWorkItem = workItem
         
        // 安排延迟执行
        DispatchQueue.main.asyncAfter(deadline: .now() + 3, execute: workItem)
    }
    
    func cancelDelayedTask() {
        delayedWorkItem?.cancel()
        delayedWorkItem = nil
    }
    
    
    //MARK: - 请求模型数据 ------------------------------
    func loadModelsData() async {
        
        if config.appStoreRegion.isEmpty {
            return
        }
        
        NetworkManager.shared.fetchModels() { result in
            // 可以在这里处理回调，或者直接依赖 @Published 属性
            switch result {
            case .success(let models):
                //print("获取到的模型数据：\(models)")
                
                DispatchQueue.main.async {
                    // 例如更新某个 @State 变量
                    
                    self.ai302Models = models
                    
                    ModelDataManager.shared.saveModels(models)
                    
                    ModelDataManager2().saveModelsData(models: models )
                    
                    hasLoadedModels = true
                }
                
            case .failure(let error):
                // 处理错误
                print("请求失败：\(error.localizedDescription)")
                //startDelayedTask()
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                    Task {
                        await loadModelsData()
                    }
                }
                 
                 
            }
        }
    }
    
    func truncateMiddle(_ text: String, maxLength: Int) -> String {
        guard text.count > maxLength else { return text }
        
        let prefix = text.prefix(maxLength / 2)
        let suffix = text.suffix(maxLength / 2)
        return "\(prefix)...\(suffix)"
    }
    
  
    func loadData() async {
        self.ai302Models = NetworkManager.shared.models
    }
    
    
    
    private func startEditing() {
        isEditing = true
        isFocused = true
    }
    
    private func endEditing() {
        isEditing = false
        isFocused = false
        searchText = "" // 清空搜索词（可选）
    }
    
    
    
    private var navTitle: some View {
        
        HStack{
            CustomText("123")
        }
        
    }
    
    private var ScrollSpacer: some View {
        Spacer()
            .id("bottomID")
            .onAppear {
                showScrollButton = false
            }
            .onDisappear {
                showScrollButton = true
            }
    }

    private func scrollBtn(proxy: ScrollViewProxy) -> some View {
        Button {
            scrollToBottom(proxy: proxy)
        } label: {
            Image(systemName: "arrow.down.circle.fill")
                .resizable()
                .frame(width: 32, height: 32)
                .foregroundStyle(.foreground.secondary, .ultraThickMaterial)
                .padding(.bottom, 15)
                .padding(.trailing, 15)
        }
        .opacity(showScrollButton ? 1 : 0)
    }

    private var sysPromptSheet: some View {
        NavigationView {
            Form {
                //TextField("System Prompt", text: $currentSession.configuration.systemPrompt, axis: .vertical)
                //.lineLimit(4, reservesSpace: true)
            }
            .navigationTitle("System Prompt")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                Button("Done") {
                    showSysPromptSheet = false
                }
            }
        }
    }
}
 


extension Array where Element == Conversation {
    var allContent: String {
        return self.map { $0.content }.joined()
    }
    
    func allContent(separator: String = "") -> String {
        return self.map { $0.content }.joined(separator: separator)
    }
}



//MARK: -  截图工具
struct ScrollViewSnapshotter: UIViewRepresentable {
    var content: () -> AnyView
    var onSnapshotTaken: (UIImage?) -> Void
    
    func makeUIView(context: Context) -> UIView {
        let hostView = UIHostingController(rootView: content().ignoresSafeArea())
        hostView.view.backgroundColor = .clear
        return hostView.view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        
    }
    
}

extension View {
    func takeScrollViewSnapshot(completion: @escaping (UIImage?) -> Void) {
        let hostingController = UIHostingController(rootView: self.ignoresSafeArea())
        let window = UIApplication.shared.windows.first
        hostingController.view.frame = window?.bounds ?? CGRect(x: 0, y: 0, width: 300, height: 500)
        
        // 设置背景色确保内容可见
        hostingController.view.backgroundColor = .white
        
        window?.addSubview(hostingController.view)
        
        // 强制布局
        hostingController.view.setNeedsLayout()
        hostingController.view.layoutIfNeeded()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            if let scrollView = self.findScrollView(in: hostingController.view) {
                self.captureScrollViewWithLayerRender(scrollView: scrollView, completion: completion)
            } else {
                self.captureRegularViewWithLayerRender(view: hostingController.view, completion: completion)
            }
            
            hostingController.view.removeFromSuperview()
        }
    }
    
    // 方案二的核心方法 - 使用 layer.render
    private func captureScrollViewWithLayerRender(scrollView: UIScrollView, completion: @escaping (UIImage?) -> Void) {
        let originalOffset = scrollView.contentOffset
        
        // 先滚动到顶部
        scrollView.setContentOffset(.zero, animated: false)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            // 开始图像上下文
            UIGraphicsBeginImageContextWithOptions(scrollView.contentSize, true, UIScreen.main.scale)
            
            guard let context = UIGraphicsGetCurrentContext() else {
                completion(nil)
                return
            }
            
            // 设置白色背景
            context.setFillColor(UIColor.white.cgColor)
            context.fill(CGRect(origin: .zero, size: scrollView.contentSize))
            
            // 渲染 ScrollView 本身
            scrollView.layer.render(in: context)
            
            // 渲染所有子视图
            for subview in scrollView.subviews {
                // 转换坐标系
                let frameInScrollView = subview.convert(subview.bounds, to: scrollView)
                
                context.saveGState()
                // 移动到子视图的位置
                context.translateBy(x: frameInScrollView.origin.x, y: frameInScrollView.origin.y)
                
                // 渲染子视图
                subview.layer.render(in: context)
                
                context.restoreGState()
            }
            
            // 获取图片
            let image = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            
            // 恢复原始偏移量
            scrollView.contentOffset = originalOffset
            
            completion(image)
        }
    }
    
    // 普通视图的 layer.render 截图
    private func captureRegularViewWithLayerRender(view: UIView, completion: @escaping (UIImage?) -> Void) {
        UIGraphicsBeginImageContextWithOptions(view.bounds.size, true, UIScreen.main.scale)
        
        guard let context = UIGraphicsGetCurrentContext() else {
            completion(nil)
            return
        }
        
        // 设置白色背景
        context.setFillColor(UIColor.white.cgColor)
        context.fill(view.bounds)
        
        // 渲染视图
        view.layer.render(in: context)
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        completion(image)
    }
    
    // 查找 ScrollView 的辅助方法
    private func findScrollView(in view: UIView) -> UIScrollView? {
        if let scrollView = view as? UIScrollView {
            return scrollView
        }
        
        for subview in view.subviews {
            if let scrollView = findScrollView(in: subview) {
                return scrollView
            }
        }
        
        return nil
    }
}


//extension View {
//    func takeScrollViewSnapshot(completion: @escaping (UIImage?) -> Void) {
//        let hostingController = UIHostingController(rootView: self.ignoresSafeArea())
//        let window = UIApplication.shared.windows.first
//        hostingController.view.frame = window?.bounds ?? CGRect(x: 0, y: 0, width: 300, height: 500)
//        
//        // 设置背景色确保内容可见
//        hostingController.view.backgroundColor = .white
//        
//        window?.addSubview(hostingController.view)
//        
//        // 使用更长的延迟确保完全渲染
//        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
//            if let scrollView = self.findScrollView(in: hostingController.view) {
//                self.captureScrollViewContent(scrollView: scrollView, completion: completion)
//            } else {
//                self.captureRegularView(view: hostingController.view, completion: completion)
//            }
//            
//            hostingController.view.removeFromSuperview()
//        }
//    }
//    
//    private func captureScrollViewContent(scrollView: UIScrollView, completion: @escaping (UIImage?) -> Void) {
//        let originalOffset = scrollView.contentOffset
//        
//        // 使用更大的延迟确保 ScrollView 内容加载完成
//        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
//            let renderer = UIGraphicsImageRenderer(size: scrollView.contentSize)
//            let image = renderer.image { ctx in
//                // 保存当前状态
//                ctx.cgContext.saveGState()
//                
//                // 遍历所有子视图并渲染
//                for subview in scrollView.subviews {
//                    let frame = subview.convert(subview.bounds, to: scrollView)
//                    ctx.cgContext.saveGState()
//                    ctx.cgContext.translateBy(x: frame.origin.x, y: frame.origin.y)
//                    subview.drawHierarchy(in: subview.bounds, afterScreenUpdates: true)
//                    ctx.cgContext.restoreGState()
//                }
//                
//                ctx.cgContext.restoreGState()
//            }
//            
//            scrollView.contentOffset = originalOffset
//            completion(image)
//        }
//    }
//    
//    private func findScrollView(in view: UIView) -> UIScrollView? {
//        if let scrollView = view as? UIScrollView {
//            return scrollView
//        }
//        
//        for subview in view.subviews {
//            if let scrollView = findScrollView(in: subview) {
//                return scrollView
//            }
//        }
//        
//        return nil
//    }
//    
//    private func captureRegularView(view: UIView, completion: @escaping (UIImage?) -> Void) {
//        let renderer = UIGraphicsImageRenderer(size: view.bounds.size)
//        let image = renderer.image { ctx in
//            view.drawHierarchy(in: view.bounds, afterScreenUpdates: true)
//        }
//        completion(image)
//    }
//}

// 图片预览视图
struct ImagePreviewView: View {
    let image: UIImage
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            ScrollView {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: .infinity)
            }
            .navigationBarItems(trailing: Button("完成") {
                presentationMode.wrappedValue.dismiss()
            })
            .navigationTitle("预览(已保存至相册)".localized())
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}




extension Color {
    static var random: Color {
        return Color(red: .random(in: 0...1),
                     green: .random(in: 0...1),
                     blue: .random(in: 0...1))
    }
}

extension Notification.Name {
    static let requireLogin = Notification.Name("RequireLoginNotification") //提示登录
    
    static let screenSnapshot = Notification.Name("ScreenSnapshotNofication") //截屏
    
    static let needRefresh = Notification.Name("NeedRefreshConversation") //刷新
     
    static let deleteNeedRefresh = Notification.Name("DeleteNeedRefreshConversation") //刷新
    
    static let addDialogueSessionNoti = Notification.Name("AddDialogueSessionNoti") //新增会话
    
    static let goImageLocation = Notification.Name("GoImageLocation") //定位到聊天图片位置
    
    static let needGetUserInfo = Notification.Name("NeedGetUserInformation") //获取用户信息
    
    static let rechargeSuccess = Notification.Name("NeedRefreshRechargeSuccess") //充值成功
    
    static let rechargeCancelled = Notification.Name("NeedRefreshRechargeCancelled") //充值取消
    
    static let rechargeFailed = Notification.Name("NeedRefreshRechargeFailed") //充值失败
     
    static let loginSuccess = Notification.Name("LoginSuccess") //登录成功
    
    static let cancelAccount = Notification.Name("CancelAccount") //注销账号成功
    
    
}

struct ScrollViewHeightPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

struct ContentHeightPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}



struct ScrollOffsetPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = 0

    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

extension Color {
    init(hex: UInt, alpha: Double = 1) {
        self.init(
            .sRGB,
            red: Double((hex >> 16) & 0xff) / 255,
            green: Double((hex >> 08) & 0xff) / 255,
            blue: Double((hex >> 00) & 0xff) / 255,
            opacity: alpha
        )
    }
}

#endif



