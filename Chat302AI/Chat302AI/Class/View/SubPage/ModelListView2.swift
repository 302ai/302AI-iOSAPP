//
//  ModelListView2.swift
//  Chat302AI
//
//  Created by Adswave on 2025/10/15.
//



import SwiftUI
import Foundation

// 修改后的 AI302Model
struct AI302Model: Hashable, Codable, Identifiable {
    var id: String
    var is_moderated: Bool
    var is_featured: Bool
    var canonical_slug: String?
    var capabilities: [String]?
    var category: String?
    var category_en: String?
    var category_jp: String?
    var context_length: Int?
    var created_on: String?
    var description: String?
    var description_en: String?
    var description_jp: String?
    var first_byte_req_time: String?
    var name: String?
    var object: String?
    var price: [String: String]?
    var pricing: Pricing?
    var supported_tools: Bool?
    var type: String?
    
    // 非 JSON 中的属性
    var model_note: String = ""
    var r1_fusion: Bool = false
    var base_url: String = ""
    var api_key: String = ""
    
    init(id: String, is_moderated: Bool = true, is_featured: Bool = false) {
        self.id = id
        self.is_moderated = is_moderated
        self.is_featured = is_featured
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        is_moderated = try container.decodeIfPresent(Bool.self, forKey: .is_moderated) ?? true
        is_featured = try container.decodeIfPresent(Bool.self, forKey: .is_featured) ?? false
        canonical_slug = try container.decodeIfPresent(String.self, forKey: .canonical_slug)
        capabilities = try container.decodeIfPresent([String].self, forKey: .capabilities)
        category = try container.decodeIfPresent(String.self, forKey: .category)
        category_en = try container.decodeIfPresent(String.self, forKey: .category_en)
        category_jp = try container.decodeIfPresent(String.self, forKey: .category_jp)
        context_length = try container.decodeIfPresent(Int.self, forKey: .context_length)
        created_on = try container.decodeIfPresent(String.self, forKey: .created_on)
        description = try container.decodeIfPresent(String.self, forKey: .description)
        description_en = try container.decodeIfPresent(String.self, forKey: .description_en)
        description_jp = try container.decodeIfPresent(String.self, forKey: .description_jp)
        first_byte_req_time = try container.decodeIfPresent(String.self, forKey: .first_byte_req_time)
        name = try container.decodeIfPresent(String.self, forKey: .name)
        object = try container.decodeIfPresent(String.self, forKey: .object)
        price = try container.decodeIfPresent([String: String].self, forKey: .price)
        pricing = try container.decodeIfPresent(Pricing.self, forKey: .pricing)
        supported_tools = try container.decodeIfPresent(Bool.self, forKey: .supported_tools)
        type = try container.decodeIfPresent(String.self, forKey: .type)
    }
    
    enum CodingKeys: String, CodingKey {
        case id, is_moderated, is_featured, canonical_slug, capabilities, category
        case category_en, category_jp, context_length, created_on, description
        case description_en, description_jp, first_byte_req_time, name, object
        case price, pricing, supported_tools, type
    }
}

struct Pricing: Hashable, Codable {
    var input_token: String?
    var output_token: String?
    var per_request: String?
}
 


// 数据管理器
class ModelDataManager2: ObservableObject {
    
    @Published var models: [AI302Model] = []
    private let saveKey = "SavedModels"
    
    init() {
        loadModels()
    }
    
    // 加载模型
    func loadModels() {
        if let data = UserDefaults.standard.data(forKey: saveKey),
           let decoded = try? JSONDecoder().decode([AI302Model].self, from: data) {
            models = decoded
        } else {
            // 如果没有保存的数据，尝试从 JSON 文件加载初始数据
            loadInitialData()
        }
    }
    
    // 保存模型
    func saveModels() {
        if let encoded = try? JSONEncoder().encode(models) {
            UserDefaults.standard.set(encoded, forKey: saveKey)
        }
    }
    
    func saveModelsData( models: [AI302Model]) {
        if let encoded = try? JSONEncoder().encode(models) {
            UserDefaults.standard.set(encoded, forKey: saveKey)
        }
    }
    
    
    // 加载初始 JSON 数据
    private func loadInitialData() {
          
        
        NetworkManager.shared.fetchModels() { result in
            // 可以在这里处理回调，或者直接依赖 @Published 属性
            switch result {
            case .success(let models):
                //print("获取到的模型数据：\(models)")
                
                DispatchQueue.main.async {
                    // 例如更新某个 @State 变量
                    
                    self.models = models
                    self.saveModels()
                    
                    ModelDataManager.shared.saveModels(models)
                }
                
            case .failure(let error):
                // 处理错误
                print("请求失败：\(error.localizedDescription)")
               
            }
        }
         
    }
    
