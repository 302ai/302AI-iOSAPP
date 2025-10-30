import SwiftUI
import AlertToast

class FunctionManager: ObservableObject {
    static let shared = FunctionManager()
    
    private let functionsKey = "selectedFunctions"
    
    @Published var selectedFunctions: Set<String> {
        didSet {
            let array = Array(selectedFunctions)
            UserDefaults.standard.set(array, forKey: functionsKey)
        }
    }
    
    // 当前选中功能的描述
    var selectedFunctionsDescription: String {
        if selectedFunctions.isEmpty {
            return "未选择功能"
        }
        return selectedFunctions.map { displayName(for: $0) }.joined(separator: "、")
    }
    
    private init() {
        if let savedFunctions = UserDefaults.standard.array(forKey: functionsKey) as? [String] {
            selectedFunctions = Set(savedFunctions)
        } else {
            selectedFunctions = [] // 默认选中"联网搜索"
            UserDefaults.standard.set(Array(selectedFunctions), forKey: functionsKey)
        }
    }
    
    func toggleFunction(_ function: String) {
        if selectedFunctions.contains(function) {
            selectedFunctions.remove(function)
        } else {
            selectedFunctions.insert(function)
        }
    }
    
    func isFunctionSelected(_ function: String) -> Bool {
        return selectedFunctions.contains(function)
    }
    
    func availableFunctions() -> [String] {
        //return ["search", "think", "mcp1"] // "deep",
        return ["search", "think"]
    }
    
    func displayName(for functionCode: String) -> String {
        switch functionCode {
        case "search": return "联网搜索".localized()
        case "deep": return "深度思考".localized()
        case "think": return "思考模式".localized()
        case "mcp1": return "MCP1"
        default: return functionCode
        }
    }
}

struct BottomSheetFunctionPicker: View {
    @EnvironmentObject var config: AppConfiguration
    var session: DialogueSession
    @Binding var isPresented: Bool
    @ObservedObject var functionManager = FunctionManager.shared
    var onFunctionsSelected: ((Set<String>) -> Void)? // 多选回调
    
    @State private var isShowToast = false
    @State private var hintText = ""
    
    //判断模型是否自带思考模式
    var isModelContainsThinking: Bool {
        if session.configuration.model.contains("R1") || session.configuration.model.contains("-r1") || session.configuration.model.contains("reason") {
            return true
        } else {
            return false
        }
    }
    
