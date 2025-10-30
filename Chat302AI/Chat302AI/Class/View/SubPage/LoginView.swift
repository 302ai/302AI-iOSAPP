//
//  LoginView.swift
//  Chat302AI
//
//  Created by Adswave on 2025/9/4.
//

import SwiftUI
import CountryPicker
import AlertToast
 

struct LoginView: View {
    
    @Binding var apiKey : String
    @Binding var username : String
    @Binding var uid : Int
    
    
    @Binding var userInfo: UserInfoResponse.UserData?
    
    @Environment(\.dismiss) var dismiss
    
    @State private var captchaImage = UIImage(named: "刷新.png")
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var requestInfo: String = ""
    @State private var responseCode: String = ""
    @State private var responseMessage: String = ""
    
    @State private var authorizationToken: String = "" 
    @State private var responseDetails: String = ""
    
    
    @State private var selectedTab = 0
    //邮箱
    @State private var email = ""
    @FocusState private var isEmailFocused: Bool
    @State private var showEmailError = false
    
    //密码
    @State private var password = ""
    @FocusState private var isPasswordFocused: Bool
    @State private var showPasswordError = false
    @State private var isPasswordVisible = false
    
    
    //手机号
    @State private var phoneNumber = ""
    @FocusState private var isPhoneFocused: Bool
    @State private var showPhoneError = false
    @State private var showingCountryPicker = false
    @State private var countryCode = "+86"
    @State var country : Country? = Country(countryCode: "CN")
    
    
    
    //验证码
    @State private var verificationCode = ""
    @FocusState private var isVerificationCodeFocused: Bool
    @State private var showVerificationCodeError = false
    @State private var captchaText = ""
    
    
     
    @State private var isShowingEmailRegisterView = false
    @State private var isShowingPhoneRegisterView = false
    
    @EnvironmentObject var config: AppConfiguration
    @AppStorage("rememberPassword") private var rememberPassword = false
    @AppStorage("lastLoginType") private var lastLoginType = "" // "email" 或 "phone"
 
    @State private var isEmailLogin = true // true: 邮箱登录, false: 手机登录
    
    
    
    let countryCodes = ["+86", "+1", "+93", "+44", "+81", "+82", "+33", "+49"]
    
    
    @State private var isShowToast = false
    @State private var hintText: String?
    
    
    