    // 添加新模型
    func addModel(_ model: AI302Model) {
        models.append(model)
        saveModels()
    }
    
    // 更新模型
    func updateModel(_ model: AI302Model) {
        if let index = models.firstIndex(where: { $0.id == model.id }) {
            models[index] = model
            saveModels()
        }
    }
    
    // 删除模型
    func deleteModel(_ model: AI302Model) {
        models.removeAll { $0.id == model.id }
        saveModels()
    }
    
    // 搜索模型（现在在 ModelListView 中处理筛选逻辑）
    func searchModels(_ searchText: String) -> [AI302Model] {
        if searchText.isEmpty {
            return models.sorted { $0.id < $1.id }
        }
        return models.filter {
            $0.id.localizedCaseInsensitiveContains(searchText) ||
            $0.name?.localizedCaseInsensitiveContains(searchText) == true ||
            $0.description?.localizedCaseInsensitiveContains(searchText) == true
        }
        .sorted { $0.id < $1.id }
    }
}

// 主视图
struct ModelListView2: View {
    
    
    @Environment(\.presentationMode) var presentationMode
    @StateObject private var dataManager = ModelDataManager2()
    @State private var searchText = ""
    @State private var showingAddModel = false
    @State private var isShowingModelDetailView = false
    @State private var selectedModel: AI302Model?
    @State private var showFeaturedOnly = true
    @State private var isSearching = false
    
    
    var filteredModels: [AI302Model] {
        let baseModels = dataManager.models
        
        // 首先根据搜索文本筛选
        let searchFiltered: [AI302Model]
        if searchText.isEmpty {
            searchFiltered = baseModels
        } else {
            searchFiltered = baseModels.filter {
                $0.id.localizedCaseInsensitiveContains(searchText) ||
                $0.name?.localizedCaseInsensitiveContains(searchText) == true ||
                $0.description?.localizedCaseInsensitiveContains(searchText) == true
            }
        }
        
        // 然后根据 featured 筛选
        if showFeaturedOnly {
            return searchFiltered.filter { $0.is_featured }
        } else {
            return searchFiltered
        }
    }
    
    // 按分类分组
    var groupedModels: [String: [AI302Model]] {
        Dictionary(grouping: filteredModels) { model in
            model.category?.isEmpty == false ? model.category! : "Uncategorized"
        }
    }
    
    var sortedCategories: [String] {
        groupedModels.keys.sorted()
    }
     
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // 搜索区域 - 带有灰色背景
                VStack(spacing: 12) {
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.gray)
                        TextField("搜索模型".localized(), text: $searchText) { isEditing in
                            // isSearching = isEditing
                            // isSearching = true
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
                    .background(Color.white)
                    .cornerRadius(8)
                    .padding(.horizontal)
                    .padding(.vertical, 8)
                    
                    // 如果需要Featured筛选开关，取消注释
                    /*
                    HStack {
                        Toggle("Show Featured Only", isOn: $showFeaturedOnly)
                            .font(.subheadline)
                    }
                    .padding(.horizontal)
                    */
                }
                .background(Color(.systemGray6))
                
                // 列表内容区域 - 无灰色背景
                if filteredModels.isEmpty {
                    // 空状态提示
                    VStack(spacing: 16) {
                        Image(systemName: showFeaturedOnly ? "star.slash" : "magnifyingglass")
                            .font(.system(size: 50))
                            .foregroundColor(.gray)
                        
                        Text(showFeaturedOnly ? "No featured models found" : "No models found")
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        if showFeaturedOnly && !searchText.isEmpty {
                            Text("Try adjusting your search or turn off featured filter")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                        }
                    }
                    .padding()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color(.systemBackground))
                } else {
                    // 模型列表 - 使用 Form
                    Form {
                        ForEach(sortedCategories, id: \.self) { category in
                            Section {
                                ForEach(groupedModels[category] ?? []) { model in
                                    Button(action: {
                                        selectedModel = model
                                        isShowingModelDetailView = true
                                    }) {
                                        ModelsRow(
                                            title: model.id,
                                            action: { }
                                        )
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                }
                            } header: {
                                HStack {
                                    Text(category)
                                        .font(.subheadline)
                                        .foregroundColor(.gray)
                                    Spacer()
                                }
                            }
                        }
                    }
                }
            }
            .sheet(isPresented: $showingAddModel) {
                AddModelView(dataManager: dataManager)
            }
            .sheet(isPresented: $isShowingModelDetailView) {
                if let model = selectedModel,
                   let index = dataManager.models.firstIndex(where: { $0.id == model.id }) {
                    ModelDetailView(model: $dataManager.models[index], dataManager: dataManager)
                }
            }
        }
        .navigationBarBackButtonHidden(true)
        .navigationTitle("模型管理".localized())
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
            
            // 新增：右侧工具栏按钮
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    showingAddModel = true
                }) {
                    Image(systemName: "plus")
                        .foregroundColor(.blue)
                }
            }
        }
    }
    
    
}

