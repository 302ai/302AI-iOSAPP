//
//  NotLoginView.swift
//  Chat302AI
//
//  Created by Adswave on 2025/7/31.
//

import SwiftUI

struct NotLoginView: View {
    @State private var showLoginAlert = false
    @State private var showSigninSafari = false
    @State private var showSigninWebview = false
    @State private var apiKey = ""
    @State private var username = ""
    @State private var uid = 0

    
    @State private var userInfo: UserInfoResponse.UserData?
    
    @EnvironmentObject var config: AppConfiguration

    // 添加拖拽手势状态
    @GestureState private var dragOffset = CGSize.zero
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        ZStack {
            Image("登录页背景")
                .resizable()
                .scaledToFill()
                .edgesIgnoringSafeArea(.all)
            
            GeometryReader { geometry in
                VStack(spacing: 16) {
                    Text("")
                        .frame(minHeight: 200)
                    
                    Image("logo302ai")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 180, height: 54)
                    
                    Text("一个按用量付费的企业级AI平台")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(Color(hex: "#8E47F1"))
                    
                    Spacer()
                    
                    Button(action: {
                        //showLoginAlert = true
                        showSigninWebview = true
                    }) {
                        Text("立即登录")
                            .frame(maxWidth: .infinity)
                            .frame(height: 48)
                            .background(Color(hex: "#8E47F1"))
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, geometry.safeAreaInsets.bottom + 120)
                }
                .frame(width: geometry.size.width, height: geometry.size.height)
            }
        }
        
        .onChange(of: apiKey) { newValue in
            
            print("登录成功: ---> 返回apiKey:\(newValue)")
            config.isLogin = true
            
            config.uid = uid
            config.username = username
            
            
            AppConfiguration.shared.OAIkey = apiKey
            
            if let selectedItem = ApiDataManager.shared.selectedItem {
                
                let item = ApiItem(name: selectedItem.name, host: selectedItem.host, apiKey: apiKey, model: selectedItem.model, apiNote: selectedItem.apiNote)
                ApiDataManager.shared.updateItem(item)
                
                presentationMode.wrappedValue.dismiss()
            }
            
            
        }
        
        .alert("登录页加载方式", isPresented: $showLoginAlert) {
            Button("Webview") {
                showSigninWebview = true
            }
            
            Button("SafariView") {
                showSigninSafari = true
            }
            
            Button("取消", role: .cancel) {
                
            }
        } message: {
            Text("(仅测试)")
        }
        
        
        // 添加拖拽手势
//        .gesture(
//            DragGesture().updating($dragOffset, body: { (value, state, transaction) in
//                if value.startLocation.x < 40 && value.translation.width > UIScreen.main.bounds.width/8 {
//                    presentationMode.wrappedValue.dismiss()
//                }
//            })
//        )
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    HStack {
                        Image(systemName: "chevron.left")
                            .foregroundColor(Color(hex: "#000"))
                    }
                }
            }
        }
        .background(NavigationGestureRestorer()) //返回手势
        .navigationBarBackButtonHidden(true)
         
        .sheet(isPresented: $showSigninSafari) {
            LoginView3(apiKey: $apiKey, uid: $uid, username:$username)
        }
        
        
        .sheet(isPresented: $showSigninWebview) {
            LoginView(apiKey:$apiKey,username: $username,uid: $uid, userInfo: $userInfo)
        }
        
        
    }
}

#Preview {
    NotLoginView()
}