    var body: some View {
        NavigationView {
            
//            Color.clear
//                .overlay(
            ZStack{
                if ThemeManager.shared.getCurrentColorScheme() == .dark {
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color(hex: "#472676"),
                            Color(hex: "#2f204e")
                        ]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                    .ignoresSafeArea()
                }else{
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color(hex: "#e3e8fe"),
                            Color(hex: "#fafcff")
                        ]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                    .ignoresSafeArea()
                }
                
                
                VStack(spacing: 20) {
                    
                    // App标题
                    Image("logo302ai")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 180, height: 54)
                        .padding(.top, 40)
                    
                    VStack{
                        // 登录方式选择
                        HStack(spacing: 100) {
                            loginButton(title: "邮箱登录".localized(), index: 0)
                            loginButton(title: "手机登录".localized(), index: 1)
                        }
                        .padding(.top, 20) // 减少顶部内边距
                        .padding(.bottom, 8) // 减少底部内边距，让按钮更靠近横条
                        .zIndex(1)
                        
                        // 底部横条 - 减少与按钮的距离
                        GeometryReader { geometry in
                            let totalWidth = geometry.size.width
                            let buttonWidth: CGFloat = 70
                            
                            HStack(spacing: 100) {
                                Capsule()
                                    .fill(Color.init(hex: "#8E47F1"))
                                    .frame(width: buttonWidth, height: 3)
                                    .offset(x: selectedTab == 0 ? 0 : buttonWidth + 100)
                                    .animation(.spring(response: 0.4, dampingFraction: 0.8), value: selectedTab)
                                
                                Spacer()
                            }
                            .padding(.leading, (totalWidth - (buttonWidth * 2 + 100)) / 2)
                            .offset(y: -5) // 向上偏移，更靠近按钮
                        }
                        .frame(height: 4) // 保持横条容器高度不变
                    }
                    
                    // 登录表单区域
                    VStack(spacing: 20) {
                        
                        
                        // 登录表单
                        if selectedTab == 0 {
                            // 邮箱登录表单
                            VStack(alignment: .leading, spacing: 8) {
                                
                                HStack{
                                    Image(systemName: "at")
                                    Text("邮箱".localized())
                                    Spacer()
                                }
                                TextField("请输入邮箱".localized(), text: $email)
                                    .textFieldStyle(PlainTextFieldStyle())
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 10)
                                    .background(Color.gray.opacity(0.1))
                                    .cornerRadius(6)
                                //                                        .background(
                                //                                            RoundedRectangle(cornerRadius: 8)
                                //                                                .stroke(isEmailFocused ? .purple : (showEmailError ? .red : .gray.opacity(0.3)), lineWidth: 1)
                                //                                                .background(
                                //                                                    RoundedRectangle(cornerRadius: 8)
                                //                                                        .fill(showEmailError ? Color.red.opacity(0.1) : Color.clear)
                                //                                                )
                                //                                        )
                                    .focused($isEmailFocused)
                                    .onChange(of: isEmailFocused) { isFocused in
                                        if !isFocused && email.isEmpty {
                                            showEmailError = true
                                        } else {
                                            showEmailError = false
                                        }
                                    }
                            }
                            .padding(.horizontal, 12)
                        } else {
                            VStack(alignment: .leading, spacing: 8) {
                                
                                
                                HStack{
                                    Image(systemName: "platter.filled.bottom.iphone")
                                    Text("手机号码".localized())
                                    Spacer()
                                }
                                
                                HStack {
                                    Button(action: {
                                        showingCountryPicker.toggle()
                                    }) {
                                        HStack {
                                            
                                            Image(uiImage: (country?.flag ?? UIImage(imageLiteralResourceName: "applogo")))
                                                .resizable()
                                                .frame(width: 25, height: 20)
                                            Image(systemName: "chevron.down")
                                                .font(.system(size: 12))
                                                .foregroundColor(.gray)
                                        }
                                        .padding(8)
                                        .background(Color.gray.opacity(0.1))
                                        .cornerRadius(4)
                                    }
                                    .sheet(isPresented: $showingCountryPicker) {
                                        CountryPickerView(configuration:Configuration(navigationTitleText: "选择国家/地区".localized()), selectedCountry: $country)
                                    }
                                    
                                    HStack(spacing: 0) {
                                        Text(country?.dialingCode ?? "+86")
                                            .foregroundColor(.primary)
                                            .padding(.leading, 12)
                                            .frame(width: 60, alignment: .leading)
                                        
                                        TextField("请输入手机号*".localized(), text: $phoneNumber)
                                            .keyboardType(.phonePad)
                                            .textFieldStyle(PlainTextFieldStyle())
                                            .padding(.trailing, 12)
                                            .padding(.vertical, 10)
                                            .focused($isPhoneFocused)
                                            .onChange(of: isPhoneFocused) { isFocused in
                                                if !isFocused && phoneNumber.isEmpty {
                                                    showPhoneError = true
                                                } else {
                                                    showPhoneError = false
                                                }
                                            }
                                    }
                                    .background(Color.gray.opacity(0.1))
                                    .cornerRadius(6)
                                    //                                        .background(
                                    //                                            RoundedRectangle(cornerRadius: 8)
                                    //                                                .stroke(isPhoneFocused ? .purple : (showPhoneError ? .red : .gray.opacity(0.3)), lineWidth: 1)
                                    //                                                .background(
                                    //                                                    RoundedRectangle(cornerRadius: 8)
                                    //                                                        .fill(showPhoneError ? Color.red.opacity(0.1) : Color.clear)
                                    //                                                )
                                    //                                        )
                                    //                                        .frame(height: 44)
                                    //                                        .animation(.easeInOut(duration: 0.2), value: isPhoneFocused)
                                    //                                        .animation(.easeInOut(duration: 0.2), value: showPhoneError)
                                }
                                
                            }
                            .padding(.horizontal, 12)
                        }
                        
                        
                        VStack(alignment: .leading, spacing: 8) {
                            HStack{
                                Image(systemName: "exclamationmark.lock")
                                Text("密码".localized())
                                Spacer()
                            }
                            HStack {
                                if isPasswordVisible {
                                    TextField("请输入密码".localized(), text: $password)
                                } else {
                                    SecureField("请输入密码".localized(), text: $password)
                                }
                                
                                Button(action: {
                                    isPasswordVisible.toggle()
                                }) {
                                    Image(systemName: isPasswordVisible ? "eye" : "eye.slash")
                                        .foregroundColor(.gray)
                                }
                            }
                            .textFieldStyle(PlainTextFieldStyle())
                            .padding(.horizontal, 12)
                            .padding(.vertical, 10)
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(6)
                            //                                .background(
                            //                                    RoundedRectangle(cornerRadius: 8)
                            //                                        .stroke(isPasswordFocused ? .purple : (showPasswordError ? .red : .gray.opacity(0.3)), lineWidth: 1)
                            //                                        .background(
                            //                                            RoundedRectangle(cornerRadius: 8)
                            //                                                .fill(showPasswordError ? Color.red.opacity(0.1) : Color.clear)
                            //                                        )
                            //                                )
                            .focused($isPasswordFocused)
                            .onChange(of: isPasswordFocused) { isFocused in
                                if !isFocused && password.isEmpty {
                                    showPasswordError = true
                                } else {
                                    showPasswordError = false
                                }
                            }
                        }
                        .padding(.horizontal, 12)
                        
                        
                        // 图形验证码
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                
                                
                                
                                TextField("图形验证码*".localized(), text: $verificationCode)
                                    .textFieldStyle(PlainTextFieldStyle())
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 10)
                                    .background(Color.gray.opacity(0.1))
                                    .cornerRadius(6)
                                //                                        .background(
                                //                                            RoundedRectangle(cornerRadius: 8)
                                //                                                .stroke(isVerificationCodeFocused ? .purple : (showVerificationCodeError ? .red : .gray.opacity(0.3)), lineWidth: 1)
                                //                                                .background(
                                //                                                    RoundedRectangle(cornerRadius: 8)
                                //                                                        .fill(showVerificationCodeError ? Color.red.opacity(0.1) : Color.clear)
                                //                                                )
                                //                                        )
                                    .focused($isVerificationCodeFocused)
                                    .onChange(of: isVerificationCodeFocused) { isFocused in
                                        if !isFocused && verificationCode.isEmpty {
                                            showVerificationCodeError = true
                                        } else {
                                            showVerificationCodeError = false
                                        }
                                    }
                                
