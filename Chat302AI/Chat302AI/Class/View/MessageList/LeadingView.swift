//
//  LeadingView.swift
//  GPTalks
//
//  Created by Adswave on 2025/5/29.
//

import SwiftUI
 
  

#if !os(macOS)
import SwiftUI
import OpenAI
import SwiftUIIntrospect

enum PresentViewType: String {
    case prompt = "Prompt"  //提示词
    case store = "Store"  //应用商店
    case library = "Library"  //应用商店
    case setting = "Setting"  //应用商店
}


struct LeadingView: View {
     
    
    @Bindable var viewModel: DialogueViewModel
    @State var imageSession: ImageSession = .init()
    @State var navigateToImages = false
    @Binding var isPresented: Bool
    @Binding var offsetX: CGFloat
    
    var presentViewTypeTap: (PresentViewType) -> Void
    
    @State private var showSettingView = false //设置
    @State private var showStoreSheet = false // 应用商店
    @State private var showTipsSheet = false // 提示词
    
    @State private var models = [AI302Model]()
    @State private var hasLoadedModels = false
    
    @ObservedObject var config = AppConfiguration.shared
    @State var showAlert = false
    @State private var showHelpModal = false
      
    @State private var lastContentOffset: CGFloat = 0
    @State private var isSearchBarVisible = true
    @State private var lastTriggerTime: Date? // 记录上次触发时间
    @State private var debounceTask: DispatchWorkItem? // 防抖任务
    
    
    
    var body: some View {
        ZStack{
            VStack(alignment:.leading) {
                
                Spacer(minLength: 50)
                
                //nav & title
                /*
                HStack{
                    //返回
                    Button {
                        hiddenView()
                        offsetX = 0
                        
                    } label: {
                        Image(systemName: "arrow.left")
                            .foregroundStyle(Color(white: 0.3))
                    }
                    .offset(x:20)
                    
                    Spacer()
                    
                    CustomText("会话历史")
                    
                    Spacer()
                     
                    //新建会话
                    Button {
                        hiddenView()
                        offsetX = 0
                        offsetX = 0
                        viewModel.addDialogue()
                    } label: {
                        Image(systemName: "plus")
                            .foregroundStyle(Color(white: 0.3))
                    }
                    .offset(x:-20)
                }
                Divider()
                 */
                
                
                // 1. 添加搜索文本框
                if isSearchBarVisible {
//                    TextField("请输入搜索内容".localized(), text: $viewModel.searchText)
//                        .padding()
//                        .font(.subheadline)
//                        .frame(height:38)
//                        .background(Color(.systemBackground))
//                        .cornerRadius(8)
//                        .padding(.horizontal)
//                        .offset(y:-5)
                    
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.gray)
                            .padding(.leading, 8)
                        
                        TextField("请输入搜索内容".localized(), text: $viewModel.searchText)
                            .padding(.leading,1)
                            .font(.subheadline)
                            .frame(height: 38)
                    }
                    //.background(ThemeManager.shared.getCurrentColorScheme() == .dark ? .gray.opacity(0.2) : Color(.systemBackground))
                    .background(ThemeManager.shared.getCurrentColorScheme() == .dark ? Color(.systemGray6) : Color.white)
                    .cornerRadius(8)
                    .padding(.horizontal)
                    .offset(y: -5)
                    
                }
                
                //提示词 & 应用商店
                /*
                HStack (spacing: 10) {
                    Button(action: {
                        
                        if !config.apiHost.contains("302"){
                            return
                        }
                        
                        if config.OAIkey.isEmpty {
                            showAlert.toggle()
                            return
                        }
//                        showTipsSheet.toggle()  //提示词
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            hiddenView()
                        offsetX = 0
                        }
                        presentViewTypeTap(.prompt)
                        
                    }) {
                        HStack {
                            Image("bear")
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 22, height: 22)
                                .clipped()
                            
                            CustomText("提示词")
                                .foregroundColor(.primary)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical,9)
                        .cornerRadius(10)
                        .background(
                            RoundedRectangle(cornerRadius: 6)
                                .fill(.background)
                                .shadow(radius: 1.5) // 阴影效果
                        )
                    }
                    
                    Spacer()
                    
                    Button(action: {
                        print("应用商店 按钮 被点击")
                        
                        if !config.apiHost.contains("302"){
                            return
                        }
                        
                        if config.OAIkey.isEmpty {
                            showAlert.toggle()
                            return
                        }
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            isPresented = false
                        offsetX = 0
                        }
                        presentViewTypeTap(.store)
                    }) {
                        
                        HStack {
                            Image("shop")
                                .aspectRatio(contentMode: .fill) // 填充整个frame
                                .frame(width: 20, height: 20)
                                .clipped()
                            
                            CustomText("应用商店")
                                .foregroundColor(.primary)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical,9)
                        .cornerRadius(10)
                        .background(
                            RoundedRectangle(cornerRadius: 6)
                                .fill(.background)
                                .shadow(radius: 1.5) // 阴影效果
                        )
                         
                    }
                }
                .padding(.horizontal,20)
                .padding(.top,5)
                
                .sheet(isPresented: $showStoreSheet) {
                    
                    StoreView2(viewModel:viewModel)
                        .presentationDragIndicator(.visible) // 显示拖拽指示器
                }
                
                .sheet(isPresented: $showTipsSheet) {
                    PromptsListView(viewModel:viewModel) // 半屏页面内容
                        .presentationDetents([.large]) // 设置半屏高度
                        .presentationDragIndicator(.visible) // 显示拖拽指示器
                }
             */
 

                list
                    .fullScreenCover(isPresented: $navigateToImages, onDismiss: {navigateToImages = false}) {
                        NavigationStack {
                            ImageCreator(imageSession: imageSession)
                        }
                    }
                    .animation(.default, value: viewModel.selectedState)
                    .animation(.default, value: viewModel.searchText)
                
                    .scrollDismissesKeyboard(.immediately)//收起键盘
                 
                
                Spacer(minLength: 60)
                
                
#if os(iOS)
                
                //.navigationTitle(viewModel.selectedState.rawValue)
                    .navigationTitle("")
#endif
            }
            .offset(y:20)
            
