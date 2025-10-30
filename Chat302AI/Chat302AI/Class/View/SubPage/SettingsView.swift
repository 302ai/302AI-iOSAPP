import SwiftUI

struct SettingsView: View {
    
    
    @Environment(\.dismiss) var dismiss
    // 状态管理
    @ObservedObject var config = AppConfiguration.shared
      
    @EnvironmentObject var store: ApiItemStore
    @EnvironmentObject var dataManager : ApiDataManager
    @EnvironmentObject var fontSettings: FontSettings
    
    @EnvironmentObject private var themeManager: ThemeManager
    @State private var showingThemePicker = false
    
    @EnvironmentObject var languageManager: LanguageManager
    @State private var showingLanguagePicker = false
     
      
    // 添加拖拽手势状态
    @GestureState private var dragOffset = CGSize.zero
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        
        ZStack {
            
            NavigationStack {
                List {
                    // 第一组：账号信息
                    Section {
                        
                        VStack{
                            
                            HStack {
                                Image(systemName: "person.crop.circle")
                                    .frame(width: 40,height: 40)
                                Spacer()
                                
                                CustomText("用户名xxxx")
                                    .foregroundColor(.primary)
                            }
                            
                            Divider()
                            HStack {
                                CustomText("302.AI账号")
                                    .foregroundColor(.primary)
                                Spacer()
                                
                                CustomText("xxxxxx@email.com")
                                    .foregroundColor(.gray)
                                
                            }.frame(height: 40)
                        }
                        
                    }
                    
                    
                    // 第一组：余额信息
                    Section {
                        
                        VStack{
                            
                            HStack {
                                VStack{
                                    CustomText("余额")
                                        .foregroundColor(.primary)
                                    CustomText("???PTC")
                                        .foregroundColor(.primary)
                                }
                                Spacer()
                                
                                CustomText("充值")
                                    .frame(width:68,height: 34)
                                    .background(Color(hex: "#8E47F1"))
                                    .foregroundColor(.white)
                                    .cornerRadius(10)
                            }.frame(height: 66)
                            
                            Divider()
                            HStack {
                                CustomText("消耗明细")
                                    .foregroundColor(.primary)
                                Spacer()
                                
                                CustomText("???PTC")
                                    .foregroundColor(.gray)
                                
                            }.frame(height: 40)
                        }
                        
                    }
                    
                    
                    
                    Section(header: CustomText("通用")) {
                        
                        VStack{
                            HStack {
                                CustomText("语言".localized())
                                Spacer()
                                
                                Button(action: {
                                    showingLanguagePicker = true
                                }) {
                                    CustomText(languageManager.currentLanguageDescription)
                                        .foregroundColor(.blue)
                                }
                                .buttonStyle(.plain) // 防止 List 的点击冲突
                                .contentShape(Rectangle()) // 确保整个区域可点击
                                .padding(4)
                                Image(systemName: "chevron.right")
                                    .resizable()
                                    .frame(width: 8,height: 14)
                                    .foregroundColor(.gray)
                                
                            }.frame(height: 40)
                            
                            Divider()
                            HStack {
                                CustomText("主题")
                                Spacer()
                                
                                Button(action: {
                                    showingThemePicker = true
                                }) {
                                    CustomText(ThemeManager.shared.themeMode.description)
                                        .foregroundColor(.blue)
                                }
                                .buttonStyle(.plain) // 防止 List 的点击冲突
                                .contentShape(Rectangle()) // 确保整个区域可点击
                                .padding(4)
                                Image(systemName: "chevron.right")
                                    .resizable()
                                    .frame(width: 8,height: 14)
                                    .foregroundColor(.gray)
                                
                            }.frame(height: 40)
                            
                            Divider()
                            HStack {
                                CustomText("偏好设置")
                                Spacer()
                                
                                Button(action: {
                                    
                                }) {
                                    Image(systemName: "chevron.right")
                                        .resizable()
                                        .frame(width: 8,height: 14)
                                        .foregroundColor(.gray)
                                }
                                .buttonStyle(.plain) // 防止 List 的点击冲突
                                .contentShape(Rectangle()) // 确保整个区域可点击
                                .padding(0)
                                
                            }.frame(height: 40)
                        }
                        
                    }
                    
                    Section(header: CustomText("管理")) {
                        VStack{
                            
                            HStack {
                                CustomText("模型管理".localized())
                                Spacer()
                                
                                Button(action: {
                                    
                                }) {
                                    Image(systemName: "chevron.right")
                                        .resizable()
                                        .frame(width: 8,height: 14)
                                        .foregroundColor(.gray)
                                }
                                .buttonStyle(.plain) // 防止 List 的点击冲突
                                .contentShape(Rectangle()) // 确保整个区域可点击
                                .padding(4)
                                
                                
                            }.frame(height: 40)
                            Divider()
                                .background(Color.init(hex: "#F6F6F6"))
                            
                            HStack {
                                CustomText("MCP服务")
                                Spacer()
                                
                                Button(action: {
                                    
                                }) {
                                    Image(systemName: "chevron.right")
                                        .resizable()
                                        .frame(width: 8,height: 14)
                                        .foregroundColor(.gray)
                                }
                                .buttonStyle(.plain) // 防止 List 的点击冲突
                                .contentShape(Rectangle()) // 确保整个区域可点击
                                .padding(4)
                                
                                
                            }.frame(height: 40)
                            
                            
                            Divider()
                                .background(Color.init(hex: "#F6F6F6"))
                            HStack {
                                CustomText("档案库")
                                Spacer()
                                
                                Button(action: {
                                    
                                }) {
                                    Image(systemName: "chevron.right")
                                        .resizable()
                                        .frame(width: 8,height: 14)
                                        .foregroundColor(.gray)
                                }
                                .buttonStyle(.plain) // 防止 List 的点击冲突
                                .contentShape(Rectangle()) // 确保整个区域可点击
                                .padding(4)
                                
                                
                            }.frame(height: 40)
                            Divider()
                                .background(Color.init(hex: "#F6F6F6"))
                            HStack {
                                CustomText("知识库")
                                Spacer()
                                
                                Button(action: {
                                    
                                }) {
                                    Image(systemName: "chevron.right")
                                        .resizable()
                                        .frame(width: 8,height: 14)
                                        .foregroundColor(.gray)
                                }
                                .buttonStyle(.plain) // 防止 List 的点击冲突
                                .contentShape(Rectangle()) // 确保整个区域可点击
                                .padding(4)
                                
                                
                            }.frame(height: 40)
                        }
                        
                        
                    }
                    
                    
                    Section(header: CustomText("关于")) {
                        VStack{
                            HStack {
                                CustomText("公告".localized())
                                Spacer()
                                
                                Button(action: {
                                    
                                }) {
                                    Image(systemName: "chevron.right")
                                        .resizable()
                                        .frame(width: 8,height: 14)
                                        .foregroundColor(.gray)
                                }
                                .buttonStyle(.plain) // 防止 List 的点击冲突
                                .contentShape(Rectangle()) // 确保整个区域可点击
                                .padding(4)
                                
                                
                            }.frame(height: 40)
                            
                            Divider()
                                .background(Color.init(hex: "#F6F6F6"))
                            HStack {
                                CustomText("版本信息")
                                Spacer()
                                
                                Button(action: {
                                    
                                }) {
                                    Image(systemName: "chevron.right")
                                        .resizable()
                                        .frame(width: 8,height: 14)
                                        .foregroundColor(.gray)
                                }
                                .buttonStyle(.plain) // 防止 List 的点击冲突
                                .contentShape(Rectangle()) // 确保整个区域可点击
                                .padding(4)
                                
                                
                            }
                            .frame(height: 40)
                            Divider()
                                .background(Color.init(hex: "#F6F6F6"))
                            HStack {
                                CustomText("服务协议")
                                Spacer()
                                
                                Button(action: {
                                    
                                }) {
                                    Image(systemName: "chevron.right")
                                        .resizable()
                                        .frame(width: 8,height: 14)
                                        .foregroundColor(.gray)
                                }
                                .buttonStyle(.plain) // 防止 List 的点击冲突
                                .contentShape(Rectangle()) // 确保整个区域可点击
                                .padding(4)
                            }
                            .frame(height: 40)
                        }
                        
                    }
                    
                    Section {
                        Button(action: {
                            
                        }) {
                            Text("退出登录")
                                .frame(maxWidth: .infinity)
                                .frame(height: 40)
                            //.background(Color(hex: "#8E47F1"))
                                .foregroundColor(.red)
                                .cornerRadius(8)
                        }
                        .padding(0)
                        .frame(height: 40)
                    }
                }
                //.scrollContentBackground(.automatic)
                .navigationTitle("设置")
                .navigationBarTitleDisplayMode(.inline)
                .listStyle(.insetGrouped)
                
                
            }
            // 添加滑动返回
            .gesture(
                DragGesture().updating($dragOffset, body: { (value, state, transaction) in
                    if value.startLocation.x < 40 && value.translation.width > UIScreen.main.bounds.width/8 {
                        //presentationMode.wrappedValue.dismiss()
                    }
                })
            )
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        //presentationMode.wrappedValue.dismiss()
                    }) {
                        HStack {
                            Image(systemName: "chevron.left")
                                .foregroundColor(Color(ThemeManager.shared.getCurrentColorScheme() == .dark ? .white : .init(hex: "#000")))
                        }
                    }
                }
            }
            .navigationBarBackButtonHidden(true)
            
            .bottomSheetThemePicker(
                isPresented: $showingThemePicker,
                onThemeSelected: { theme in
                    print("主题已更改为: \(theme.description)")
                    // 这里可以执行主题改变后的其他操作
                    dismiss()
                }
            )
            
            .bottomSheetLanguagePicker(
                isPresented: $showingLanguagePicker,
                onLanguageSelected: { language in
                    // 处理语言变更
                    print("选择了语言: \(language)")
                }
            )
             
        }
    }
}
 







