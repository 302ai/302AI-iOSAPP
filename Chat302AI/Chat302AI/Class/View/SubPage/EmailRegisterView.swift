//
//  RegisterView.swift
//  Chat302AI
//
//  Created by Adswave on 2025/9/4.
//

import SwiftUI
import AlertToast


struct EmailRegisterView: View {
    
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.dismiss) var dismiss
    @State private var isShowingPhoneRegisterView = false
    
    @State private var username = ""
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var captchaImage = UIImage(named: "刷新.png")
    @State private var verificationCode = ""
    @State private var emailCode = ""
    @State private var isPasswordVisible = false
    @State private var isPasswordVisible2 = false
    
    
    @State private var showingCountryPicker = false
    
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var requestInfo: String = ""
    @State private var responseCode: String = ""
    
    
    @State private var countdown = 0
    @State private var timer: Timer? = nil
    
    @State var isFromPhone : Bool
     
    let countryCodes = ["+86", "+1", "+93", "+44", "+81", "+82", "+33", "+49"]
    
    @State private var isShowToast = false
    @State private var hintText: String?
    
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                Spacer()
                    .frame(height: 40)
                // App标题
                HStack {
                    Spacer()
                        .frame(width: 20)
                    ZStack(alignment: .topTrailing) {
                        Text("创建账号".localized())
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .padding(5)
                        
                        Image("圈")
                            .resizable()
                            .frame(width: 20, height: 20)
                    }
                    Spacer()
                }
                // 用户名
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Image(systemName: "person")
                        
                        Text("用户名".localized())
                            .font(.headline)
                            .foregroundColor(.primary)
                        Spacer()
                    }
                    
                    TextField("请输入用户名".localized(), text: $username)
                        .textFieldStyle(PlainTextFieldStyle())
                        .padding(.horizontal, 12)
                        .padding(.vertical, 10)
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(6)
                }
                .padding(.horizontal, 30)
                 
                // 邮箱注册
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Image(systemName: "at")
                        Text("邮箱".localized())
                            .font(.headline)
                            .foregroundColor(.primary)
                        Spacer()
                    }
                    
                    TextField("请输入邮箱".localized(), text: $email)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                        .textFieldStyle(PlainTextFieldStyle())
                        .padding(.horizontal, 12)
                        .padding(.vertical, 10)
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(6)
                }
                .padding(.horizontal, 30)
                
                // 密码
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        
                        Image(systemName: "exclamationmark.lock")
                        
                        Text("密码".localized())
                            .font(.headline)
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
                .padding(.horizontal, 30)
                
                // 图形验证码
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        
                        Image(systemName: "checkmark.shield") 
                        Text("图形验证码".localized())
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        Spacer()
                         
                    }
                    HStack{
                        TextField("请输入验证码".localized(), text: $verificationCode)
                            .textFieldStyle(PlainTextFieldStyle())
                            .padding(.horizontal, 12)
                            .padding(.vertical, 10)
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(6)
                        
                        // 验证码图像
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color.gray.opacity(0.3))
                            .frame(width: 100, height: 42)
                            .overlay(
                                Image(uiImage: captchaImage!)
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 100, height: 42)
                                    .onTapGesture {
                                        fetchImage()
                                    }
                            )
                    }
                }
                .padding(.horizontal, 30)
                
                
                // 邮箱验证码
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Image(systemName: "key")
                        Text("验证码".localized())
                            .font(.headline)
                            .foregroundColor(.primary)
                        Spacer()
                    }
                    
                    HStack {
                        TextField("请输入验证码".localized(), text: $emailCode)
                            .textFieldStyle(PlainTextFieldStyle())
                            .padding(.horizontal, 12)
                            .padding(.vertical, 10)
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(6)
                        
                        Spacer()
                        
                        Button(action: {
                            // 获取验证码操作
                            
                            fetchEmailCode()
                        }) {
                            if countdown > 0 {
                                Text("重新获取".localized()+"(\(countdown)s)")
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
                        //.padding(.top, 10) // 顶部间距调小
                    }
                }
                .padding(.horizontal, 30)
                .onDisappear {
                    // 视图消失时停止计时器
                    timer?.invalidate()
                    timer = nil
                }

                
                
                // 注册按钮
                Button(action: {
                    // 注册操作
                    register()
                }) {
                    Text("注册".localized())
                        .font(.title3)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color(hex: "#8E47F1"))
                        .cornerRadius(8)
                }
                .padding(.horizontal, 30)
                .padding(.top, 20)
                
                
                // 已有账号引导
                HStack {
                    Text("已有账号？".localized())
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    
                    Button("马上登录".localized()) {
                        // 回到登录页面
                        presentationMode.wrappedValue.dismiss()
                    }
                    .font(.subheadline)
                    .foregroundColor(Color(hex: "#8E47F1"))
                }
                .padding(.top, 20)
                
                
                // 其他注册方式
                VStack(spacing: 15) {
                    Text("其他注册方式".localized())
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    
                    HStack(spacing: 30) {
                        // 第三方注册图标
                        Button(action: {
                            // 手机号注册
                            
                            if isFromPhone {
                                dismiss()
                            }else{
                                isShowingPhoneRegisterView = true
                            }
                            
                        }) {
                            Circle()
                                .fill(Color.gray.opacity(0.2))
                                .frame(width: 50, height: 50)
                                .overlay(
                                    Image(systemName: "platter.filled.bottom.iphone")
                                        .foregroundColor(.purple)
                                )
                        }
                        /*
                        Button(action: {
                            // QQ注册
                        }) {
                            Circle()
                                .fill(Color.gray.opacity(0.2))
                                .frame(width: 50, height: 50)
                                .overlay(
                                    Image(systemName: "photo.on.rectangle")
                                        .foregroundColor(.blue)
                                )
                        }*/
                    }
                }
                .padding(.top, 30)
                .padding(.bottom, 30)
                
            }
            
            .sheet(isPresented: $isShowingPhoneRegisterView) {
                PhoneRegisterView(isFromEmail: true)
            }
            
            .toast(isPresenting: $isShowToast){
                
                AlertToast(displayMode: .alert, type: .regular, title: hintText)
            }
            
            .onAppear{
                fetchImage()
            }
        }
        .scrollDismissesKeyboard(.immediately)
        .onTapGesture {
            // 点击空白处收起键盘
            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        }
    }
    
    
    
    // 获取验证码的网络请求
    private func fetchEmailCode() {
        print("发送邮箱验证码请求...")
        
        if email.isEmpty {
            isShowToast = true
            hintText = "请输入邮箱".localized()
            return
        }
        
        if verificationCode.isEmpty {
            isShowToast = true
            hintText = "请输入图形验证码".localized()
            return
        }
        
         
        NetworkManager.shared.sendEmailCode(email: email, captcha: verificationCode, code: responseCode) { result in
            
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
    
    
    
    
    // 注册方法
    private func register() {
        // 表单验证
        guard validateForm() else { return }
        
        // 模拟注册请求
        print("正在注册...")
        print("用户名: \(username)")
        print("邮箱: \(email)")
        print("密码: \(password)")
        print("验证码: \(verificationCode)")
         
        
        if password.count < 8 {
            isShowToast = true
            hintText = "密码不能少于8位".localized()
            return
        }
        
        
        NetworkManager.shared.registerWithEmail(
            email: email,
            password: password,
            name: username,
            captcha: verificationCode,
            code: responseCode,
            emailCode: emailCode
        ) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    if response.code == 0 {
                        print("注册成功: \(response.msg)")
                        
                        isShowToast = true
                        hintText = "注册成功!".localized()
                         
                        if let userData = response.data {
                            print("Token: \(userData.token ?? "")")
                            
                            if let token = response.data?.token {
                                 
                                AppConfiguration.shared.userToken = token
                                 
                                NotificationCenter.default.post(
                                    name: .needGetUserInfo,
                                    object: userData.token
                                )
                            }
                            
                            dismiss();
                            if isFromPhone {
                                dismiss()
                            }
                        }
                    } else {
                        print("注册失败: \(response.msg)")
                        hintText = "注册失败_\(response.msg):\(response.code)"
                        
                        if response.code == 605 {
                            hintText = "账号已存在".localized()
                        }
                        if response.code == 900 {
                            hintText = "验证码错误".localized()
                        }
                        
                        isShowToast = true
                    }
                case .failure(let error):
                    print("注册请求失败: \(error.localizedDescription)")
                    
                    hintText = "\(error.localizedDescription)"
                    isShowToast = true
                }
            }
        }
    }
    
    
    
    
    
    // 开始倒计时
       private func startCountdown() {
           countdown = 60 // 设置倒计时时间（秒）
           
           // 先停止之前的计时器
           timer?.invalidate()
           
           // 创建新的计时器
           timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
               if countdown > 1 {
                   countdown -= 1
               } else {
                   countdown = 0
                   timer?.invalidate()
                   timer = nil
               }
           }
       }
    
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
                //self.isLoading = false
                
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
    
    
    
    
    // 表单验证
    private func validateForm() -> Bool {
        if username.isEmpty {
            print("请输入用户名")
            
            hintText = "请输入用户名".localized()
            isShowToast = true
            return false
        }
        
        // 邮箱注册验证
        if email.isEmpty {
            print("请输入邮箱")
            hintText = "请输入邮箱".localized()
            isShowToast = true
            return false
        }
        if !isValidEmail(email) {
            print("邮箱格式不正确")
            hintText = "邮箱格式不正确".localized()
            isShowToast = true
            return false
        }
        
        if password.isEmpty {
            print("请输入密码")
            hintText = "请输入密码".localized()
            isShowToast = true
            return false
        }
        
        if password.count < 6 {
            print("密码长度至少6位")
            
            hintText = "密码长度至少6位".localized()
            isShowToast = true
            
            return false
        }
        
        if password != confirmPassword {
            print("两次输入的密码不一致")
            hintText = "两次输入的密码不一致".localized()
            isShowToast = true
            return false
        }
        
        if verificationCode.isEmpty {
            print("请输入验证码")
            hintText = "请输入验证码".localized()
            isShowToast = true
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


 
