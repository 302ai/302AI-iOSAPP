//
//  PreferenceSet.swift
//  Chat302AI
//
//  Created by Adswave on 2025/8/26.
//

import SwiftUI
import Toasts
import AlertToast



struct PreferenceSet: View {
    
    @Environment(\.presentationMode) var presentationMode
    @State private var isShowingChatModelList = false
    @State private var isShowingTitleModelList = false
    @State private var showSearchPicker = false //搜索服务商
    
    @EnvironmentObject var config: AppConfiguration
    @Environment(\.presentToast) var presentToast
    
    @State private var showAlertTitleGenerated = false  //标题生成弹框
    
        
    var body: some View{
        
        //NavigationView{
        VStack {
            List {
                Section {
                    VStack {
                        Button(action: {
                            print("会话模型设置")
                            isShowingChatModelList = true
                        }) {
                            SettingRow(title: "默认聊天模型".localized(), value: config.chatModel, action: { })
                                .frame(height: 40)
                                .contentShape(Rectangle())
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                    .frame(minHeight: 45)
                }
                header: {
                    EmptyView() // 移除默认的 header 占位
                }
                
                
                Section {
                    VStack {
                        Button(action: {
                            showAlertTitleGenerated = true
                        }) {
                            SettingRow(title: "标题生成".localized(), value: config.titleGenerated == "first" ? "第一次会话".localized() : "每一次会话".localized(), action: {})
                                .frame(height: 40)
                                .contentShape(Rectangle())
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                    .frame(minHeight: 45)
                }
                
                Section {
                    VStack {
                        Button(action: {
                            print("标题模型设置")
                            isShowingTitleModelList = true
                        }) {
                            SettingRow(title: "标题生成模型".localized(), value: config.titleModel, action: { })
                                .frame(height: 40)
                                .contentShape(Rectangle())
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                    .frame(minHeight: 45)
                }
                
                Section {
                    VStack {
                        Toggle(isOn: $config.autoScrollToBottom) {
                            CustomText("自动滚动底部".localized())
                        }
                        .toggleStyle(SwitchToggleStyle(tint: .purple))
                    }
                }
                .frame(minHeight: 45)
                
                Section {
                    VStack {
                        Toggle(isOn: $config.autoTracelessSession) {
                            CustomText("默认使用无痕会话".localized())
                        }
                        .toggleStyle(SwitchToggleStyle(tint: .purple))
                    }
                    .frame(minHeight: 45)
                }
                
                Section {
                    VStack {
                        Button(action: {
                            print("默认搜索服务")
                            showSearchPicker = true
                        }) {
                            SettingRow(title: "默认搜索服务".localized(), value: config.currentSearchType.rawValue, action: { })
                                .frame(height: 40)
                                .contentShape(Rectangle())
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                    .frame(minHeight: 45)
                }
            }
            .listSectionSpacing(12) // 设置 Section 上下间距为 10
            .scrollContentBackground(.hidden)
            .background(Color(ThemeManager.shared.getCurrentColorScheme() == .dark ? .black : .init(hex: "#F9F9F9")))
        }
            .listStyle(.insetGrouped)
            .background(NavigationGestureRestorer()) //返回手势
        
            .navigationTitle("偏好设置".localized())
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
        
        
        
        
        .alert("", isPresented: $showAlertTitleGenerated) {
            Button("第一次会话".localized()) {
                config.titleGenerated = "first"
            }
            Button("每一次会话".localized()) {
                config.titleGenerated = "every"
            }
            
            Button("取消".localized(), role: .cancel) {}
        } message: {
            Text("选择标题生成的时机".localized())
        }
         
        
        .sheet(isPresented: $isShowingChatModelList) {
            ModelListView(selectedModel: $config.chatModel)
        }
         
        .sheet(isPresented: $isShowingTitleModelList) {
            ModelListView(selectedModel: $config.titleModel)
        }
        
        // 显示选择器
        .bottomSheetSearchTypePicker(isPresented: $showSearchPicker) { type in
            print("选择了: \(type.description)")
            AppConfiguration.shared.currentSearchType = type
        }
        
    }
    
    
     
}

#Preview {
    PreferenceSet()
}
