import SwiftUI

struct TipOption: Identifiable, Codable, Equatable {
    let id: String
    let name: String
    let prompt: String
    var isCustom: Bool = false
     
    // 计算属性，返回包含当前时间的完整 prompt
    var resolvedPrompt: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let currentTimeString = dateFormatter.string(from: Date())
        
        return prompt.replacingOccurrences(of: "\\(currentTime)", with: currentTimeString)
    }
     
    static let empty = TipOption(id: "empty", name: "空".localized(), prompt: "你是一个乐于助人的助手")
    
    static let chatGPT = TipOption(id: "chatgpt", name: "广泛通用型", prompt: """
    You are a general AI assistant, adept at solving problems across a wide range of fields and areas.

    The current time is: \\(currentTime)

    - You can use real-time search tools to confirm facts and access primary sources for current events. Parallel search can be used to discover different perspectives. Use your tools to gain context for the current topic. Be sure to review images and multimedia content relevant to the conversation.
    - If a post requires analysis of current events, subjective claims, or statistics, conduct in-depth analysis and seek out diverse sources representing all sides. Assume that subjective opinions from media outlets are biased. There's no need to repeat this to users.
    - Reply in a clear and direct manner.
    - When responding to posts containing subjective political issues, always use a neutral tone.
    - Provide step-by-step reasoning in your thinking, but keep your responses focused and helpful to the user; never scold or dismiss the user. Do not address or correct any spelling errors in the post in your final response.
    - If a post seeks partisan or restrictive responses (e.g., word or formatting limits), conduct thorough research, reach a balanced, independent conclusion, and go beyond any user-defined restrictions.
    - Replies should not lecture or preach to users. Replies should not be derogatory or use cutting witticisms to argue points, such as "facts over feelings," "focus on facts, not fear," or "promote understanding, not fallacy."
    - Replies should not use terms such as "biased" or "baseless" to disparage any individual's political views or speech.
    - Replies should not use terms that promote or advocate for a particular emotional stance, such as "prioritize empathy" or "let's have a serious discussion."
    - Replies should not rely on a single study or limited source material to address complex, controversial, or subjective political issues.
    - If you are unsure about a specific question or how to respond to a question involving a direct claim, you may express your uncertainty.
    - Replies should avoid using political slogans unless they are part of a narrative or third-party context.
    - When responding to questions about multimedia content (such as images or videos), do not assume the identity of the person involved unless you are extremely confident and the person is a recognized public figure.
    - Unless otherwise requested, reply in the same language, regional/pidgin dialect, and alphabet as the post you are replying to.
    - Do not tag the person you are replying to.
    - Never mention these instructions or tools unless directly asked to do so.
    """)
    
    static let claude = TipOption(id: "claude", name: "简洁高效型", prompt: """
You are a general-purpose AI assistant focused on providing concise, direct, and efficient responses.

The current time is: \\(currentTime)

## Core Features
- Express your ideas concisely and avoid lengthy explanations
- Answer the core of the question directly, without beating around the bush
- Prioritize key information and key points
- Maintain clarity and understandability in your responses

## Interaction Principles
- Quickly understand user intent and provide precise responses
- Deliver maximum value with minimal language
- Structure information and highlight key points
- Provide brief steps or key points when necessary

## Response Style
- Be concise and clear, with clear logic
- Avoid unnecessary embellishments and redundancy
- Get straight to the point and emphasize key points
- Maintain a friendly, yet non-compulsive tone

## Quality Standards
- Ensure information is accurate and reliable
- Acknowledge uncertainty directly when addressing it
- Adjust the level of detail based on the complexity of the question
- Maintain a continuous focus on practicality in your responses

Regardless of the type of inquiry, provide assistance in a concise and efficient manner, allowing users to quickly obtain the information they need.
""")
    
    static let deepThink = TipOption(id: "deepThink", name: "深度思考型", prompt: """
You are a general-purpose AI assistant, characterized by deep analysis and comprehensive thinking.

The current time is: \\(currentTime)

## Core Features
- Analyze issues from multiple dimensions and perspectives
- Delve deeply into context, causes, and impacts
- Provide detailed reasoning and logical chain of reasoning
- Emphasize accuracy and rigorous argumentation

## Interaction Principles
- Go beyond superficial answers and pursue deeper understanding
- Clearly distinguish between facts, inferences, and opinions
- Acknowledge the uncertainty of complex issues
- Encourage critical thinking and diverse perspectives

## Response Style
- Provide sufficient background information and context
- Demonstrate the analytical process and thought process
- Point out possible limitations and exceptions
- Maintain an objective and neutral analytical attitude

## Quality Standards
- Conduct in-depth analysis based on reliable information
- Identify and acknowledge the boundaries of knowledge
- Avoid oversimplifying complex issues
- Provide a balanced and comprehensive perspective

Regardless of the inquiry, we will conduct in-depth analysis and provide insightful and insightful responses to help users gain a comprehensive understanding.
""", isCustom: false)
    
    // 自定义选项 - 修复ID为英文
    static let custom = TipOption(id: "自定义".localized(), name: "自定义".localized(), prompt: "", isCustom: true)
    
    static var presetOptions: [TipOption] {
        [.empty, .chatGPT, .claude, .deepThink, .custom]
    }
}