            .sheet(isPresented: $showAlert) {
                //ApiItemDetailView()
            }
            
            
//            .alert("请输入 302AI API Key", isPresented: $showAlert) {
//                TextField("API Key", text: $config.OAIkey)
//                Button("确定") {}
//                
//                Button("获取API Key") {
//                    UIApplication.shared.open(URL(string: "https://302.ai/")!)
//                }
//                Button("取消", role: .cancel) {}
//            }
            .background(.background)
              
//            .onAppear {
//                if !hasLoadedModels {
//                    Task {
//                        await loadModelsData()
//
//                    }
//                }
//            }

        }
        .backgroundStyle(Color(ThemeManager.shared.getCurrentColorScheme() == .dark ? .black : .init(hex: "#F9F9F9")))
        .frame(maxWidth: .infinity, alignment: .leading)
        .edgesIgnoringSafeArea(.all)
        
    }
        
    
    func hiddenView(){
         
        isPresented = false
        viewModel.searchText = ""
    }
    
    
    func loadModelsData() async {
        
        NetworkManager.shared.fetchModels { result in
            // 可以在这里处理回调，或者直接依赖 @Published 属性
            switch result {
                case .success(let models):
                    //print("获取到的模型数据：\(models)")
                     
                    DispatchQueue.main.async {
                        // 例如更新某个 @State 变量
                        self.models = models
                        ModelDataManager.shared.saveModels(models)
                        hasLoadedModels = true
                    }
                    
                case .failure(let error):
                    // 处理错误
                    print("请求失败：\(error.localizedDescription)")
                }
        }
    }
     
    
    @ViewBuilder
    private var list: some View {
            if viewModel.shouldShowPlaceholder {
                //PlaceHolderView(imageName: "message.fill", title: viewModel.placeHolderText)
                VStack {
                    //Spacer(minLength: UIScreen.main.bounds.height/1.5)
                    Spacer()
                    Text("")
                    Spacer()
                }
            } else {
                
                ZStack {
                    ScrollView {
                        VStack(spacing: 0) {
                            // 顶部两个按钮 顶部菜单 - 始终显示
                            MenuSectionView(
                                buttons: [
                                    .init(iconName: "新会话", title: "新的聊天".localized(), action: {
                                        NotificationCenter.default.post(name: .addDialogueSessionNoti, object: nil)
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                            hiddenView()
                                            offsetX = 0
                                        }
                                    }),
//                                    .init(iconName: "资源库", title: "资源库".localized(), action: {
//                                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
//                                            isPresented = false
//                                            offsetX = 0
//                                        }
//                                        presentViewTypeTap(.library)
//                                    })
                                ],
                                verticalSpacing: 12
                            )
                            .padding(.top, 16)
                            
                            // 分组显示的列表 - 只在有数据时显示
                            if !viewModel.currentDialogues.groupedByDate().isEmpty {
                                LazyVStack(spacing: 0, pinnedViews: [.sectionHeaders]) {
                                    ForEach(viewModel.currentDialogues.groupedByDate(), id: \.title) { group in
                                        Section {
                                            ForEach(group.dialogues) { session in
                                                Button(action: {
                                                    if viewModel.isMultiSelectMode {
                                                        if viewModel.selectedDialogues.contains(session) {
                                                            viewModel.selectedDialogues.remove(session)
                                                        } else {
                                                            viewModel.selectedDialogues.insert(session)
                                                        }
                                                    } else {
                                                        viewModel.selectedDialogue = session
                                                        isPresented = false
                                                        offsetX = 0
                                                    }
                                                }) {
                                                    DialogueListItem(session: session, mutiSelectBtnTap: { muti in
                                                        viewModel.isMultiSelectMode = true
                                                        viewModel.selectedDialogues.insert(session)
                                                    })
                                                    .padding(.horizontal, 16)
                                                    .padding(.vertical, 12)
                                                    .frame(maxWidth: .infinity)
                                                     
                                                    
                                                }
                                                .buttonStyle(PlainButtonStyle())
                                            }
                                        } header: {
                                            HStack {
                                                // 今天 "昨天" 最近7天" "更早"
                                                Text(group.title)
                                                    .font(.headline)
                                                    .foregroundColor(.secondary)
                                                    .padding(.leading, 20)
                                                    .padding(.top, 12)
                                                    .padding(.bottom, -5)
                                                Spacer()
                                            }
                                            .background(
                                                Color(ThemeManager.shared.getCurrentColorScheme() == .dark ?
                                                    .black : .init(hex: "#F9F9F9")))
                                            .frame(maxWidth: .infinity)
                                        }
                                    }
                                }
                                
                                VStack{
                                    
                                }.frame(height: 1)
                            } else {
                                // 添加空状态视图
                                VStack {
                                    Spacer()
                                    Text("暂无会话".localized())
                                        .foregroundColor(.secondary)
                                        .padding()
                                    Spacer()
                                }
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                                
                                
                            }
                            
                            // 底部占位空间
                            Spacer()
                                .frame(height: 80)
                        }
                    }
                    
                    VStack {
                        Spacer()
                        
                        Group {
                            if viewModel.isMultiSelectMode {
                                HStack {
                                    Button {
                                        viewModel.isMultiSelectMode = false
                                        viewModel.selectedDialogues.removeAll()
                                    } label: {
                                        HStack {
                                            Text("取消".localized())
                                        }
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 9)
                                        .cornerRadius(10)
                                        .foregroundStyle(Color.black.opacity(0.5))
                                        .background(
                                            RoundedRectangle(cornerRadius: 10)
                                                .fill(.background)
                                                .overlay(
                                                    RoundedRectangle(cornerRadius: 10)
                                                        .stroke(Color.black.opacity(0.5), lineWidth: 1)
                                                )
                                        )
                                    }
                                    Spacer(minLength: 52)
                                    
                                    Button {
                                        if viewModel.selectedDialogues.count == 0 {
                                            return
                                        }
                                        
                                        viewModel.isMultiSelectMode = false
                                        viewModel.deleteSelectedDialogues()
                                    } label: {
                                        HStack {
                                            Text("删除".localized())
                                        }
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 9)
                                        .background(Color(viewModel.selectedDialogues.isEmpty ? .gray : .init(hex: "#E31111")))
                                        .foregroundColor(.white)
                                        .cornerRadius(10)
                                        .background(
                                            RoundedRectangle(cornerRadius: 10)
                                                .fill(.background)
                                        )
                                    }
                                }
                                .padding(.horizontal, 16)
                            } else {
                                // 悬浮在底部的按钮 - 始终显示
                                
                                Button {
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                        isPresented = false
                                        offsetX = 0
                                    }
                                    presentViewTypeTap(.setting)
                                } label: {
                                    HStack(spacing: 12) {
                                        if let imgUrl = URL(string: UserDataManager.shared.getUserInfo()?.data?.safeAvatar ?? "https://file.302.ai/gpt/imgs/5b36b96aaa052387fb3ccec2a063fe1e.png") {
                                            NetworkImageView(url: imgUrl)
                                                .scaledToFit()
                                                .frame(width: 28, height: 28)
                                                .cornerRadius(14)
                                                .padding(.top, 3)
                                        }else{
                                            Image("applogo")
                                                .resizable()
                                                .frame(width: 24, height: 24)
                                        }
//                                        Image("applogo")
//                                            .resizable()
//                                            .frame(width: 24, height: 24)
                                        
                                        Text(config.username)
                                            .font(.system(size: 16, weight: .regular))
                                        
                                        Spacer()
                                        
                                        Image(systemName: "chevron.right")
                                            .foregroundColor(Color(.label))
                                            .font(.system(size: 14))
                                            .hidden()
                                    }
                                    .contentShape(Rectangle())
                                }
                                .padding(.horizontal, 16)
                                .padding(.vertical, 14)
                                .frame(maxWidth: .infinity)
                                .buttonStyle(PlainButtonStyle())
                                .background(
                                    //hiddenBackView ? nil : // 隐藏背景
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(ThemeManager.shared.getCurrentColorScheme() == .dark ? .black : (Color(hex: "#F9F9F9"))   )
                                )
                                
//                                MenuSectionView(
//                                    buttons: [
//                                        .init(iconName: "applogo", title: config.username,  action: {
//                                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
//                                                isPresented = false
//                                                offsetX = 0
//                                            }
//                                            presentViewTypeTap(.setting)
//                                        })
//                                    ],
//                                    verticalSpacing: 8
//                                )
                            }
                        }
                    }
                }
                 
                
                
