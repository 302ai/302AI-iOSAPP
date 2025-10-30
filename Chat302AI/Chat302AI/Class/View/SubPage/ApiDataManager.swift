//
//  ApiDataManager.swift
//  Chat302AI
//
//  Created by Adswave on 2025/9/1.
//

import SwiftUI


struct ApiItem: Identifiable, Codable, Equatable {
    var id = UUID()
    var name: String
    var host: String
    var apiKey: String
    var model: AI302Model
    var apiNote: String
    var modelId: String = ""
    var baseURL: String = ""
    var capabilities: ModelCapabilities = ModelCapabilities()
    
    // 模型能力结构体
    struct ModelCapabilities: Codable, Equatable {
        var reasoning: Bool = false
        var imageUnderstanding: Bool = false
        var advancedSettings: AdvancedSettings = AdvancedSettings()
        
        struct AdvancedSettings: Codable, Equatable {
            var customBaseURL: String = ""
            var customAPIKey: String = ""
        }
    }
    
    // 预设数据
    static var presetItems: [ApiItem] {
        [
            ApiItem(name: "302.AI", host: "api.302.ai", apiKey: AppConfiguration.shared.OAIkey.isEmpty ? "" : AppConfiguration.shared.OAIkey, model: AI302Model(id: "gpt-4.1", is_moderated: true), apiNote: "",modelId: "deepseek-chat"),
            ApiItem(name: "OpenAI", host: "api.openai.com", apiKey: "", model: AI302Model(id: "gpt-4.1", is_moderated: true), apiNote: ""),
            ApiItem(name: "Anthropic", host: "api.anthropic.com", apiKey: "", model: AI302Model(id: "claude-3-5-sonnet-latest", is_moderated: true), apiNote: ""),
            ApiItem(name: "自定义", host: "xxx.xxxai.com", apiKey: "", model: AI302Model(id: "your-model-id", is_moderated: true), apiNote: "")
        ]
    
        
        /*
        //CHN CN
        if AppConfiguration.shared.appStoreRegion == "CHN" || AppConfiguration.shared.appStoreRegion == "CN" || AppConfiguration.shared.appStoreRegion == "USA" {
            [
                ApiItem(name: "302.AI", host: "api.302ai.cn/cn", apiKey: AppConfiguration.shared.OAIkey.isEmpty ? "" : AppConfiguration.shared.OAIkey, model: AI302Model(id: "deepseek-chat",is_moderated: false), apiNote: ""),
                ApiItem(name: "智谱AI", host: "open.bigmodel.cn", apiKey: "", model: AI302Model(id: "glm-g-plus",is_moderated: true), apiNote: ""),
                ApiItem(name: "自定义", host: "xxx.xxxai.com", apiKey: "", model: AI302Model(id:"your-model-id",is_moderated: true), apiNote: "")
            ]
        }else if AppConfiguration.shared.appStoreRegion == "" {
            [
                ApiItem(name: "302.AI", host: "api.302ai.cn/cn", apiKey: "", model: AI302Model(id: "deepseek-chat",is_moderated: false), apiNote: ""),
                ApiItem(name: "智谱AI", host: "open.bigmodel.cn", apiKey: "", model: AI302Model(id: "glm-g-plus",is_moderated: true), apiNote: ""),
                ApiItem(name: "自定义", host: "xxx.xxxai.com", apiKey: "", model: AI302Model(id:"your-model-id",is_moderated: true), apiNote: "")
            ]
        }else {
            [
                ApiItem(name: "302.AI", host: "api.302.ai", apiKey: AppConfiguration.shared.OAIkey.isEmpty ? "" : AppConfiguration.shared.OAIkey, model: AI302Model(id: "gpt-4.1",is_moderated: true), apiNote: ""),
                ApiItem(name: "OpenAI", host: "api.openai.com", apiKey: "", model: AI302Model(id: "gpt-4.1",is_moderated: true), apiNote: ""),
                ApiItem(name: "Anthropic", host: "api.anthropic.com", apiKey: "", model: AI302Model(id:"claude-3-5-sonnet-latest",is_moderated: true), apiNote: ""),
                ApiItem(name: "自定义", host: "xxx.xxxai.com", apiKey: "", model: AI302Model(id:"your-model-id",is_moderated: true), apiNote: "")
            ]
        }
        */
        
    }
}




class ApiDataManager: ObservableObject {
    
    static let shared = ApiDataManager()
    
    @Published var apiItems: [ApiItem] = []
    
    @Published var selectedItemId: UUID? {
        didSet {
            // 当 selectedItemId 变化时，自动存储到 UserDefaults
            if let selectedId = selectedItemId {
                UserDefaults.standard.set(selectedId.uuidString, forKey: "selectedItemId")
                print("已保存选中ID: \(selectedId.uuidString)")
            } else {
                UserDefaults.standard.removeObject(forKey: "selectedItemId")
                print("已清除选中ID")
            }
        }
    }
    
    static let availableModels = [ "Doubao-pro-32k", "qwen-vl-max" , "deepseek-chat" ]
    
    var selectedItem: ApiItem? {
        if let selectedItemId = selectedItemId {
            return apiItems.first { $0.id == selectedItemId }
        }
        return nil
    }
    
