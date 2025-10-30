//
//  UserInfoView.swift
//  Chat302AI
//
//  Created by Adswave on 2025/10/11.
//

import SwiftUI
import AlertToast


struct UserInfoView: View {
    
    
    @Environment(\.presentationMode) var presentationMode
    @State private var showCancelAccount = false  //弹出充值页面
    
    @State private var isShowToast = false
    @State private var hintText: String?
    
    
    var body: some View {
        
        //NavigationView{
        VStack {
            List {
                Section {
                        VStack {
                            Button(action: {
                                // 按钮动作
                                print("点击了头像")
                                
                            }) {
                                ZStack(alignment: .bottomTrailing) {
                                    if let imgUrl = URL(string: UserDataManager.shared.getUserInfo()?.data?.safeAvatar ?? "https://file.302.ai/gpt/imgs/5b36b96aaa052387fb3ccec2a063fe1e.png") {
                                        NetworkImageView(url: imgUrl)
                                            .scaledToFit()
                                            .frame(width: 70, height: 70)
                                            .clipShape(Circle())
                                    } else {
                                        Image("applogo")
                                            .resizable()
                                            .frame(width: 70, height: 70)
                                            .clipShape(Circle())
                                    }
                                    
                                    Image("相机")
                                        .foregroundColor(.white)
                                        .padding(5)
                                        .frame(width: 25, height: 25)
                                        .offset(x: 1, y: 1) // 减少偏移量确保完全可见
                                        .hidden()
                                }
                                .frame(width: 80, height: 80) // 增加容器大小以容纳偏移的图标
                            }
                            .frame(maxWidth: .infinity)
                        }
                        .frame(maxWidth: .infinity)
                        .listRowInsets(EdgeInsets())
                        .background(Color(ThemeManager.shared.getCurrentColorScheme() == .dark ? .black : .init(hex: "#F9F9F9")))
                    }
                    header: {
                        EmptyView()
                    }

                
                
                Section {
                    VStack {
                        Button(action: {
                            print("点击了用户名")
                            
                        }) {
                            if let user = UserDataManager.shared.getCurrentUser(),user.register_from == "Phone" {
                                 
                                SettingRow(title: "用户名".localized(), value: user.phone ?? "--", action: { })
                                    .frame(height: 40)
                                    .contentShape(Rectangle())
                            }else{
                                SettingRow(title: "用户名".localized(), value: UserDataManager.shared.getCurrentUser()?.safeEmail ?? "--", action: { })
                                    .frame(height: 40)
                                    .contentShape(Rectangle())
                            }
                            
                            
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                    .frame(minHeight: 45)
                }
                header: {
                    EmptyView() // 移除默认的 header 占位
                }
                
                
                
                /*
                //修改密码
                Section {
                    VStack {
                        Button(action: {
                            print("点击了修改密码")
                            
                            
                        }) {
                            SettingRow(title: "修改密码".localized(), value: "", action: {})
                                .frame(height: 40)
                                .contentShape(Rectangle())
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                    .frame(minHeight: 45)
                }
                */
                
                
                Section {
                    VStack {
                        Button(action: {
                            // 注销操作
                            
                            print("点击了注销账户")
                            showCancelAccount = true
                        }) {
                            Text("注销账户".localized())
                                .fontWeight(.bold)
                                .foregroundStyle(Color.red)
                                .frame(maxWidth: .infinity, maxHeight: 40) // 添加 maxWidth: .infinity
                                .multilineTextAlignment(.center) // 文字居中
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
        //}
            .navigationTitle("个人资料".localized())
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
    
    
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
        
        
        
            .toast(isPresenting: $isShowToast){
                
                AlertToast(displayMode: .alert, type: .regular, title: hintText)
            }
        
        
            .alert(isPresented: $showCancelAccount) {
                Alert(
                    title: Text("注销须知".localized()),
                    message: Text("注销账号后,所有信息将永久消失,\n请谨慎操作".localized()),
                    primaryButton: .default(Text("取消".localized())),
                    secondaryButton: .destructive(Text("确定".localized())) {
                        // 执行注销操作
                        //performLogout()
                        NetworkManager.shared.userDelete { result in
                            DispatchQueue.main.async {
                                switch result {
                                case .success(let response):
                                    if response.code == 0 {
                                        print("成功 response:\(response)")
                                        
                                        hintText = "注销成功".localized()
                                        isShowToast = true
                                        
                                        
                                        AppConfiguration.shared.isLogin = false
                                        PersistenceController.logout()
                                        ApiDataManager.shared.restorePresetData()
                                        
                                        if let selectedItem = ApiDataManager.shared.selectedItem {
                                            let item = ApiItem(name: selectedItem.name, host: selectedItem.host, apiKey: "", model: selectedItem.model, apiNote: selectedItem.apiNote)
                                            ApiDataManager.shared.updateItem(item)
                                        }
                                        
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                                            presentationMode.wrappedValue.dismiss()
                                        }
                                        
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                                            NotificationCenter.default.post(
                                                name: .cancelAccount,
                                                object: nil
                                            )
                                        }
                                        
                                        
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                                            DispatchQueue.main.async {
                                                NotificationCenter.default.post(
                                                    name: .requireLogin,
                                                    object: nil
                                                )
                                            }
                                        }
                                        
                                        
                                        
                                    }else if  response.code == 2004 {
                                        print("验注销失败: \(response.msg)")
                                        hintText = "\(response.msg):\(response.code)"
                                        AppConfiguration.shared.isLogin = false
                                        isShowToast = true
                                        
                                        
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                                            presentationMode.wrappedValue.dismiss()
                                        }
                                         
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                                            NotificationCenter.default.post(
                                                name: .cancelAccount,
                                                object: nil
                                            )
                                        }
                                        
                                        
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                                            DispatchQueue.main.async {
                                                NotificationCenter.default.post(
                                                    name: .requireLogin,
                                                    object: nil
                                                )
                                            }
                                        }
                                        
                                    }
                                    else {
                                        
                                        print("验注销失败: \(response.msg)")
                                        hintText = "\(response.msg):\(response.code)"
                                        isShowToast = true
                                        
                                        
                                    }
                                case .failure(let error):
                                    
                                    print("注销请求失败: \(error.localizedDescription)")
                                    hintText = error.localizedDescription
                                    isShowToast = true
                                }
                            }
                        }
                    }
                )
            }
        
         
        
    }
    
    
    // 递归方法回到根视图
       private func popToRoot() {
           if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first,
              let rootViewController = window.rootViewController {
               
               findAndDismiss(rootViewController)
           }
       }
       
       private func findAndDismiss(_ viewController: UIViewController) {
           if let presented = viewController.presentedViewController {
               findAndDismiss(presented)
               viewController.dismiss(animated: true)
           }
       }
    
}

#Preview {
    UserInfoView()
}