//                List(viewModel.currentDialogues) { session in
//                    //DialogueListItem(session: session)
//                    Button(action: {
//                        viewModel.selectedDialogue = session
//                        isPresented = false
//                        offsetX = 0
//                        // 其他点击处理逻辑
//                    }) {
//                        DialogueListItem(session: session)
//                    }
//                    .listRowBackground(Color(ThemeManager.shared.getCurrentColorScheme() == .dark ? .black : .init(hex: "#F9F9F9")))
//                    .buttonStyle(PlainButtonStyle()) // 保持列表项外观
//                    .listRowSeparator(.hidden) // 隐藏分割线
//                }
//                .coordinateSpace(name: "List")
//                .listStyle(.plain)
//                .onPreferenceChange(ScrollOffsetKey.self) { offset in
//                    handleScrollOffsetChange(offset)
//                    
//                }
//                .introspect(.list, on: .iOS(.v16, .v17)) { tableView in
//                    tableView.bounces = false // 禁用回弹
//                }
            }
        
    }
    
    
    struct MenuRowButton: View {
        let iconName: String
        let title: String
        let action: () -> Void
        
        
        var body: some View {
            Button(action: action) {
                HStack(spacing: 12) {
                    Image(iconName)
                        .resizable()
                        .frame(width: 24, height: 24)
                    
                    Text(title)
                        .font(.system(size: 16, weight: .regular))
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .foregroundColor(Color(.label))
                        .font(.system(size: 14))
                        //.hidden(hiddenBackView)
                }
                .contentShape(Rectangle())
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .frame(maxWidth: .infinity)
            .background(
                //hiddenBackView ? nil : // 隐藏背景
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color(ThemeManager.shared.getCurrentColorScheme() == .dark ?
                              UIColor.systemGray6 : .white))
            )
            .buttonStyle(PlainButtonStyle())
        }
    }
    
    
    
    struct MenuSectionView: View {
        let buttons: [MenuButton]
        let verticalSpacing: CGFloat
        
        struct MenuButton {
            let iconName: String
            let title: String
            let hiddenBackView = false
            let action: () -> Void
        }
        
        var body: some View {
            VStack(alignment: .leading, spacing: verticalSpacing) {
                ForEach(buttons.indices, id: \.self) { index in
                    MenuRowButton(
                        iconName: buttons[index].iconName,
                        title: buttons[index].title,
                        action: buttons[index].action
                    )
                }
            }
            .background(Color(ThemeManager.shared.getCurrentColorScheme() == .dark ? .black.opacity(0.9) : .init(hex: "#F9F9F9")))
            .frame(maxWidth: .infinity)
            .padding(.horizontal, 16)
        }
    }
    
    
    
    
    /// 处理滚动偏移变化（带冷却时间）
    private func handleScrollOffsetChange(_ offset: CGFloat) {
        let now = Date()
  
        let scrollDelta = offset - lastContentOffset
        lastContentOffset = offset

        let isBouncing = offset < 0 // 过滤回弹
        guard !isBouncing else { return }
        
        let isScrollingUp = scrollDelta > 50//threshold
        let isScrollingDown = scrollDelta < -50//threshold

        withAnimation(.smooth) {
             
            if isScrollingUp {
                isSearchBarVisible = false
            } else if isScrollingDown  {
                isSearchBarVisible = true
            }
              
            
        }

        lastTriggerTime = now // 记录本次触发时间
    }
}

#endif