extension Notification.Name {
    static let languageChanged = Notification.Name("languageChanged")
}


// MARK: - 子视图
struct StyleSelectionView: View {
    @Binding var selectedStyle: String
    let styles = ["默认风格", "专业风格", "轻松风格", "学术风格"]
    
    var body: some View {
        List(styles, id: \.self) { style in
            Button {
                selectedStyle = style
            } label: {
                HStack {
                    CustomText(style)
                    Spacer()
                    if selectedStyle == style {
                        Image(systemName: "checkmark")
                            .foregroundColor(.blue)
                    }
                }
            }
        }
        .navigationTitle("语言风格")
    }
}

 
//struct AvatarSettingsView: View {
//    var body: some View {
//        VStack{
//            VStack{}
//                .frame(height:30)
//            CustomText("😀 ")
//                .navigationTitle("头像")
//                .frame(width: 20, height: 20)
//                .padding(10)
//                .overlay( RoundedRectangle(cornerRadius: 6)
//                            .stroke(Color.gray, lineWidth: 0.5))
//            Spacer()
//            VStack{}
//        }
////        CustomText("头像设置页面")
////            .navigationTitle("头像")
//    }
//}

struct SendKeySettingsView: View {
    var body: some View {
        CustomText("发送键设置页面")
            .navigationTitle("发送键")
    }
}

struct PersonalInfoView: View {
    var body: some View {
        Form {
            Section {
                TextField("姓名", text: .constant(""))
                TextField("职业", text: .constant(""))
                TextField("兴趣爱好", text: .constant(""))
            }
            
            Section {
                Toggle("本地存储", isOn: .constant(true))
                Toggle("同步到云端", isOn: .constant(false))
            }
        }
        .navigationTitle("个人信息管理")
    }
}
 



// 预览
struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
