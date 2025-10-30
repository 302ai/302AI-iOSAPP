//
//  MessageSetting.swift
//  Chat302AI
//
//  Created by Adswave on 2025/8/1.
//

import SwiftUI
import Toasts




struct MessageSetting: View {
    
    
    @State private var isShowingModelList = false
    @State private var isShowTipsList = false
    
    @State private var selectedTips = TipsSettingView.getSavedTipsString()
    
    @EnvironmentObject private var themeManager: ThemeManager
    @EnvironmentObject var config: AppConfiguration

    @Environment(\.dismiss) var dismiss
    @Environment(\.presentToast) var presentToast
    
    @Bindable var session: DialogueSession
    private var snapshotBtnTap: (Bool) -> Void?
    
    init(session: DialogueSession, snapshotBtnTap: @escaping (Bool) -> Void) {
            self.session = session
            self.snapshotBtnTap = snapshotBtnTap
        }
    
        var body: some View {
            
            NavigationView{
                VStack{
                    List {
                        
                        Section("会话标题".localized()) {
                            LimitedTextField(text: $session.title)
                                .frame(height: 40)
                                
                        }
                        
                        Section("参数设置".localized()) {
                            VStack{
                                Button(action: {
                                    print("点击了模型设置")
                                    
                                    isShowingModelList = true
                                    
                                    
                                }) {
                                    SettingRow(title: "模型".localized(), value: session.configuration.model, action: { })
                                        .frame(height: 40)
                                        .contentShape(Rectangle())  // 确保整个区域都可点击
                                }
                                .buttonStyle(PlainButtonStyle())
                                /*
                                Divider()
                                    .background(Color.init(hex: "#F6F6F6"))
                                
                                Button(action: {
                                    
                                    let toast = ToastValue(message: "知识库开发中")
                                    presentToast(toast)
                                    
                                }) {
                                    SettingRow(title: "知识库".localized(), value: "知识库".localized(), action: {})
                                        .frame(height: 40)
                                        .contentShape(Rectangle())  // 确保整个区域都可点击
                                }
                                .buttonStyle(PlainButtonStyle())
                                 */
                            }
                        }
                        
                        Section("系统提示词".localized()) {
                            SettingRow(title: "设置系统提示词".localized(), value: TipsSettingView.getSavedTipsOption().name.localized()) {
                                
                                isShowTipsList = true
                                
                            }.frame(height: 40)
                            
                            
                            
                        }
                        
                        
                        Section("随机性".localized()) {
                            VStack(spacing: 8) {
                                
                                Slider(value: $session.configuration.temperature , in:0.5...2)
                                    .tint(Color.init(hex: "#8E47F1"))
                                /*.overlay(
                                 GeometryReader { proxy in
                                 Circle()
                                 .fill(Color.init(hex: "#8E47F1")) // 滑块颜色
                                 .frame(width: 24, height: 24)
                                 
                                 .overlay(
                                 Circle()
                                 .stroke(.white, lineWidth: 3) // 滑块边框
                                 )
                                 .offset(x: (proxy.size.width - 24) * CGFloat(session.configuration.temperature), y:3)
                                 }
                                 )*/
                                
                                
                                HStack {
                                    Text("更准确".localized())
                                        .font(.footnote)
                                        .foregroundColor(.primary)
                                    Spacer()
                                    Text("更创意".localized())
                                        .font(.footnote)
                                        .foregroundColor(.primary)
                                }
                            }
                            .frame(height: 54)
                            .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                        }
                        
                        Section(header: CustomText("分享".localized())) {
                            VStack{
//                                Button(action: {
//                                    print("点击了链接分享")
//                                    
//                                    let toast = ToastValue(message: "链接分享 开发中")
//                                    presentToast(toast)
//                                    
//                                }) {
//                                    HStack {
//                                        Text("链接分享".localized())
//                                            .foregroundColor(Color.primary)
//                                        Spacer()
//                                        Image(systemName: "chevron.right")
//                                            .foregroundColor(Color(.systemGray3))
//                                    }
//                                    .contentShape(Rectangle()) // 确保整个HStack区域都可点击
//                                    .frame(height: 40)
//                                }
//                                .buttonStyle(PlainButtonStyle()) // 保持列表样式
//                                
//                                Divider()
//                                    .background(Color.init(hex: "#F6F6F6"))
                                
                                Button(action: {
                                    print("点击了生成截图")
                                    
                                    snapshotBtnTap(true)
                                    dismiss()
                                    
                                    
                                }) {
                                    HStack {
                                        Text("生成截图".localized())
                                            .foregroundColor(Color.primary)
                                        Spacer()
                                        Image(systemName: "chevron.right")
                                            .foregroundColor(Color(.systemGray3))
                                    }
                                    .contentShape(Rectangle()) // 确保整个HStack区域都可点击
                                    .frame(height: 40)
                                }
                                .buttonStyle(PlainButtonStyle()) // 保持列表样式
                            }
                            
                        }
                        
                    }
                    .listStyle(.insetGrouped)
                    .background(NavigationGestureRestorer()) //返回手势
                    .scrollContentBackground(.hidden) // 隐藏默认背景
                    .background(Color(ThemeManager.shared.getCurrentColorScheme() == .dark ? .black : .init(hex: "#F9F9F9"))) // 设置主题背景色
                    
                    
                    NavigationLink(
                        destination: TipsSettingView(selectedTips: $selectedTips),
                        isActive: $isShowTipsList,
                        label: { EmptyView() }
                    )
                    .hidden()
                }
            }
                
            .sheet(isPresented: $isShowingModelList) {
                ModelListView(selectedModel: $session.configuration.model)
            }
             
             
            
            
        }
    }

struct LimitedTextField: View {
    
    
    @Binding var text : String
    private let maxLength = 20
    
    var body: some View {
        ZStack(alignment: .trailing) {
            TextField("新的聊天".localized(), text: $text)
                .padding(.trailing, 55) // 为字数显示留出空间
                .onChange(of: text) { newValue in
                    if newValue.count > maxLength {
                        text = String(newValue.prefix(maxLength))
                    }
                }
            
            Text("\(text.count)/\(maxLength)")
                .foregroundColor(text.count == maxLength ? .red : .gray)
                .padding(.trailing, 1)
        }
        .frame(height: 40)
        .padding(.horizontal,5)
        .padding(.vertical,0)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .stroke(.background, lineWidth: 1)
        )
    }
}


struct SettingRow: View {
    let title: String
    let value: String
    let action: () -> Void
    var showRedBackground: Bool = false
    var showChevron: Bool = true // 新增属性，控制是否显示右侧箭头
    
    var body: some View {
        Button(action: action) {
            HStack {
                Text(title)
                Spacer()
                HStack(spacing: 4) {
                    Text(value)
                        .foregroundColor(showRedBackground ? Color.white : Color(.systemGray))
                        .padding(.horizontal, 8)
                        .frame(height: 20) // 高度20
                        .background(
                            RoundedRectangle(cornerRadius: 10) // 圆角10
                                .fill(showRedBackground ? Color.red : Color.clear)
                        )
                    
                    // 根据 showChevron 属性决定是否显示箭头
                    if showChevron {
                        Image(systemName: "chevron.right")
                            .foregroundColor(Color(.systemGray3))
                    }
                }
            }
        }
        .foregroundColor(.primary)
    }
}
