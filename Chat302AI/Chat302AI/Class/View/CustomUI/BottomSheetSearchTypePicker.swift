//
//  BottomSheetSearchTypePicker.swift
//  Chat302AI
//
//  Created by Adswave on 2025/8/26.
//

import SwiftUI

// 搜索类型枚举
enum SearchEngineType: String, CaseIterable {
    case jina = "jina"
    case search1api = "search1api"
    case tavily = "tavily"
    case exa = "exa"
    case bochaai = "bochaai"
    
    var description: String {
        switch self {
        case .jina: return "Jina Search"
        case .search1api: return "Search1API"
        case .tavily: return "Tavily"
        case .exa: return "Exa"
        case .bochaai: return "BochaAI"
        }
    }
    
    // 默认类型
    static var `default`: SearchEngineType {
        return .jina
    }
    
    // 从字符串初始化
    init?(rawValue: String) {
        switch rawValue {
        case "jina": self = .jina
        case "search1api": self = .search1api
        case "tavily": self = .tavily
        case "exa": self = .exa
        case "bochaai": self = .bochaai
        default: return nil
        }
    }
}






struct BottomSheetSearchTypePicker: View {
    @Binding var isPresented: Bool
    @ObservedObject var config = AppConfiguration.shared
    var onTypeSelected: ((SearchEngineType) -> Void)?
    
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
                        Text("选择搜索引擎".localized())
                            .font(.headline)
                            .padding(.vertical, 16)
                    }
                    .frame(maxWidth: .infinity)
                    
                    // 搜索类型选项
                    ForEach(SearchEngineType.allCases, id: \.self) { type in
                        Button(action: {
                            withAnimation {
                                isPresented = false
                                config.currentSearchType = type
                                onTypeSelected?(type)
                            }
                        }) {
                            HStack {
                                Text(type.description)
                                    .font(.body)
                                
                                Spacer()
                                
                                // 显示选中标记
                                if config.currentSearchType == type {
                                    Image(systemName: "checkmark")
                                        .foregroundColor(.blue)
                                }
                            }
                            .padding(.vertical, 16)
                            .padding(.horizontal, 16)
                            .background(Color(.systemBackground))
                            //.cornerRadius(10)
                            //.contentShape(Rectangle())
                        }
                        .buttonStyle(PlainButtonStyle())
                        .padding(.horizontal, 8)
                        
                        
                        // 添加分割线（最后一个选项不添加）
                        if type != SearchEngineType.allCases.last {
                            Divider()
                                .background(Color.init(hex: "#FaFaFa"))
                                .padding(.horizontal, 16)
                        }
                    }
                    
                    // 底部间距
                    VStack{}
                        .frame(height: 10)
                    
                }
                .padding(.horizontal)
                .background(Color(ThemeManager.shared.getCurrentColorScheme() == .dark ? .black : .init(hex: "#F6F6F6")))
                .cornerRadius(16)
                .padding(.horizontal, 8)
                .padding(.bottom, 8)
                .shadow(radius: 10)
                .transition(.move(edge: .bottom))
                .zIndex(1)
            }
        }
        .animation(.easeInOut(duration: 0.25), value: isPresented)
    }
}
