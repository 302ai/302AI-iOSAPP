//
//  ThemeManager.swift
//  Chat302AI
//
//  Created by Adswave on 2025/7/30.
//

import SwiftUI




// 主题模式枚举
enum ThemeMode: Int, CaseIterable {
    
    case light = 0
    case dark = 1
    case system = 2
    
    var description: String {
        switch self {
        case .system: return "跟随系统".localized()
        case .light: return "浅色模式".localized()
        case .dark: return "深色模式".localized()
        }
    }
    
    
    var iconName: String {
            switch self {
            case .light: return "sun.max"
            case .dark: return "moon"
            case .system: return "gearshape"
            }
        }
}

// 主题管理工具类
class ThemeManager: ObservableObject {
    // 单例实例
    static let shared = ThemeManager()
    
    // 当前主题模式
    @Published var themeMode: ThemeMode = .system {
        didSet {
            saveThemeMode()
            applyTheme()
        }
    }
    
    // 当前颜色方案（由系统或手动设置决定）
    @Published var colorScheme: ColorScheme? = nil
    
    // 私有初始化方法
    private init() {
        loadThemeMode()
    }
    
    // 加载保存的主题模式
    private func loadThemeMode() {
        let rawValue = UserDefaults.standard.integer(forKey: "themeMode")
        themeMode = ThemeMode(rawValue: rawValue) ?? .system
        applyTheme()
    }
    
    // 保存主题模式
    private func saveThemeMode() {
        UserDefaults.standard.set(themeMode.rawValue, forKey: "themeMode")
    }
    
    // 应用主题
    private func applyTheme() {
        print("Applying theme: \(themeMode)")  // 调试
        switch themeMode {
        case .system:
            colorScheme = nil // nil 表示跟随系统
        case .light:
            colorScheme = .light
        case .dark:
            colorScheme = .dark
        }
    }
    
    // 切换主题模式
    func toggleTheme() {
        switch themeMode {
        case .system:
            themeMode = .light
        case .light:
            themeMode = .dark
        case .dark:
            themeMode = .system
        }
    }
    
    // 获取当前实际的颜色方案（考虑系统设置）
    func getCurrentColorScheme() -> ColorScheme {
        if let colorScheme = colorScheme {
            return colorScheme
        }
        
        // 如果没有手动设置，则返回系统当前的颜色方案
        return UITraitCollection.current.userInterfaceStyle == .dark ? .dark : .light
    }
    
    
    // 新增方法：获取所有可用的主题模式
       func getAllThemes() -> [ThemeMode] {
           return ThemeMode.allCases
       }
       
       // 可选：获取包含描述的可用主题数组
       func getAllThemesWithDescription() -> [(mode: ThemeMode, description: String)] {
           return ThemeMode.allCases.map { ($0, $0.description) }
       }
}


extension Color {
    static func adaptiveColor(light: Color, dark: Color) -> Color {
        let themeManager = ThemeManager.shared
        if themeManager.getCurrentColorScheme() == .dark {
            return dark
        } else {
            return light
        }
    }
}