struct ModelsRow: View {
    let title: String
    let action: () -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            Text(title)
                .font(.body)
                .foregroundColor(.primary)
            
            Spacer()
            
            // 右侧箭头
            Image(systemName: "chevron.right")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(Color.gray)
        }
        .contentShape(Rectangle())
        .padding(.vertical, 8)
    }
}
 

// 搜索栏
struct SearchBar: View {
    @Binding var text: String
    
    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.gray)
            
            TextField("Search models...", text: $text)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            
            if !text.isEmpty {
                Button(action: {
                    text = ""
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.gray)
                }
            }
        }
         
    }
}





// 模型行视图
struct ModelRowView: View {
    let model: AI302Model
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(model.name ?? model.id)
                    .font(.headline)
                Text(model.description ?? "No description")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
            }
            
            Spacer()
            
            if model.is_featured {
                Image(systemName: "star.fill")
                    .foregroundColor(.yellow)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemGray6))
        )
    }
}

// 模型详情视图
struct ModelDetailView: View {
    @Binding var model: AI302Model
    @ObservedObject var dataManager: ModelDataManager2
    @State private var isEditing = false
    
    var body: some View {
        Form {
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
                    
                    TextField("请输入模型ID".localized(), text: $model.id)
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
                    TextField("请输入备注名称".localized(), text: $model.model_note)
                        .textFieldStyle(PlainTextFieldStyle())
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
                Toggle(isOn: $model.r1_fusion) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("推理".localized())
                            .font(.body)
                            .foregroundColor(.primary)
                    }
                }
                .toggleStyle(SwitchToggleStyle(tint: .purple))
                
                // 图像理解
                Toggle(isOn: $model.is_moderated) {
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
                        .foregroundColor(.secondary)
                }
            ) {
                // Base URL
                VStack(alignment: .leading, spacing: 8) {
                    Text("Base URL")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    TextField("https://api.302.ai/v1", text: $model.base_url)
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
                    
                    TextField("sk-*******", text: $model.api_key)
                        .textFieldStyle(PlainTextFieldStyle())
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                }
                .padding(.vertical, 8)
            }
            
            
            
        }
        .navigationTitle("Model Details")
        .navigationBarItems(trailing: Button("Save") {
            dataManager.updateModel(model)
        })
    }
}

// 添加模型视图
struct AddModelView: View {
    @ObservedObject var dataManager: ModelDataManager2
    @Environment(\.dismiss) var dismiss
    @State private var newModel = AI302Model(id: "")
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Required")) {
                    TextField("Model ID", text: $newModel.id)
                }
                
                Section(header: Text("Basic Info")) {
                    TextField("Name", text: Binding(
                        get: { newModel.name ?? "" },
                        set: { newModel.name = $0 }
                    ))
                    TextField("Description", text: Binding(
                        get: { newModel.description ?? "" },
                        set: { newModel.description = $0 }
                    ))
                }
                
                Section(header: Text("Additional Properties")) {
                    TextField("Model Note", text: $newModel.model_note)
                    Toggle("R1 Fusion", isOn: $newModel.r1_fusion)
                    TextField("Base URL", text: $newModel.base_url)
                    SecureField("API Key", text: $newModel.api_key)
                }
            }
            .navigationTitle("Add New Model")
            .navigationBarItems(
                leading: Button("Cancel") {
                    dismiss()
                },
                trailing: Button("Save") {
                    if !newModel.id.isEmpty {
                        dataManager.addModel(newModel)
                        dismiss()
                    }
                }
                .disabled(newModel.id.isEmpty)
            )
        }
    }
}

// 预览
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ModelListView2()
    }
}