    var body: some View {
        ZStack(alignment: .bottom) {
            // 半透明背景
            if isPresented {
                Color.black.opacity(0.4)
                    .edgesIgnoringSafeArea(.all)
                    .onTapGesture {
                        withAnimation {
                            isPresented = false
                        }
                    }
                    .transition(.opacity)
            }
            
            // Action Sheet 内容
            if isPresented {
                VStack(alignment: .leading, spacing: 0) {
                    ZStack {
                        // 背景层
                        HStack {
                            Spacer()
                            Button(action: { isPresented = false }) {
                                Image(systemName: "xmark")
                            }
                            .buttonStyle(PlainButtonStyle())
                            .padding(20)
                        }
                        
                        // 居中标题
                        Text("功能选择".localized()) // (多选)
                            .font(.headline)
                            .padding(.vertical, 16)
                    }
                    .frame(maxWidth: .infinity)
                    
                    // 功能选项列表
                    ForEach(functionManager.availableFunctions(), id: \.self) { function in
                        if function == "mcp1" {
                            // mcp1 保持原有的 Button 和 Image 样式
                            Button(action: {
                                handleMCP1Tap(function: function)
                            }) {
                                HStack {
                                    Image(systemName: getIconName(for: function))
                                        .frame(width: 24)
                                    
                                    Text(functionManager.displayName(for: function))
                                        .font(.body)
                                    
                                    Spacer()
                                    
                                    if functionManager.isFunctionSelected(function) {
                                        Image(systemName: "checkmark")
                                            .foregroundColor(.purple)
                                    }
                                }
                                .padding(.vertical, 12)
                                .padding(.horizontal, 16)
                                .background(Color(.systemBackground))
                                .cornerRadius(10)
                                .contentShape(Rectangle())
                            }
                            .buttonStyle(PlainButtonStyle())
                            .padding(8)
                        } else {
                            // search 和 think 使用 Toggle
                            HStack {
                                Image(systemName: getIconName(for: function))
                                    .frame(width: 24)
                                
                                if function == "think" {
                                    Text(functionManager.displayName(for: function))
                                        .font(.body)
                                        .foregroundColor(isModelContainsThinking ? .gray : Color(.label))
                                } else {
                                    Text(functionManager.displayName(for: function))
                                        .font(.body)
                                }
                                
                                Spacer()
                                
                                Toggle("", isOn: Binding(
                                    get: { functionManager.isFunctionSelected(function) },
                                    set: { newValue in
                                        handleToggleChange(function: function, isOn: newValue)
                                    }
                                ))
                                .toggleStyle(SwitchToggleStyle(tint: .purple))
                                .labelsHidden()
                                .disabled(shouldDisableToggle(for: function))
                            }
                            .padding(.vertical, 12)
                            .padding(.horizontal, 16)
                            .background(Color(.systemBackground))
                            .cornerRadius(10)
                            .contentShape(Rectangle())
                            .padding(8)
                        }
                    }
                    
                    VStack{}
                        .frame(height: 10)
                }
                .padding(.horizontal)
                .background(Color(ThemeManager.shared.getCurrentColorScheme() == .dark ? .black : .init(hex: "#F9F9F9")))
                .cornerRadius(16)
                .padding(.horizontal, 8)
                .padding(.bottom, 8)
                .shadow(radius: 10)
                .transition(.move(edge: .bottom))
                .zIndex(1)
            }
        }
        .animation(.easeInOut(duration: 0.25), value: isPresented)
        .toast(isPresenting: $isShowToast){
            AlertToast(displayMode: .alert, type: .regular, title: hintText)
        }
    }
    
    private func handleToggleChange(function: String, isOn: Bool) {
        withAnimation {
            if function == "think" && isModelContainsThinking {
                hintText = "模型已包含<思考模式>"
                isShowToast = true
                return
            }
            
            // 更新功能选择状态
            functionManager.toggleFunction(function)
            onFunctionsSelected?(functionManager.selectedFunctions)
            
            // 更新配置
            updateConfiguration(for: function, isSelected: isOn)
        }
    }
    
    private func handleMCP1Tap(function: String) {
        withAnimation {
            hintText = "MCP1(暂未开放)"
            isShowToast = true
        }
    }
    
    private func updateConfiguration(for function: String, isSelected: Bool) {
        switch function {
        case "think":
            config.isR1Fusion = isSelected
        case "search":
            config.isWebSearch = isSelected
        case "deep":
            config.isDeepSearch = isSelected
        default:
            break
        }
    }
    
    private func shouldDisableToggle(for function: String) -> Bool {
        if function == "think" && isModelContainsThinking {
            return true
        }
        
        return false
    }
    
    private func getIconName(for function: String) -> String {
        switch function {
        case "search": return "magnifyingglass"
        case "deep": return "brain.head.profile"
        case "think": return "lightbulb"
        case "mcp1": return "cpu"
        default: return "questionmark"
        }
    }
}

extension View {
    // 多选框版本的功能选择器
    func bottomSheetFunctionMultiPicker(
        session: DialogueSession,
        isPresented: Binding<Bool>,
        onFunctionsSelected: ((Set<String>) -> Void)? = nil
    ) -> some View {
        self.overlay(
            BottomSheetFunctionPicker(
                session: session,
                isPresented: isPresented,
                onFunctionsSelected: onFunctionsSelected
            )
        )
    }
}
