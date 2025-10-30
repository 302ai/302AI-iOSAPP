//
//  VersionView.swift
//  Chat302AI
//
//  Created by Adswave on 2025/8/28.
//

import SwiftUI


struct VersionView: View {
    
    
    @Environment(\.presentationMode) var presentationMode
    @State private var showCancelAccount = false  //弹出充值页面
    
    @State private var isShowToast = false
    @State private var hintText: String?
    @State private var lastVersioin = ""
    @State private var showNewVersion = false
    
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
                                        Image("applogo")
                                            .resizable()
                                            .frame(width: 70, height: 70)
                                            .clipShape(Circle())
                                     
                                }
                                .frame(width: 80, height: 80) // 增加容器大小以容纳偏移的图标
                            }
                            .frame(maxWidth: .infinity)
                            
                            Text("302.AI")
                                .font(.title)
                            
                            
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
                            print("点击了当前版本")
                            
                        }) {
                            var version =  Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "--"
                            
                            SettingRow(title: "当前版本".localized(), value: version, action: { },showChevron: false)
                                .frame(height: 40)
                                .contentShape(Rectangle())
                            
                        }
                        .buttonStyle(PlainButtonStyle())
                        
                        Divider()
                        
                        Button(action: {
                            print("点击了版本更新")
                            if let url = URL(string: "https://apps.apple.com/cn/app/302-ai/id6744959746") {
                                UIApplication.shared.open(url)
                            }
                            
                        }) {
                                
                            SettingRow(title: "版本更新".localized(), value: showNewVersion ? lastVersioin : "", action: {}, showRedBackground: showNewVersion)
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
                
                
                //Section {
                    
                //}
                
            }
            .listSectionSpacing(12) // 设置 Section 上下间距为 10
            .scrollContentBackground(.hidden)
            .background(Color(ThemeManager.shared.getCurrentColorScheme() == .dark ? .black : .init(hex: "#F9F9F9")))
        }
            .listStyle(.insetGrouped)
            .background(NavigationGestureRestorer()) //返回手势
        //}
            .navigationTitle("".localized())
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
            .onAppear{
                detectionOfUpdate()
            }
    
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
        
        
        
            //.toast(isPresenting: $isShowToast){
            //    AlertToast(displayMode: .alert, type: .regular, title: hintText)
            //}
         
        
         
        
    }
    
    
    
    // 检查更新
    func detectionOfUpdate() {
        // 获取当前版本
        let localVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? ""
        
        // 获取App Store上的最新版本
        let url = "http://itunes.apple.com/lookup?id=6744959746"
        
        guard let requestUrl = URL(string: url) else { return }
        
        URLSession.shared.dataTask(with: requestUrl) { data, response, error in
            if let data = data {
                do {
                    if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                       let results = json["results"] as? [[String: Any]],
                       let ver = results[0]["version"] as? String {
                        lastVersioin = ver
                        DispatchQueue.main.async {
                            checkAppVersion(ver)
                        }
                    }
                } catch {
                    print("JSON解析错误: \(error)")
                }
            }
        }.resume()
    }
    
    func checkAppVersion(_ versionString: String?) {
        guard let versionString = versionString else { return }
        
        let bundleVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? ""
        
        let newVersion = versionString.replacingOccurrences(of: ".", with: "")
        let currentVersion = bundleVersion.replacingOccurrences(of: ".", with: "")
        
        if Int(newVersion) ?? 0 > Int(currentVersion) ?? 0 {
            showNewVersion = true
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
    VersionView()
}