    init() {
        loadData()
    }
    
    func loadData() {
        print("开始加载数据...")
        
        // 加载 apiItems
        if let data = UserDefaults.standard.data(forKey: "apiItems") {
            do {
                let decoded = try JSONDecoder().decode([ApiItem].self, from: data)
                apiItems = decoded
                print("成功加载 \(apiItems.count) 个API项目")
            } catch {
                print("解码apiItems失败: \(error)")
                apiItems = ApiItem.presetItems
                print("使用预设项目")
            }
        } else {
            apiItems = ApiItem.presetItems
            print("没有保存的数据，使用预设项目")
        }
        
        // 恢复 selectedItemId
        if let savedIdString = UserDefaults.standard.string(forKey: "selectedItemId"),
           let savedId = UUID(uuidString: savedIdString) {
            
            // 检查该ID是否仍然存在于apiItems中
            if apiItems.contains(where: { $0.id == savedId }) {
                selectedItemId = savedId
                print("恢复上次选中的项目ID: \(savedId.uuidString)")
            } else {
                // 如果ID不存在，选择第一个项目
                selectedItemId = apiItems.first?.id
                print("选中项目不存在，选择第一个项目: \(selectedItemId?.uuidString ?? "无")")
            }
        } else {
            // 如果没有保存的ID，选择第一个项目
            selectedItemId = apiItems.first?.id
            print("没有保存的选中ID，选择第一个项目: \(selectedItemId?.uuidString ?? "无")")
        }
        
        print("数据加载完成，当前选中ID: \(selectedItemId?.uuidString ?? "无")")
    }
    
    func saveData() {
        do {
            let encoded = try JSONEncoder().encode(apiItems)
            UserDefaults.standard.set(encoded, forKey: "apiItems")
            print("数据已保存到UserDefaults，共 \(apiItems.count) 个项目")
        } catch {
            print("数据编码失败: \(error)")
        }
    }
    
    // 删除项目方法
    func deleteItem(_ item: ApiItem) {
        if let index = apiItems.firstIndex(where: { $0.id == item.id }) {
            // 如果删除的是当前选中的项目，需要重新选择
            if selectedItemId == item.id {
                // 尝试选择下一个项目，如果没有则选择第一个
                if apiItems.count > 1 {
                    let nextIndex = (index == apiItems.count - 1) ? index - 1 : index + 1
                    selectedItemId = apiItems[nextIndex].id
                } else {
                    selectedItemId = nil
                }
            }
            
            apiItems.remove(at: index)
            saveData()
            print("已删除项目: \(item.name)")
        }
    }
    
    // 添加项目方法
    func addItem(_ item: ApiItem) {
        apiItems.append(item)
        saveData()
        selectItem(item)
        print("已添加项目: \(item.name)")
    }
    
    func updateItem(_ item: ApiItem) {
        if let index = apiItems.firstIndex(where: { $0.id == item.id }) {
            apiItems[index] = item
            saveData()
            print("已更新项目: \(item.name)")
        }
    }
    
    func selectItem(_ item: ApiItem) {
        selectedItemId = item.id
        print("已选中项目: \(item.name), ID: \(item.id.uuidString)")
    }
    
    
    
    // MARK: - 恢复预设数据方法
    
    /// 恢复预设数据（替换当前所有数据）
    func restorePresetData() {
        apiItems = ApiItem.presetItems
        selectedItemId = apiItems.first?.id
        saveData()
        print("已恢复预设数据，共 \(apiItems.count) 个项目")
    }
    
    /// 恢复预设数据（可选是否保留现有数据）
    /// - Parameter keepExisting: 是否保留现有数据，true为合并，false为替换
    func restorePresetData(keepExisting: Bool) {
        if keepExisting {
            // 合并模式：只添加不存在的预设项目
            let existingNames = apiItems.map { $0.name }
            let newPresetItems = ApiItem.presetItems.filter { !existingNames.contains($0.name) }
            
            if !newPresetItems.isEmpty {
                apiItems.append(contentsOf: newPresetItems)
                saveData()
                print("已合并预设数据，新增 \(newPresetItems.count) 个项目")
            } else {
                print("所有预设项目已存在，无需合并")
            }
        } else {
            // 替换模式：完全替换为预设数据
            restorePresetData()
        }
    }
    
    /// 重置为预设数据并清除所有用户数据
    func resetToPresetData() {
        // 清除UserDefaults中的相关数据
        UserDefaults.standard.removeObject(forKey: "apiItems")
        UserDefaults.standard.removeObject(forKey: "selectedItemId")
        
        // 重新加载预设数据
        apiItems = ApiItem.presetItems
        selectedItemId = apiItems.first?.id
        saveData()
        
        print("已重置为预设数据，共 \(apiItems.count) 个项目")
    }
    
    /// 检查当前数据是否与预设数据相同
    func isSameAsPresetData() -> Bool {
        let currentNames = apiItems.map { $0.name }.sorted()
        let presetNames = ApiItem.presetItems.map { $0.name }.sorted()
        
        return currentNames == presetNames
    }
    
    
}


 
