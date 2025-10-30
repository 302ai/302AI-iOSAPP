//
//  SettingView.swift
//  Chat302AI
//
//  Created by Adswave on 2025/8/5.
//

import SwiftUI
import Toasts
import ActivityIndicatorView
import AlertToast

class NavigationCoordinator: ObservableObject {
     
}


struct SettingView: View {
     
    @Environment(\.dismiss) var dismiss
    @Environment(\.presentToast) var presentToast
    
    @State private var showAmountPicker = false  //弹出充值页面
    @State private var selectedAmount: RechargeMountType = .default  //选择充值金额
    
    
    // 状态管理
    //@ObservedObject var config = AppConfiguration.shared
    @EnvironmentObject var config: AppConfiguration
    
    @EnvironmentObject var store: ApiItemStore
    @EnvironmentObject var dataManager : ApiDataManager
    @EnvironmentObject var fontSettings: FontSettings
    
    @EnvironmentObject private var themeManager: ThemeManager
    @State private var showingThemePicker = false
    
    @EnvironmentObject var languageManager: LanguageManager
    @State private var showingLanguagePicker = false
    @State private var showLoading = false
    
    // 添加拖拽手势状态
    @GestureState private var dragOffset = CGSize.zero
     
    @State var showPreferenceView: Bool
    @State private var showAnnouncementView = false
    @State private var showVersionView = false
    @State  var showAgreementView = false
    
    @State  var showModelManager = false
    @State  var showCostDetailView = false
    @State  var showUserInfoView = false
    
    @State  var userBalance = "0.00"
    
    @State  var isShowToast = false
    @State  var hintText = ""
    
    
    @Environment(\.presentationMode) var presentationMode
    
    
    