                                if showVerificationCodeError {
                                    //Text("请输入验证码".localized())
                                        //.font(.subheadline)
                                        //.foregroundColor(.red)
                                }
                                
                                
                                Spacer()
                                
                                // 可点击刷新的验证码图像
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(Color.gray.opacity(0.3))
                                    .frame(width: 100, height: 42)
                                    .overlay(
                                        
                                        Image(uiImage: captchaImage!)
                                            .resizable()
                                            .aspectRatio(contentMode: .fit)
                                            //.frame(maxWidth: 80)
                                            .frame(width: 100, height: 42)
                                            .onTapGesture {
                                                //获取图片验证码
                                                fetchImage()
                                            }
                                    )
                            }
                            
                        }
                        .padding(.horizontal, 12)
                        
                        
                        
                        
                        // 记住密码和忘记密码
                        HStack {
                            HStack {
                                Button(action: {
                                    rememberPassword.toggle()
                                }) {
                                    Image(systemName: rememberPassword ? "checkmark.square.fill" : "square")
                                        .foregroundColor(Color.init(hex: "#8E47F1"))
                                }
                                
                                Text("记住密码".localized())
                                    .font(.subheadline)
                            }
                            
                            Spacer()
                            
//                            Button("忘记密码？".localized()) {
//                                // 忘记密码操作
//                                
//                                isShowToast = true
//                                hintText = "开发中"
//                                
//                                
//                            }
//                            .font(.subheadline)
//                            .foregroundColor(Color.init(hex: "#8E47F1"))
                        }
                        .padding(.horizontal, 12)
                        
                        // 登录按钮
                        Button(action: {
                            // 登录操作
                            //login()
                            
                            sendLoginRequest()
                            
                        }) {
                            Text("登录".localized())
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.init(hex: "#8E47F1"))
                                .cornerRadius(8)
                        }
                        .padding(.horizontal, 12)
                        .padding(.top, 20)
                        
                        
                        //Spacer()
                        
                        // 注册引导
                        HStack {
                            Text("没有账号？".localized())
                                .font(.subheadline)
                                .foregroundColor(.gray)
                            
                            Button("立即注册".localized()) {
                                
                                //isShowToast = true
                                //hintText = "开发中"
                                
                                if selectedTab == 0 {
                                    isShowingEmailRegisterView = true
                                }else{
                                    isShowingPhoneRegisterView = true
                                }
                            }
                            .font(.subheadline)
                            .foregroundColor(Color.init(hex: "#8E47F1"))
                        }
                        .padding(.bottom, 20)
                    }
                    .padding(20) // 内容区域的内边距
                    .background(Color(.systemBackground)) // 白色背景提高可读性
                    .cornerRadius(12) // 圆角
                    .padding(.horizontal, 10) // 左右padding10
                    .padding(.vertical, 12) // 上下padding20
                    
                    
                    
                    
                    // 其他登录方式
                    VStack(spacing: 15) {
                        
                        Spacer()
                        Text("其他登录方式".localized())
                            .font(.subheadline)
                            .foregroundColor(.gray)
                        
                        HStack(spacing: 12) {
                            // 第三方登录图标
                            Button(action: {
                                selectedTab = selectedTab == 0 ?  1 :  0
                            }) {
                                Circle()
                                    .fill(Color.gray.opacity(0.2))
                                    .frame(width: 50, height: 50)
                                    .overlay(
                                        Image(systemName: selectedTab == 0 ? "platter.filled.bottom.iphone" : "envelope")
                                            .foregroundColor(.purple)
                                    )
                            }
                            
                        }
                    }
                }
                .padding()
            }
