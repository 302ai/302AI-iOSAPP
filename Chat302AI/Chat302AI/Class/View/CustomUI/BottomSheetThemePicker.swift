//
//  SomePickerView.swift
//  Chat302AI
//
//  Created by Adswave on 2025/8/7.
//

import SwiftUI


struct BottomSheetThemePicker: View {
    @Binding var isPresented: Bool
    @ObservedObject var themeManager = ThemeManager.shared
    var onThemeSelected: ((ThemeMode) -> Void)? // 新增回调闭包
    
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
                    // 标题
                    Text("选择主题".localized())
                        .font(.headline)
                        .padding(.vertical, 16)
                        .frame(maxWidth: .infinity)
                    
                    // 主题选项
                    ForEach(ThemeMode.allCases, id: \.self) { theme in
                        Button(action: {
                            withAnimation {
                                themeManager.themeMode = theme
                                isPresented = false
                                onThemeSelected?(theme) // 调用回调
                            }
                        }) {
                            HStack {
                                Image(systemName: theme.iconName)
                                    .frame(width: 24)
                                
                                Text(theme.description)
                                    .font(.body)
                                
                                Spacer()
                                
                                if themeManager.themeMode == theme {
                                    Image(systemName: "checkmark")
                                        .foregroundColor(.accentColor)
                                }
                            }
                            .padding(.vertical, 12)
                            .contentShape(Rectangle())
                        }
                        .buttonStyle(PlainButtonStyle())
                        
                        if theme != ThemeMode.allCases.last {
                            Divider()
                        }
                    }
                    
                    // 取消按钮
                    Divider()
                        .padding(.top, 8)
                    
                    Button(action: {
                        withAnimation {
                            isPresented = false
                        }
                    }) {
                        Text("取消".localized())
                            .font(.body.weight(.semibold))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .contentShape(Rectangle())
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                .padding(.horizontal)
                .background(Color(.systemBackground))
                .cornerRadius(16)
                .padding(.horizontal, 8)
                .padding(.bottom, 8)
                .shadow(radius: 10)
                .transition(.move(edge: .bottom))
                .zIndex(1)
            }
        }
        //.animation(.spring(response: 0.3, dampingFraction: 0.7), value: isPresented)
        .animation(.easeInOut(duration: 0.25), value: isPresented)
    }
}




