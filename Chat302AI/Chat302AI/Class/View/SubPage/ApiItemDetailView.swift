//
//  ApiListView2.swift
//  GPTalks
//
//  Created by Adswave on 2025/4/10.
//

import SwiftUI
import AlertToast
 


// 用于创建新API项的视图
struct CreateApiItemView: View {
    @EnvironmentObject var dataManager: ApiDataManager
    @Environment(\.presentationMode) var presentationMode
    @State private var newItem = ApiItem(
        name: "新API",
        host: "",
        apiKey: "",
        model: AI302Model(id: "", is_moderated: true),
        apiNote: ""
    )
    
    var body: some View {
        ApiItemDetailViewWrapper(item: $newItem, isNewItem: true)
            .onDisappear {
                // 当视图消失时，如果是新项目且已填写必要信息，则保存
                if !newItem.name.isEmpty && !newItem.host.isEmpty {
                    dataManager.addItem(newItem)
                }
            }
    }
}

// 包装器视图，用于处理新建和编辑的不同逻辑
struct ApiItemDetailViewWrapper: View {
    @Binding var item: ApiItem
    var isNewItem: Bool = false
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        ApiItemDetailView(draftItem: item, isNewItem: isNewItem)
            .onDisappear {
                if isNewItem {
                    // 更新传递的item引用
                    item = (ApiItemDetailView.draftItem ?? item)
                }
            }
    }
}

// 修改 ApiItemDetailView 以支持新建功能
struct ApiItemDetailView: View {
    @EnvironmentObject var dataManager: ApiDataManager
    @EnvironmentObject var config: AppConfiguration
    @Environment(\.dismiss) var dismiss
    @Environment(\.presentationMode) var presentationMode
    
    @State var draftItem: ApiItem
    var isNewItem: Bool = false
    
    @State private var isShowingList = false
    @State private var isShowingModelList = false
    @State var isShowToast = false
    @State var hintText = ""
    @State var isShowProgress = false
    @State private var showSigninSafari = false
    
    // 静态变量用于在包装器中访问draftItem
    static var draftItem: ApiItem?
    
    init(draftItem: ApiItem, isNewItem: Bool = false) {
        _draftItem = State(initialValue: draftItem)
        self.isNewItem = isNewItem
    }
     
    var body: some View {
        List {
            // 基本信息 Section
            Section(
                header: VStack(alignment: .leading, spacing: 4) {
                    Text("模型ID".localized())
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                },
                footer: HStack {
                       Text("这是模型的真实名称，用于实际发起请求".localized())
                           .font(.caption)
                           .foregroundColor(.gray)
                       Spacer()
                   }
                   .padding(.top, 4)
            ) {
                // 模型ID
                VStack(alignment: .leading, spacing: 8) {
                    
                    TextField("请输入模型ID".localized(), text: $draftItem.modelId)
                        .textFieldStyle(PlainTextFieldStyle())
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                }
                .padding(.vertical, 8)
            }
            
             
            Section(
                header: VStack(alignment: .leading, spacing: 4) {
                    Text("备注".localized())
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                },
                footer: HStack {
                    Text("你可以为这个模型设置一个更容易分辨的名字，仅用于展示".localized())
                        .font(.caption)
                        .foregroundColor(.gray)
                    Spacer()
                }
                .padding(.top, 4)
            ) {
                // 备注名称
                VStack(alignment: .leading, spacing: 8) {
                    ZStack(alignment: .trailing) {
                        TextField("请输入备注名称".localized(), text: $draftItem.name)
                            .textFieldStyle(PlainTextFieldStyle())
                            .padding(.trailing, 55) // 为字数显示留出空间
                            .onChange(of: draftItem.name) { newValue in
                                if newValue.count > 20 {
                                    draftItem.name = String(newValue.prefix(20))
                                }
                            }
                        
                        Text("\(draftItem.name.count)/20")
                            .font(.caption)
                            .foregroundColor(draftItem.name.count == 20 ? .red : .gray)
                            .padding(.trailing, 8)
                    }
                    .frame(height: 40)
                    .padding(.horizontal, 5)
                    //.background(
                    //    RoundedRectangle(cornerRadius: 8)
                    //       .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                    //)
                }
                .padding(.vertical, 8)
            }
            
            
            
            // 模型能力 Section
            Section(
                header: VStack(alignment: .leading, spacing: 4) {
                    Text("模型能力".localized())
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            ) {
                // 推理能力
                Toggle(isOn: $draftItem.capabilities.reasoning) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("推理".localized())
                            .font(.body)
                            .foregroundColor(.primary)
                    }
                }
                .toggleStyle(SwitchToggleStyle(tint: .purple))
                
                // 图像理解
                Toggle(isOn: $draftItem.capabilities.imageUnderstanding) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("图像理解".localized())
                            .font(.body)
                            .foregroundColor(.primary)
                    }
                }
                .toggleStyle(SwitchToggleStyle(tint: .purple))
            }
            
            // 高级设置 Section
            Section(
                header: VStack(alignment: .leading, spacing: 4) {
                    Text("高级设置".localized())
                        .font(.body)
                        .foregroundColor(.primary)
                }
            ) {
                // Base URL
                VStack(alignment: .leading, spacing: 8) {
                    Text("Base URL")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    TextField("https://api.302.ai/v1", text: $draftItem.host)
                        .textFieldStyle(PlainTextFieldStyle())
                        .keyboardType(.URL)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                }
                .padding(.vertical, 8)
                
                // API Key
                VStack(alignment: .leading, spacing: 8) {
                    Text("API Key")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    TextField("sk-*******", text: $draftItem.apiKey)
                        .textFieldStyle(PlainTextFieldStyle())
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                }
                .padding(.vertical, 8)
            }
             
        }
        .listStyle(.insetGrouped)
        .navigationTitle(isNewItem ? "添加模型".localized() : "编辑模型".localized())
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                CustomText("保存".localized())
                    .frame(height: 34)
                    .fixedSize()
                    .padding(.horizontal,8)
                    .background(Color(hex: "#8E47F1"))
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    .onTapGesture {
                        saveData { success in
                            if success {
                                dismiss()
                            }
                        }
                    }
            }
            
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
        .toast(isPresenting: $isShowToast) {
            AlertToast(displayMode: .alert, type: .regular, title: hintText)
        }
        .onAppear {
            ApiItemDetailView.draftItem = draftItem
            // 如果是新项目，设置默认值
            if isNewItem && draftItem.modelId.isEmpty {
                draftItem.modelId = draftItem.model.id
            }
        }
        .onDisappear {
            ApiItemDetailView.draftItem = draftItem
        }
    }
    
    func saveData(completion: @escaping (Bool) -> Void) {
        // 验证必填字段
        guard !draftItem.modelId.isEmpty else {
            hintText = "请输入模型ID".localized()
            isShowToast = true
            completion(false)
            return
        }
        
        guard !draftItem.name.isEmpty else {
            hintText = "请输入备注名称".localized()
            isShowToast = true
            completion(false)
            return
        }
        
        if isNewItem {
            // 创建新项目
            var itemToSave = draftItem
            itemToSave.id = UUID()
            itemToSave.model.id = itemToSave.modelId // 同步模型ID
            
            dataManager.addItem(itemToSave)
            dataManager.selectItem(itemToSave)
            
            // 更新配置
            //config.OAIkey = itemToSave.apiKey
            config.chatModel = itemToSave.model.id
            config.apiHost = itemToSave.host
            
            completion(true)
        } else {
            // 更新现有项目
            if let selectedId = dataManager.selectedItemId {
                var updatedItem = draftItem
                updatedItem.id = selectedId
                updatedItem.model.id = updatedItem.modelId // 同步模型ID
                
                // 更新配置
                //config.OAIkey = updatedItem.apiKey
                config.chatModel = updatedItem.model.id
                config.apiHost = updatedItem.host
                
                dataManager.updateItem(updatedItem)
                completion(true)
            } else {
                completion(false)
            }
        }
    }
}
 
 
 

