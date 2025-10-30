//
//  AgreementView.swift
//  Chat302AI
//
//  Created by Adswave on 2025/8/28.
//

import SwiftUI

 
struct AgreementView: View {
    
    @State var showTerms = false
    @State var showPrivacy = false
    
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        VStack {
            List {
                Section {
                    
                     
                    Button(action: {
                        showTerms = true
                    }) {
                        HStack {
                            CustomText("使用条款".localized())
                            Spacer()
                            Image(systemName: "chevron.right")
                                .resizable()
                                .frame(width: 8, height: 14)
                                .foregroundColor(.gray)
                        }
                        .frame(height: 40)
                        .contentShape(Rectangle()) // 确保整个区域可点击
                    }
                    .buttonStyle(.plain) // 防止 List 的点击冲突
                    
//                    HStack {
//                        CustomText("使用条款".localized())
//                        Spacer()
//                        
//                        Button(action: {
//                            //https://302.ai/legal/terms/
//                            
//                            showTerms = true
//                        }) {
//                            Image(systemName: "chevron.right")
//                                .resizable()
//                                .frame(width: 8,height: 14)
//                                .foregroundColor(.gray)
//                        }
//                        .buttonStyle(.plain) // 防止 List 的点击冲突
//                        .contentShape(Rectangle()) // 确保整个区域可点击
//                        .padding(4)
//                        
//                    }.frame(height: 40)
                    
                     
                }
                
                
                
                Section {
                    
                    
                    
                    Button(action: {
                        showPrivacy = true
                    }) {
                        HStack {
                            CustomText("隐私协议".localized())
                            Spacer()
                            Image(systemName: "chevron.right")
                                .resizable()
                                .frame(width: 8, height: 14)
                                .foregroundColor(.gray)
                        }
                        .frame(height: 40)
                        .contentShape(Rectangle()) // 确保整个区域可点击
                    }
                    .buttonStyle(.plain) // 防止 List 的点击冲突
                    
//                    HStack {
//                        CustomText("隐私协议".localized())
//                        Spacer()
//                        
//                        Button(action: {
//                            
//                            showPrivacy = true
//                        }) {
//                            Image(systemName: "chevron.right")
//                                .resizable()
//                                .frame(width: 8,height: 14)
//                                .foregroundColor(.gray)
//                        }
//                        .buttonStyle(.plain) // 防止 List 的点击冲突
//                        .contentShape(Rectangle()) // 确保整个区域可点击
//                        .padding(4)
//                        
//                    }.frame(height: 40)
                     
                    
                    
                }
            }
            
            
        }
        .listStyle(.insetGrouped)
        //.background(NavigationGestureRestorer()) //返回手势
        .highPriorityGesture(DragGesture()) 
        .navigationTitle("服务协议".localized())
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
        }
        
        .navigationBarBackButtonHidden(true)
        
         
        
        .sheet(isPresented: $showPrivacy) {
            //"en", "zh-Hans", "ja"
            if LanguageManager.shared.currentLanguage == "en" {
                LocalWebView(htmlFileName: "隐私政策(en)")
            }
            else if LanguageManager.shared.currentLanguage == "ja" {
                LocalWebView(htmlFileName: "隐私政策(jp)")
            }else{
                LocalWebView(htmlFileName: "隐私政策")
            }
                    
        }
        .sheet(isPresented: $showTerms) {
            
                
            if LanguageManager.shared.currentLanguage == "en" {
                LocalWebView(htmlFileName: "使用条款(en)")
            }
            else if LanguageManager.shared.currentLanguage == "ja" {
                LocalWebView(htmlFileName: "使用条款(jp)")
            }else{
                LocalWebView(htmlFileName: "使用条款")
            }
        }
         
        
    }
    
}






