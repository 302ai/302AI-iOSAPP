//
//  BottomSheetLanguagePicker.swift
//  Chat302AI
//
//  Created by Adswave on 2025/8/7.
//

import SwiftUI

 


// 语言选择器视图
struct BottomSheetLanguagePicker: View {
    @Binding var isPresented: Bool
    @ObservedObject var languageManager = LanguageManager.shared
    var onLanguageSelected: ((String) -> Void)? // 选择回调
    
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
                    Text("选择语言".localized())
                        .font(.headline)
                        .padding(.vertical, 16)
                        .frame(maxWidth: .infinity)
                    
                    // 语言选项
                    ForEach(languageManager.availableLanguages(), id: \.self) { language in
                        Button(action: {
                            withAnimation {
                                languageManager.setLanguage(language)
                                isPresented = false
                                onLanguageSelected?(language)
                            }
                        }) {
                            HStack {
                                Text(languageManager.displayName(for: language))
                                    .font(.body)
                                
                                Spacer()
                                
                                if languageManager.currentLanguage == language {
                                    Image(systemName: "checkmark")
                                        .foregroundColor(.accentColor)
                                }
                            }
                            .frame(height: 30)
                            .padding(.vertical, 12)
                            .contentShape(Rectangle())
                        }
                        .buttonStyle(PlainButtonStyle())
                        
                        if language != languageManager.availableLanguages().last {
                            Divider()
                        }
                    }
                    
                    // 取消按钮
                    Divider()
                        .padding(.top, 5)
                    
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


extension View {
    
    //语言选择
    func bottomSheetLanguagePicker(
        isPresented: Binding<Bool>,
        onLanguageSelected: ((String) -> Void)? = nil
    ) -> some View {
        self.overlay(
            BottomSheetLanguagePicker(
                isPresented: isPresented,
                onLanguageSelected: onLanguageSelected
            )
        )
        //.ignoresSafeArea()  //输入框  会被覆盖
    }
}




