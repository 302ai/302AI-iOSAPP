//
//  ForgetPwdView.swift
//  Chat302AI
//
//  Created by Adswave on 2025/10/10.
//

//
//  SigninView.swift
//  Chat302AI
//
//  Created by Adswave on 2025/10/9.
//

import SwiftUI
import CountryPicker
import AlertToast



struct ForgetPwdView: View {
    
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
    @State private var confirmPassword = ""
    
    @FocusState private var isPasswordFocused: Bool
    @State private var showPasswordError = false
    
    @State private var isPasswordVisible = false
    @State private var isPasswordVisible2 = false
    
    //手机号
    @State private var phoneNumber = ""
    @FocusState private var isPhoneFocused: Bool
    @State private var showPhoneError = false
    @State private var showingCountryPicker = false
    @State private var countryCode = "+86"
    @State var country : Country? = Country(countryCode: "CN")
    
    
    
    //验证码
    @State private var verificationCode = ""  //图形码
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
     
    @State private var countdown = 0
    @State private var timer: Timer? = nil
    @State private var msgCode = ""
    
    
    var body: some View {
        NavigationView {
            
//            Color.clear
//                .overlay(
            
            ScrollView{
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
                        

                        
                        // 登录表单区域
                        VStack(spacing: 20) {
                            
                            VStack{
                                // 登录方式选择
                                HStack(spacing: 100) {
                                    loginButton(title: "短信验证".localized(), index: 0)
                                    loginButton(title: "邮箱验证".localized(), index: 1)
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
                            
                            
                            
                            // 登录表单
                            if selectedTab == 0 {
                                //短信登录
                                VStack(alignment: .leading, spacing: 8) {
                                    
                                    HStack{
                                        Text("手机号".localized())
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
                                    }
                                    
                                }
                                .padding(.horizontal, 12)
                                
                                
                                
                                
                            } else {
                                
                                // 密码登录
                                VStack(alignment: .leading, spacing: 8) {
                                    
                                    HStack{
                                        Text("邮箱".localized())
                                        Spacer()
                                    }
                                    TextField("请输入邮箱".localized(), text: $email)
                                        .textFieldStyle(PlainTextFieldStyle())
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 10)
                                        .background(Color.gray.opacity(0.1))
                                        .cornerRadius(6)
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
                            }
                            
                                // 验证码   // 图形验证码
                                VStack(alignment: .leading, spacing: 8) {
                                    HStack {
                                        Text("验证码".localized())
                                            .foregroundColor(.primary)
                                        Spacer()
                                    }
                                    if selectedTab == 0 {
                                        HStack {
                                            TextField("图形验证码".localized(), text: $verificationCode)
                                                .textFieldStyle(PlainTextFieldStyle())
                                                .padding(.horizontal, 12)
                                                .padding(.vertical, 10)
                                                .background(Color.gray.opacity(0.1))
                                                .cornerRadius(6)
                                                .focused($isVerificationCodeFocused)
                                                .onChange(of: isVerificationCodeFocused) { isFocused in
                                                    if !isFocused && verificationCode.isEmpty {
                                                        showVerificationCodeError = true
                                                    } else {
                                                        showVerificationCodeError = false
                                                    }
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
                                }.padding(.horizontal, 12)
                           
                             
                            VStack(alignment: .leading, spacing: 8) {
                                 
                                // 短信/邮件   验证码
                                HStack {
                                    TextField("请输入验证码".localized(), text: $msgCode)
                                        .textFieldStyle(PlainTextFieldStyle())
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 10)
                                        .background(Color.gray.opacity(0.1))
                                        .cornerRadius(6)
                                    
                                    Spacer()
                                    
                                    Button(action: {
                                        // 获取验证码操作
                                        if selectedTab == 0 {
                                            fetchMsgCode()
                                        }else{
                                            fetchEmailCode()
                                        }
                                    }) {
                                        if countdown > 0 {
                                            Text("重新获取(\(countdown)s)")
                                                .font(.system(size: 14)) // 字体调小
                                                .foregroundColor(.white)
                                                .frame(width: 100, height: 40) // 固定宽高
                                                .background(Color.gray)
                                                .cornerRadius(6) // 圆角调小
                                        } else {
                                            Text("获取验证码".localized())
                                                .font(.system(size: 14)) // 字体调小
                                                .foregroundColor(.white)
                                                .frame(width: 100, height: 40) // 固定宽高
                                                .background(Color(hex: "#8E47F1"))
                                                .cornerRadius(6) // 圆角调小
                                        }
                                    }
                                    .disabled(countdown > 0)
                                    .padding(.horizontal, 5) // 水平间距调小
                                }
                            }
                            .padding(.horizontal, 12)
                            .onDisappear {
                                // 视图消失时停止计时器
                                timer?.invalidate()
                                timer = nil
                            }
  
                            
                            
                            // 密码
                            VStack(alignment: .leading, spacing: 8) {
                                HStack {
                                    Text("密码".localized())
                                        .foregroundColor(.primary)
                                    Spacer()
                                }
                                HStack {
                                    Group{
                                        if isPasswordVisible {
                                            TextField("请输入密码".localized(), text: $password)
                                            
                                        } else {
                                            SecureField("请输入密码".localized(), text: $password)
                                        }
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
                                
                                
                                HStack {
                                    Group{
                                        if isPasswordVisible2 {
                                            TextField("再输入一次密码".localized(), text: $confirmPassword)
                                            
                                        } else {
                                            SecureField("再输入一次密码".localized(), text: $confirmPassword)
                                        }
                                    }
                                    
                                    Button(action: {
                                        isPasswordVisible2.toggle()
                                    }) {
                                        Image(systemName: isPasswordVisible2 ? "eye" : "eye.slash")
                                            .foregroundColor(.gray)
                                    }
                                }
                                .textFieldStyle(PlainTextFieldStyle())
                                .padding(.horizontal, 12)
                                .padding(.vertical, 10)
                                .background(Color.gray.opacity(0.1))
                                .cornerRadius(6)
                            }
                            .padding(.horizontal, 12)

                            
                            // 登录按钮
                            HStack{
                                Button(action: {
                                    dismiss()
                                }) {
                                    Text("回到登录".localized())
                                        .font(.headline)
                                        .foregroundColor(Color.init(hex: "#8E47F1")) // 字体改成紫色
                                        .frame(maxWidth: .infinity)
                                        .padding()
                                        .background(Color.white) // 背景改成白色
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 8)
                                                .stroke(Color.init(hex: "#8E47F1"), lineWidth: 1) // 紫色边框1，圆角8
                                        )
                                }
                                .padding(.horizontal, 12)
                                .padding(.top, 20)
                                
                                Spacer()
                                
                                // 修改密码
                                Button(action: {
                                    //action
                                    if selectedTab ==  0 {
                                        forgetPhonePasswdRequest()
                                    }else{
                                        forgetEmailPasswdRequest()
                                    }
                                    
                                    
                                    
                                }) {
                                    Text("修改密码".localized())
                                        .font(.headline)
                                        .foregroundColor(.white)
                                        .frame(maxWidth: .infinity)
                                        .padding()
                                        .background(Color.init(hex: "#8E47F1"))
                                        .cornerRadius(8)
                                }
                                .padding(.horizontal, 12)
                                .padding(.top, 20)
                            }
                            
                            
                            
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
                        
                        
                        
                        /*
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
                        */
                    }
                    .padding()
                }
            }
            .onTapGesture {
                // 点击空白处收起键盘
                UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
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
    
    // 开始倒计时
    private func startCountdown() {
        print("✅ startCountdown 被调用")
        
        countdown = 60
        timer?.invalidate()
        
        print("✅ 创建新 Timer")
        
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) {  timer in
             
            
            print("✅ Timer 执行，当前 countdown: \(self.countdown)")
            
            if self.countdown > 1 {
                self.countdown -= 1
                print("✅ 倒计时更新: \(self.countdown)")
            } else {
                self.countdown = 0
                timer.invalidate()
                self.timer = nil
                print("✅ 倒计时结束")
            }
        }
        
        // 确保 Timer 在滚动等情况下也能工作
        if let timer = timer {
            RunLoop.current.add(timer, forMode: .common)
        }
    }
    
    // 获取短信验证码 请求
    private func fetchMsgCode() {
        print("发送手机验证码请求...")
        
        if phoneNumber.isEmpty {
            isShowToast = true
            hintText = "请输入手机号".localized()
            return
        }
        
        if verificationCode.isEmpty {
            isShowToast = true
            hintText = "请输入图形验证码".localized()
            return
        }
        
        
        
        let phone = "\(country?.dialingCode ?? "+86")\(phoneNumber)"
        
        //验证码倒计时
        NetworkManager.shared.sendSMS(mobile: phone, captcha: verificationCode, code: responseCode) { result in
            // 确保回到主线程更新 UI
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    print("发送成功: \(response.msg)")
                    
                    if response.code == 0 {
                        self.startCountdown()
                        self.isShowToast = true
                        self.hintText = "发送成功!".localized()
                    } else if response.code == 900 {
                        self.isShowToast = true
                        self.hintText = "图形码错误"
                        fetchImage()
                    } else {
                        self.hintText = "\(response.msg)"
                        self.isShowToast = true
                        fetchImage()
                    }
                    
                case .failure(let error):
                    print("发送失败: \(error.localizedDescription)")
                }
            }
        }
        
    }
    
    
    // 获取邮箱验证码 请求
    private func fetchEmailCode() {
        print("发送邮箱验证码请求...")
        
        if email.isEmpty {
            isShowToast = true
            hintText = "请输入邮箱".localized()
            return
        }
         
        
        NetworkManager.shared.sendResetEmailCode(email: email) { result in
            
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    if response.code == 0 {
                        print("邮箱验证码发送成功: \(response.msg)")
                        startCountdown()
                        hintText = "发送成功!".localized()
                        isShowToast = true
                        
                    } else {
                        print("邮箱验证码发送失败: \(response.msg)")
                        hintText = "发送失败\(response.msg):\(response.code)"
                        
                        if response.code == 900 {
                            hintText = "图形验证失败".localized()
                        }
                        
                        isShowToast = true
                        
                    }
                case .failure(let error):
                    print("邮箱验证码请求失败: \(error.localizedDescription)")
                    
                    hintText = "\(error.localizedDescription)"
                    isShowToast = true
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
    
    // 获取图片 验证码
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
     
    
    //email 忘记密码
    private func forgetEmailPasswdRequest(  ) {
        NetworkManager.shared.resetEmailPwdPutRequest(email: email,
                                                   email_code: msgCode,
                                                   password: password,
                                                   confirmPassword: confirmPassword ) { result in
            switch result {
            case .success(let response):
                if response.code == 0 {
                    print("验证码登录成功: \(response.msg)")
                    if let userData = response.data {
                        
                        print("验证码登录成功 response:\(response)")
                        print("Token: \(userData.token ?? "")")
                        
                        hintText = "修改成功".localized()
                        isShowToast = true
                    
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
    
                            dismiss();
                        }
                        
//                        DispatchQueue.main.async {
//                            NotificationCenter.default.post(
//                                name: .needGetUserInfo,
//                                object: userData.token
//                            )
//                        }
                        
                    }
                } else {
                    
                    print("验证码登录失败: \(response.msg)")
                    hintText = "\(response.msg):\(response.code)"
                    if response.code == 900 {
                        hintText = "验证码错误".localized()
                        fetchImage()
                    }
                    
                    if response.code == 605 {
                        hintText = "用户已存在".localized()
                    }
                    
                    
                    isShowToast = true
                    
                }
            case .failure(let error):
                
                print("注册请求失败: \(error.localizedDescription)")
                hintText = error.localizedDescription
                isShowToast = true
            }
        }
        
    }
        
        
    //手机号 忘记密码
    private func forgetPhonePasswdRequest() {
        NetworkManager.shared.resetPhonePwdRequest(phone_number: phoneNumber,
                                                   password: password,
                                                   sms_code: msgCode) { result in
            switch result {
            case .success(let response):
                if response.code == 0 {
                    print("验证码登录成功: \(response.msg)")
                    if let userData = response.data {
                        
                        print("验证码登录成功 response:\(response)")
                        print("Token: \(userData.token ?? "")")
                        
                        dismiss();
                        
                        DispatchQueue.main.async {
                            NotificationCenter.default.post(
                                name: .needGetUserInfo,
                                object: userData.token
                            )
                        }
                        
                    }
                } else {
                    
                    print("验证码登录失败: \(response.msg)")
                    hintText = "\(response.msg):\(response.code)"
                    if response.code == 900 {
                        hintText = "验证码错误".localized()
                        fetchImage()
                    }
                    
                    if response.code == 605 {
                        hintText = "用户已存在".localized()
                    }
                    
                    
                    isShowToast = true
                    
                }
            case .failure(let error):
                
                print("注册请求失败: \(error.localizedDescription)")
                hintText = error.localizedDescription
                isShowToast = true
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
              phone: "\(country?.dialingCode ?? "+86")\(phoneNumber)",
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
 