//                )
//                .background(
//                    Image("登录页背景")
//                        .resizable()
//                        .scaledToFill()
//                        .edgesIgnoringSafeArea(.all)
//                )
            
                .navigationBarHidden(true)
                .sheet(isPresented: $isShowingEmailRegisterView) {
                    EmailRegisterView(isFromPhone:false)
                }
                .sheet(isPresented: $isShowingPhoneRegisterView) {
                    PhoneRegisterView(isFromEmail:false)
                }
                .toast(isPresenting: $isShowToast){
                    
                    AlertToast(displayMode: .alert, type: .regular, title: hintText)
                }
            
                .onAppear{
                    fetchImage()
                    if rememberPassword {
                        email = config.savedEmail
                        password = config.savedPassword
                        phoneNumber = config.savedPhone
                    }
                }
            
                .onReceive(NotificationCenter.default.publisher(
                    for: .needGetUserInfo)
                ) { notification in
                    if let loginToken = notification.object as? String {
                        
                        fetchUserInfo(token: loginToken)
                    }
                }
            
            
            
        } 
        
    }
    
    
    private func loginButton(title: String, index: Int) -> some View {
            Button(action: {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                    selectedTab = index
                }
            }) {
                VStack {
                    Text(title)
                        .font(.system(size: 18, weight: selectedTab == index ? .semibold : .regular))
                        .foregroundColor(selectedTab == index ? .primary : .gray)
                }
            }
        }
    
    // 获取图片
       private func fetchImage() {
           isLoading = true
           errorMessage = nil
           responseCode = ""
           
           // 记录请求信息
           let timestamp = Int(Date().timeIntervalSince1970 * 1000)
           let randomCode = NetworkManager.shared.generateRandomString(length: 10)
           requestInfo = "https://dash-api.302.ai/proxy/static/image?code=\(randomCode)-\(timestamp)"
           
           NetworkManager.shared.fetchImage { result in
               DispatchQueue.main.async {
                   self.isLoading = false
                   
                   switch result {
                   case .success(let response):
                       // 保存返回的code
                       self.responseCode = response.code
                       print("\n======请求验证码图片的字符串:======\n \(self.responseCode)")
                       if let uiImage = UIImage(data: response.data) {
                           self.captchaImage = uiImage
                       } else {
                           self.errorMessage = "无法解析图像数据"
                       }
                   case .failure(let error):
                       self.errorMessage = error.localizedDescription
                   }
               }
           }
       }
    
    
    
    //MARK: - 邮箱登录
    private func sendLoginRequest() {
           isLoading = true
           responseMessage = ""
           errorMessage = ""
           
        isEmailLogin = selectedTab == 0 ? true : false
        
        if isEmailLogin {
            // 邮箱登录验证
            if email.isEmpty {
                showEmailError = true
                
                isShowToast = true
                hintText = "请输入邮箱".localized()
                
                return
            }
        } else {
            // 手机登录验证
            if phoneNumber.isEmpty {
                showPhoneError = true
                
                isShowToast = true
                hintText = "请输入手机号".localized()
                
                return
            }
            
        }
        
        if password.isEmpty {
            showPasswordError = true
            
            isShowToast = true
            hintText = "请输入密码".localized()
            
            return
        }
           
        
        if verificationCode.isEmpty {
            showVerificationCodeError = true
            
            isShowToast = true
            hintText = "请输入验证码".localized()
            
            return
        }
         
        isEmailLogin = selectedTab == 0 ? true : false
         
        // 处理记住密码逻辑
        if rememberPassword {
            if isEmailLogin {
                config.savedEmail = email
                lastLoginType = "email"
            } else {
                config.savedPhone = phoneNumber
                lastLoginType = "phone"
            }
            config.savedPassword = password
        } else {
            clearSavedCredentials()
        }
        
        
        var request : LoginRequest
        // Email请求对象
        if selectedTab == 0 {
            request = LoginEmailRequest(
              email: email,
              password: password,
              ref: "",
              event: "",
              captcha: verificationCode,
              code: self.responseCode,
              login_from: "iOSApp"
          )
        }else{
            //Phone请求对象
            request = LoginPhoneRequest(
                phone: phoneNumber, //"\(country?.dialingCode ?? "+86")\(phoneNumber)",
              password: password,
              ref: "",
              event: "",
              captcha: verificationCode,  //验证码
              code: self.responseCode,  //请求验证码的字符串
              login_from: "iOSApp"
          )
        }
           
        
        
           
           // 发送请求
        NetworkManager.shared.loginRequest(isEmail: isEmailLogin ,request: request) { result in
               DispatchQueue.main.async {
                   isLoading = false
                   
                   switch result {
                   case .success(let response):
                       if response.success {
                           responseMessage = "登录成功！\(response.msg)"
                           if let token = response.data?.token {
                               responseMessage += "\n用户ID: \(token)"
                               
                               self.authorizationToken = token
                               
                               AppConfiguration.shared.userToken = token
                               
                               fetchUserInfo(token:token)
                              
                           }
                       } else {
                           errorMessage = "失败: \(response.msg) : \(response.code)"
                           
                           if response.code == 900 {
                               hintText = "验证码错误".localized()
                               fetchImage()
                           }
                           if response.code == 604 {
                               hintText = "账号或密码错误".localized()
                           }
                            
                           isShowToast = true
                        }
                   case .failure(let error):
                       errorMessage = error.localizedDescription
                   }
                   
                   //showAlert = true
               }
           }
       }
    
    
    //清除记住
    func clearSavedCredentials() {
        config.savedEmail = ""
        config.savedPhone = ""
        config.savedPassword = ""
//        lastLoginType = ""
//        email = ""
//        phoneNumber = ""
//        password = ""
    }
    
    //MARK: - 获取用户信息
    private func fetchUserInfo(token:String) {
            isLoading = true
            userInfo = nil
            errorMessage = ""
            responseDetails = ""
            
        if token.isEmpty {
            return
        }
             
            // 隐藏键盘
            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
            
            NetworkManager.shared.getUserInfo(authorization: token) { result in
                DispatchQueue.main.async {
                    isLoading = false
                    
                    switch result {
                    case .success(let response):
                        userInfo = response.data
                        responseDetails = "获取成功: \(response.msg)"
                        
                        self.isShowToast = true
                        self.hintText = "登录成功".localized()
                        
                        apiKey = userInfo?.api_key ?? ""
                        username = userInfo?.user_name ?? ""
                        uid = userInfo?.uid ?? 0
                        
                        
                        PersistenceController.currentUserId = "\(uid)"
                        PersistenceController.login(uid: "\(uid)")
                        
                        NotificationCenter.default.post(name: .loginSuccess, object: nil)
                        
                        
                        config.isLogin = true
                        config.uid = uid
                        config.username = username
                        
                        
                        AppConfiguration.shared.OAIkey = apiKey
                        
                        if let selectedItem = ApiDataManager.shared.selectedItem {
                            
                            let item = ApiItem(name: selectedItem.name, host: selectedItem.host, apiKey: apiKey, model: selectedItem.model, apiNote: selectedItem.apiNote)
                            ApiDataManager.shared.updateItem(item)
                            
                        }
                        
                        dismiss()
                        
                    case .failure(let error):
                        errorMessage = "错误: \(error.localizedDescription)"
                        
                        self.isShowToast = true
                        self.hintText = errorMessage
                        
                        
                        if let networkError = error as? NetworkError,
                           case .apiError(let code, let message) = networkError {
                            responseDetails = "API错误: code=\(code), message=\(message)"
                        }
                    }
                     
                }
            }
        }
    
    
    
    // 刷新验证码函数
    private func refreshCaptcha() {
        let letters = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        captchaText = String((0..<4).map { _ in letters.randomElement()! })
    }
    
    
    
    
    // 登录方法
    private func login() {
        // 表单验证
        guard validateForm() else { return }
        
        // 模拟登录请求
        print("正在登录...")
        print("邮箱: \(email)")
        print("手机号: \(phoneNumber)")
        print("验证码: \(verificationCode)")
        print("记住密码: \(rememberPassword)")
        
        // 这里可以添加实际的登录API调用
        // NetworkManager.shared.login(email: email, password: password) { result in
        //     switch result {
        //     case .success(let user):
        //         // 登录成功处理
        //     case .failure(let error):
        //         // 登录失败处理
        //     }
        // }
    }
    
    // 表单验证
    private func validateForm() -> Bool {
        if selectedTab == 0 {
            // 邮箱登录验证
            if email.isEmpty {
                print("请输入邮箱".localized())
                return false
            }
            if !isValidEmail(email) {
                print("邮箱格式不正确".localized())
                return false
            }
        } else {
            // 手机号登录验证
            if phoneNumber.isEmpty {
                print("请输入手机号".localized())
                return false
            }
            if !isValidPhoneNumber(phoneNumber) {
                print("手机号格式不正确".localized())
                return false
            }
        }
        
        if verificationCode.isEmpty {
             
            
            print("请输入验证码".localized())
            return false
        }
        
        return true
    }
    
    // 邮箱格式验证
    private func isValidEmail(_ email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: email)
    }
    
    // 手机号格式验证
    private func isValidPhoneNumber(_ phone: String) -> Bool {
        let phoneRegEx = "^1[0-9]{10}$"
        let phonePred = NSPredicate(format:"SELF MATCHES %@", phoneRegEx)
        return phonePred.evaluate(with: phone)
    }
}
 
 