    @State private var isGestureActive = false
 
    
    var body: some View {
        ZStack {
            
            List {
                // 第一组：账号信息
                Section {
                    HStack{
                        if let imgUrl = URL(string: UserDataManager.shared.getUserInfo()?.data?.safeAvatar ?? "https://file.302.ai/gpt/imgs/5b36b96aaa052387fb3ccec2a063fe1e.png") {
                            NetworkImageView(url: imgUrl)
                                //.scaledToFit()
                                .frame(width: 40,height: 40)
                                .clipShape(Circle())
                                .padding(.top, 3)
                        }else{
                            Image("applogo")
                                .resizable()
                                .frame(width: 40,height: 40)
                                .clipShape(Circle())
                        }
                         
                        VStack {
                            HStack{
                                CustomText(config.username)
                                    .foregroundColor(.primary)
                                Spacer()
                            }
                            Spacer()
                            HStack{
                                if let user = UserDataManager.shared.getCurrentUser(),user.register_from == "Phone" {
                                    Text(user.phone ?? "--")
                                        .foregroundColor(Color.gray)
                                }else{
                                    Text(UserDataManager.shared.getCurrentUser()?.safeEmail ?? "--")
                                        .foregroundColor(Color.gray)
                                }
                                Spacer()
                            }
                        }.frame(height: 40)
                        
                        Spacer()
                        Image(systemName: "chevron.right")
                            .resizable()
                            .frame(width: 8, height: 14)
                            .foregroundColor(.gray)
                    }
                    .contentShape(Rectangle()) // 确保整个区域都可点击
                    .onTapGesture {
                        // 处理点击事件
                        print("点击了用户信息行")
                        
                        showUserInfoView = true 
                        
                    }
                }
                
                
                // 第一组：余额信息
                Section {
                    
                    VStack{
                        
                        HStack {
                            VStack(alignment: .leading){
                                CustomText("余额".localized())
                                    .foregroundColor(.primary)
                                HStack(alignment: .bottom){
                                    CustomText(userBalance)
                                        .foregroundColor(.primary)
                                    CustomText("PTC")
                                        .font(Font.footnote)
                                        .foregroundColor(.gray)
                                        .offset(x:-5)
                                }
                            }
                            Spacer()
                            
                            CustomText("充值".localized())
                                .frame(height: 34)
                                .fixedSize()
                                .padding(.horizontal,8)
                                .background(Color(hex: "#8E47F1"))
                                .foregroundColor(.white)
                                .cornerRadius(10)
                                .onTapGesture {
                                    //let toast = ToastValue(message: "充值开发中~")
                                    //presentToast(toast)
                                    
                                    showAmountPicker = true
                                    
                                }
                        }
                        .frame(height: 66)
                        
                        Divider()
                        HStack {
                            CustomText("消耗总量".localized())
                                .foregroundColor(.primary)
                            Spacer()
                            HStack(alignment: .bottom){
                                CustomText("\(UserDataManager.shared.getCurrentUser()?.formattedGptCost ?? "--")")
                                    .foregroundColor(.secondary)
                                    .offset(x:5)
                                CustomText("PTC")
                                    .font(Font.footnote)
                                    .foregroundColor(.gray)
                            }
                        }
                        .frame(height: 40)
                        .contentShape(Rectangle())
//                        .onTapGesture {
//                            //showCostDetailView = true
//                            isShowToast = true
//                            hintText = "暂未开放"
//                        }
                    }
                    
                }
                
                
                
                Section(header: CustomText("通用".localized())) {
                    
                    VStack{
                        HStack {
                            CustomText("语言".localized())
                            Spacer()
                            
                            Button(action: {
                                showingLanguagePicker = true
                            }) {
                                CustomText(languageManager.currentLanguageDescription)
                                    .foregroundColor(.gray)
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
                            CustomText("主题".localized())
                            Spacer()
                            
                            Button(action: {
                                showingThemePicker = true
                            }) {
                                CustomText(ThemeManager.shared.themeMode.description.localized())
                                    .foregroundColor(.gray)
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
                        Button(action: {
                            showPreferenceView = true
                        }) {
                            HStack {
                                CustomText("偏好设置".localized())
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
                    }
                    
                }
                
                Section(header: CustomText("管理".localized())) {
                    VStack {
                        // 模型管理
                        Button(action: {
                            //let toast = ToastValue(message: "模型管理开发中~")
                            //presentToast(toast)
                            
                            showModelManager = true
                            
                        }) {
                            HStack {
                                CustomText("模型管理".localized())
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
                        
//                        Divider()
//                            .background(Color.init(hex: "#F6F6F6"))
                        // MCP服务
//                        Button(action: {
//                            let toast = ToastValue(message: "MCP服务开发中~")
//                            presentToast(toast)
//                        }) {
//                            HStack {
//                                CustomText("MCP服务".localized())
//                                Spacer()
//                                Image(systemName: "chevron.right")
//                                    .resizable()
//                                    .frame(width: 8, height: 14)
//                                    .foregroundColor(.gray)
//                            }
//                            .frame(height: 40)
//                            .contentShape(Rectangle())
//                        }
//                        .buttonStyle(.plain)
                        
                        /*
                        Divider()
                            .background(Color.init(hex: "#F6F6F6"))
                        
                        // 档案库
                        Button(action: {
                            let toast = ToastValue(message: "档案库开发中~")
                            presentToast(toast)
                        }) {
                            HStack {
                                CustomText("档案库".localized())
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .resizable()
                                    .frame(width: 8, height: 14)
                                    .foregroundColor(.gray)
                            }
                            .frame(height: 40)
                            .contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)
                        
                        Divider()
                            .background(Color.init(hex: "#F6F6F6"))
                        
                        // 知识库
                        Button(action: {
                            let toast = ToastValue(message: "知识库开发中~")
                            presentToast(toast)
                        }) {
                            HStack {
                                CustomText("知识库".localized())
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .resizable()
                                    .frame(width: 8, height: 14)
                                    .foregroundColor(.gray)
                            }
                            .frame(height: 40)
                            .contentShape(Rectangle())
                        }
                        .buttonStyle(.plain) */
                    }
                }
                
                
                Section(header: CustomText("关于".localized())) {
                    VStack{
                        
                        
                        Button(action: {
                            showAnnouncementView = true
                        }) {
                            HStack {
                                CustomText("公告".localized())
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
                        
                        
//                        HStack {
//                            CustomText("公告".localized())
//                            Spacer()
//                            
//                            Button(action: {
//                                showAnnouncementView = true
//                            }) {
//                                Image(systemName: "chevron.right")
//                                    .resizable()
//                                    .frame(width: 8,height: 14)
//                                    .foregroundColor(.gray)
//                            }
//                            .buttonStyle(.plain) // 防止 List 的点击冲突
//                            .contentShape(Rectangle()) // 确保整个区域可点击
//                            .padding(4)
//                            
//                            
//                        }.frame(height: 40)
                        
                        
                        
                        Divider()
                            .background(Color.init(hex: "#F6F6F6"))
                        
                        Button(action: {
                            showVersionView = true
                        }) {
                            HStack {
                                CustomText("版本信息".localized())
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
                        
                        
//                        HStack {
//                            CustomText("版本信息".localized())
//                            Spacer()
//                            
//                            Button(action: {
//                                showVersionView = true
//                            }) {
//                                Image(systemName: "chevron.right")
//                                    .resizable()
//                                    .frame(width: 8,height: 14)
//                                    .foregroundColor(.gray)
//                            }
//                            .buttonStyle(.plain) // 防止 List 的点击冲突
//                            .contentShape(Rectangle()) // 确保整个区域可点击
//                            .padding(4)
//                        }.frame(height: 40)
                        
                        
                        Divider()
                            .background(Color.init(hex: "#F6F6F6"))
                        
                        
                        Button(action: {
                            showAgreementView = true
                        }) {
                            HStack {
                                CustomText("服务协议".localized())
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
                        
//                        HStack {
//                            CustomText("服务协议".localized())
//                            Spacer()
//                            
//                            Button(action: {
//                                //https://302.ai/legal/terms/
//                                
//                                showAgreementView = true
//                            }) {
//                                Image(systemName: "chevron.right")
//                                    .resizable()
//                                    .frame(width: 8,height: 14)
//                                    .foregroundColor(.gray)
//                            }
//                            .buttonStyle(.plain) // 防止 List 的点击冲突
//                            .contentShape(Rectangle()) // 确保整个区域可点击
//                            .padding(4)
//                        }.frame(height: 40)
                        
                        
                    }
                    
                }
                
                Section {
                    Button(action: {
                        
                        config.isLogin = false
                        config.OAIkey = ""
                        
                        AppConfiguration.shared.isLogin = false
                        AppConfiguration.shared.OAIkey = ""
                        
                        PersistenceController.logout()
                        
                        TipsSettingView.clearCustomContent() //清除自定义提示词
                        
                        ApiDataManager.shared.restorePresetData()
                        
                        
                        if let selectedItem = ApiDataManager.shared.selectedItem {
                            
                            let item = ApiItem(name: selectedItem.name, host: selectedItem.host, apiKey: "", model: selectedItem.model, apiNote: selectedItem.apiNote)
                            ApiDataManager.shared.updateItem(item)
                            
                        }
                        presentationMode.wrappedValue.dismiss()
                        
                    }) {
                        Text("退出登录".localized())
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
            .navigationTitle("设置".localized())
            .navigationBarTitleDisplayMode(.inline)
            .listStyle(.insetGrouped)
            .background(NavigationGestureRestorer()) //返回手势
            
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
            
            
            //充值取消
            .onReceive(NotificationCenter.default.publisher(for: .rechargeCancelled)) { _ in
                let toast = ToastValue(message: "充值取消")
                presentToast(toast)
            }
            //充值失败
            .onReceive(NotificationCenter.default.publisher(for: .rechargeFailed)) { _ in
                let toast = ToastValue(message: "充值失败")
                presentToast(toast)
            }
            
            //注销账号
            .onReceive(NotificationCenter.default.publisher(for: .cancelAccount)) { _ in
                
                presentationMode.wrappedValue.dismiss()
            }
            
            
            //充值成功
            .onReceive(NotificationCenter.default.publisher(for: .rechargeSuccess)) { _ in
                let toast = ToastValue(message: "充值成功")
                presentToast(toast)
                
                NetworkManager.shared.getUserInfo(authorization: AppConfiguration.shared.userToken) { result in
                    DispatchQueue.main.async {
                        
                        switch result {
                        case .success(let response):
                            //var userInfo = response.data
                            print( "获取成功: \(response.msg)")
                            userBalance = UserDataManager.shared.getCurrentUser()?.formattedBalance ?? "--"
                            
                        case .failure(let error):
                            
                            if let networkError = error as? NetworkError,
                               case .apiError(let code, let message) = networkError {
                                print("API错误: code=\(code), message=\(message)")
                            }
                        }
                        
                    }
                }
                
            }
            
            //充值
            .bottomSheetRechargeMountPicker(
                isPresented: $showAmountPicker,
                selectedAmount: $selectedAmount
            ) { selectedType in
                print("确定了金额选择: \(selectedType.description)")
                
                let productID = "302.ai.\(selectedType.amount)ptc"
                showLoading = true
                
                AppPayManager.shared.startPay(proId: productID) { result in
                    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 3, execute: {
                        showLoading = false
                    })
                    print("\(result)")
                    let toast = ToastValue(message: result)
                    presentToast(toast)
                }
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 5, execute: {
                    showLoading = false
                })
                
            }
            
            
            .bottomSheetThemePicker(
                isPresented: $showingThemePicker,
                onThemeSelected: { theme in
                    print("主题已更改为: \(theme.description)")
                    // 这里可以执行主题改变后的其他操作
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        //dismiss()
                    }
                }
            )
            
            .bottomSheetLanguagePicker(
                isPresented: $showingLanguagePicker,
                onLanguageSelected: { language in
                    // 处理语言变更
                    print("选择了语言: \(language)")
                }
            )
            
            
            NavigationLink(
                destination: CostDetailView(),
                isActive: $showCostDetailView ,
                label: { EmptyView() }
            )
            .hidden()
            
            NavigationLink(
                destination: UserInfoView(),
                isActive: $showUserInfoView ,
                label: { EmptyView() }
            )
            .hidden()
            
            
            NavigationLink(
                destination: ApiItemListView(),
                //destination: ModelListView2(),
                isActive: $showModelManager ,
                label: { EmptyView() }
            )
            .hidden()
            
            
            NavigationLink(
                destination: AnnouncementView(),
                isActive: $showAnnouncementView ,
                label: { EmptyView() }
            )
            .hidden()
            
            
            
            NavigationLink(
                destination: VersionView(),
                isActive: $showVersionView ,
                label: { EmptyView() }
            )
            .hidden()
            
            NavigationLink(
                destination: AgreementView(),
                isActive: $showAgreementView ,
                label: { EmptyView() }
            )
            .hidden()
            
            NavigationLink(
                destination: PreferenceSet(),
                isActive: $showPreferenceView ,
                label: { EmptyView() }
            )
            .hidden()
            
            ActivityIndicatorView(isVisible: $showLoading, type: .flickeringDots(count: 8))
                .frame(width: 50, height: 50)
        }
        .onAppear{
            userBalance = UserDataManager.shared.getCurrentUser()?.formattedBalance ?? "--"
        }
         
        .toast(isPresenting: $isShowToast){
              
            AlertToast(displayMode: .alert, type: .regular, title: hintText)
        }
        
    }
}

//启用返回手势
struct NavigationGestureRestorer: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> UIViewController {
        UIViewController()
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        DispatchQueue.main.async {
            // 获取导航控制器并重新启用手势
            if let navigationController = uiViewController.navigationController {
                navigationController.interactivePopGestureRecognizer?.isEnabled = true
                navigationController.interactivePopGestureRecognizer?.delegate = nil
            }
        }
    }
}
  







 





