struct ModelListView: View {
    @Binding var selectedModel: String
    @Environment(\.presentationMode) var presentationMode
    @State private var searchText = ""
    @State private var isSearching = true
    @State private var hasScrolledToSelection = false
    @State private var showFeaturedOnly = true  //list显示 is_featured = true 的模型
    
    var body: some View {
        var sortedModels: [AI302Model] {
            ModelDataManager.shared.loadModels().sorted { $0.id < $1.id }
        }
        
        let filteredModels = sortedModels.filter {  model in
            //searchText.isEmpty || $0.id.localizedCaseInsensitiveContains(searchText)
            
            // 搜索条件
            let searchCondition = searchText.isEmpty || model.id.localizedCaseInsensitiveContains(searchText)
            // 精选条件
            let featuredCondition = !showFeaturedOnly || model.is_featured
            
            return searchCondition //&& featuredCondition
        }
        
        NavigationView {
            VStack(spacing: 0) {
                // 搜索栏
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.gray)
                    TextField("搜索模型".localized(), text: $searchText) { isEditing in
                        //isSearching = isEditing
                        //isSearching = true
                    } onCommit: {
                        isSearching = false
                    }
                    .textFieldStyle(.plain)
                    .autocorrectionDisabled()
                    .textInputAutocapitalization(.never)
                    
                    if !searchText.isEmpty {
                        Button(action: {
                            searchText = ""
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.gray)
                        }
                    }
                }
                .padding(8)
                .background(Color(.systemGray6))
                .cornerRadius(8)
                .padding(.horizontal)
                .padding(.vertical, 8)
                
                // 模型列表
                ScrollViewReader { scrollProxy in
                    List(filteredModels, id: \.self) { model in
                        Button(action: {
                            selectedModel = model.id
                            presentationMode.wrappedValue.dismiss()
                        }) {
                            HStack {
                                Text(model.id)
                                Spacer()
                                if selectedModel == model.id {
                                    Image(systemName: "checkmark")
                                        .foregroundColor(.blue)
                                }
                            }
                            .contentShape(Rectangle())
                        }
                        .buttonStyle(PlainButtonStyle())
                        .id(model.id) // 为每个项目设置ID，用于滚动定位
                        .onAppear {
                            // 滚动时收起键盘
                            if isSearching {
                                UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                                isSearching = false
                            }
                        }
                    }
                    .listStyle(.plain)
                    .onAppear {
                        // 当列表首次出现时，滚动到选中的项目
                        if !hasScrolledToSelection && !selectedModel.isEmpty {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                withAnimation {
                                    scrollProxy.scrollTo(selectedModel, anchor: .center)
                                }
                                hasScrolledToSelection = true
                            }
                        }
                    }
                    .onChange(of: searchText) { _ in
                        // 搜索时重置滚动状态
                        hasScrolledToSelection = false
                    }
                    .gesture(
                        DragGesture().onChanged { _ in
                            // 滚动时收起键盘
                            if isSearching {
                                UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                                isSearching = false
                            }
                        }
                    )
                }
            }
            .navigationTitle("选择模型".localized())
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("取消".localized()) {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        }
    }
}


 