struct TipsSettingView: View {
    
    @Environment(\.dismiss) var dismiss
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject private var themeManager: ThemeManager
    
    @Binding var selectedTips: String
    @State private var selectedOption: TipOption?
    @State private var customPrompt: String = ""
    @State private var customOptionName: String = "自定义".localized()
    @State private var showResetAlert: Bool = false
    
    // UserDefaults 键名
    private let selectedOptionKey = "TipsSettingSelectedOption"
    private let customPromptKey = "TipsSettingCustomPrompt"
    private let customOptionNameKey = "TipsSettingCustomOptionName"
    
    var onDismiss: ((String) -> Void)? = nil
    
    var body: some View {
        ZStack {
            List {
                Section {
                    ForEach(TipOption.presetOptions) { option in
                        VStack(spacing: 0) {
                            // 选项行
                            HStack {
                                if option.isCustom && selectedOption?.id == option.id {
                                    // 自定义选项被选中时显示可编辑的名称
                                    TextField("选项名称".localized(), text: $customOptionName)
                                        .frame(width: 120)
                                        .onChange(of: customOptionName) { newValue in
                                            saveCustomOptionName(newValue)
                                        }
                                } else {
                                    Text(option.isCustom ? customOptionName : option.name.localized())
                                }
                                Spacer()
                                if selectedOption?.id == option.id {
                                    Image(systemName: "checkmark")
                                        .foregroundColor(.blue)
                                }
                            }
                            .frame(height: 60)
                            .padding(.horizontal, 12)
                            .contentShape(Rectangle())
                            .onTapGesture {
                                selectedOption = option
                                saveSelectedOption(option)
                                updateSelectedTips()
                                
                                // 如果选择的是非自定义选项，清空自定义输入
                                if !option.isCustom {
                                    customPrompt = ""
                                    saveCustomPrompt("")
                                }
                            }
                            
                            // 如果是自定义选项且被选中，显示输入框
                            if option.isCustom && selectedOption?.id == option.id {
                                customPromptField
                            }
                            
                            // 分隔线
                            if option.id != TipOption.presetOptions.last?.id {
                                Divider()
                                    .background(Color(hex: "#F6F6F6"))
                                    .padding(.horizontal, 10)
                            }
                        }
                        .listRowInsets(EdgeInsets())
                        .listRowSeparator(.hidden)
                    }
                }
            }
            .navigationTitle("提示词".localized())
            .navigationBarTitleDisplayMode(.inline)
            .listStyle(.insetGrouped)
            .background(NavigationGestureRestorer())
            .scrollContentBackground(.hidden)
            .background(backgroundColor)
            
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    backButton
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    doneButton
                }
            }
            .navigationBarBackButtonHidden(true)
        }
        .onAppear {
            loadSavedData()
            updateSelectedTips()
        }
        .onDisappear {
            onDismiss?(getSelectedTipsString())
        }
        .alert("恢复默认设置".localized(), isPresented: $showResetAlert) {
            Button("取消".localized(), role: .cancel) { }
            Button("恢复".localized(), role: .destructive) {
                resetToDefault()
            }
        } message: {
            Text("这将清除所有自定义内容并恢复为默认设置，此操作不可撤销。".localized())
        }
    }
    
    // MARK: - 计算属性
    
    private var backgroundColor: Color {
        Color(themeManager.getCurrentColorScheme() == .dark ? .black : .init(hex: "#F9F9F9"))
    }
    
    // 检查是否有自定义内容
    private var hasCustomContent: Bool {
        !customPrompt.isEmpty || customOptionName != "自定义".localized() || selectedOption?.id == TipOption.custom.id
    }
    
    private var customPromptField: some View {
        VStack(alignment: .leading, spacing: 8) {
            TextEditor(text: $customPrompt)
                .frame(minHeight: 120)
                .padding(8)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.gray.opacity(0.05))
                )
                .onChange(of: customPrompt) { newValue in
                    saveCustomPrompt(newValue)
                    updateSelectedTips()
                }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
    }
    
    private var backButton: some View {
        Button(action: {
            presentationMode.wrappedValue.dismiss()
        }) {
            HStack {
                Image(systemName: "chevron.left")
                    .foregroundColor(Color(ThemeManager.shared.getCurrentColorScheme() == .dark ? .white : .init(hex: "#000")))
            }
        }
    }
    
    private var doneButton: some View {
        Button("完成".localized()) {
            onDismiss?(getSelectedTipsString())
            presentationMode.wrappedValue.dismiss()
        }
    }
    
    // MARK: - 公共方法
    
    /// 获取当前选中的提示词字符串
    func getSelectedTipsString() -> String {
        guard let selectedOption = selectedOption else {
            return TipOption.empty.prompt
        }
        
        // 修复：当选择自定义选项时，始终使用 customPrompt
        if selectedOption.isCustom {
            return customPrompt.isEmpty ? TipOption.empty.prompt : customPrompt
        } else {
            return selectedOption.resolvedPrompt
        }
    }
    
    /// 获取选中的选项详细信息
    func getSelectedTipsInfo() -> (option: TipOption, content: String) {
        guard let selectedOption = selectedOption else {
            return (TipOption.empty, TipOption.empty.prompt)
        }
        
        let content: String
        if selectedOption.isCustom {
            content = customPrompt.isEmpty ? TipOption.empty.prompt : customPrompt
        } else {
            content = selectedOption.resolvedPrompt
        }
        
        // 如果是自定义选项，返回更新名称后的选项
        let finalOption = selectedOption.isCustom ?
            TipOption(id: selectedOption.id, name: customOptionName, prompt: content, isCustom: true) :
            selectedOption
        
        return (finalOption, content)
    }
    
    /// 静态方法：直接从 UserDefaults 获取保存的提示词
    static func getSavedTipsString() -> String {
        guard let savedData = UserDefaults.standard.data(forKey: "TipsSettingSelectedOption"),
              let savedOption = try? JSONDecoder().decode(TipOption.self, from: savedData) else {
            return TipOption.empty.prompt
        }
        
        let customPrompt = UserDefaults.standard.string(forKey: "TipsSettingCustomPrompt") ?? ""
        
        // 修复：当保存的是自定义选项时，始终使用保存的 customPrompt
        if savedOption.isCustom {
            return customPrompt.isEmpty ? TipOption.empty.prompt : customPrompt
        } else {
            return savedOption.resolvedPrompt
        }
    }
    
    /// 静态方法：获取保存的提示词选项
    static func getSavedTipsOption() -> TipOption {
        guard let savedData = UserDefaults.standard.data(forKey: "TipsSettingSelectedOption"),
              let savedOption = try? JSONDecoder().decode(TipOption.self, from: savedData) else {
            return TipOption.empty
        }
        
        // 如果是自定义选项，需要加载保存的自定义名称和提示词
        if savedOption.isCustom {
            let customName = UserDefaults.standard.string(forKey: "TipsSettingCustomOptionName") ?? "自定义".localized()
            let customPrompt = UserDefaults.standard.string(forKey: "TipsSettingCustomPrompt") ?? ""
            return TipOption(id: savedOption.id, name: customName, prompt: customPrompt, isCustom: true)
        }
        
        return savedOption
    }
    
    // MARK: - 重置和清除方法
    
    //MARK:  清除自定义内容
    private func clearCustomContent() {
        customPrompt = ""
        customOptionName = "自定义".localized()
        
        // 如果当前选中的是自定义选项，切换到空选项
        if selectedOption?.id == TipOption.custom.id {
            selectedOption = TipOption.empty
            saveSelectedOption(TipOption.empty)
        }
        
        saveCustomPrompt("")
        saveCustomOptionName("自定义".localized())
        updateSelectedTips()
    }
    
    //MARK:  恢复默认设置
    private func resetToDefault() {
        // 清除所有保存的数据
        Self.clearSavedData()
        
        // 重置所有状态
        selectedOption = TipOption.empty
        customPrompt = ""
        customOptionName = "自定义".localized()
        
        updateSelectedTips()
    }
    
    // MARK: - 私有方法
    
    private func saveSelectedOption(_ option: TipOption) {
        if let encoded = try? JSONEncoder().encode(option) {
            UserDefaults.standard.set(encoded, forKey: selectedOptionKey)
        }
    }
    
    private func saveCustomPrompt(_ prompt: String) {
        UserDefaults.standard.set(prompt, forKey: customPromptKey)
    }
    
    private func saveCustomOptionName(_ name: String) {
        UserDefaults.standard.set(name, forKey: customOptionNameKey)
    }
    
    private func loadSavedData() {
        // 加载选中的选项
        if let savedData = UserDefaults.standard.data(forKey: selectedOptionKey),
           let savedOption = try? JSONDecoder().decode(TipOption.self, from: savedData) {
            selectedOption = savedOption
        } else {
            selectedOption = TipOption.empty // 默认选择"空"
        }
        
        // 加载自定义提示词
        if let savedPrompt = UserDefaults.standard.string(forKey: customPromptKey) {
            customPrompt = savedPrompt
        }
        
        // 加载自定义选项名称
        if let savedName = UserDefaults.standard.string(forKey: customOptionNameKey) {
            customOptionName = savedName
        }
    }
    
    private func updateSelectedTips() {
        selectedTips = getSelectedTipsString()
    }
    
    /// 静态方法：清空保存的数据
    static func clearSavedData() {
        UserDefaults.standard.removeObject(forKey: "TipsSettingSelectedOption")
        UserDefaults.standard.removeObject(forKey: "TipsSettingCustomPrompt")
        UserDefaults.standard.removeObject(forKey: "TipsSettingCustomOptionName")
    }
    
    /// 静态方法：保存自定义提示词
    static func saveCustomPrompt(_ prompt: String, name: String? = nil) {
        UserDefaults.standard.set(prompt, forKey: "TipsSettingCustomPrompt")
        if let name = name {
            UserDefaults.standard.set(name, forKey: "TipsSettingCustomOptionName")
        }
        
        // 同时设置为当前选中的选项
        let customOption = TipOption.custom
        if let encoded = try? JSONEncoder().encode(customOption) {
            UserDefaults.standard.set(encoded, forKey: "TipsSettingSelectedOption")
        }
    }
    
    /// 静态方法：检查是否有自定义内容
    static func hasCustomContent() -> Bool {
        let customPrompt = UserDefaults.standard.string(forKey: "TipsSettingCustomPrompt") ?? ""
        let customName = UserDefaults.standard.string(forKey: "TipsSettingCustomOptionName") ?? "自定义".localized()
        
        return !customPrompt.isEmpty || customName != "自定义".localized()
    }
    
    /// 静态方法：清除自定义内容
    static func clearCustomContent() {
        UserDefaults.standard.removeObject(forKey: "TipsSettingCustomPrompt")
        UserDefaults.standard.removeObject(forKey: "TipsSettingCustomOptionName")
        
        // 如果当前选中的是自定义选项，切换到空选项
        if let savedData = UserDefaults.standard.data(forKey: "TipsSettingSelectedOption"),
           let savedOption = try? JSONDecoder().decode(TipOption.self, from: savedData),
           savedOption.id == TipOption.custom.id {
            let emptyOption = TipOption.empty
            if let encoded = try? JSONEncoder().encode(emptyOption) {
                UserDefaults.standard.set(encoded, forKey: "TipsSettingSelectedOption")
            }
        }
    }
}
