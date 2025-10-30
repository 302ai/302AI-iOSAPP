//
//  PhoneRegisterView.swift
//  Chat302AI
//
//  Created by Adswave on 2025/9/9.
//

import SwiftUI
import CountryPicker
import AlertToast

struct PhoneRegisterView: View {
    
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.dismiss) var dismiss
    @State private var username = ""
    @State private var phoneNumber = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var captchaImage = UIImage(named: "刷新.png")
    @State private var verificationCode = ""
    @State private var msgCode = ""
    @State private var isPasswordVisible = false
    @State private var isPasswordVisible2 = false
    
    @State private var showingCountryPicker = false
    @State private var isShowingEmailRegisterView = false
     
    @State private var countryCode = "+86"
    @State var country : Country? = Country(countryCode: "CN")
     
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var requestInfo: String = ""
    @State private var responseCode: String = ""
     
    @State private var countdown = 0
    @State private var timer: Timer? = nil
    
    @State var isFromEmail : Bool
    
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
                            
                            CountryPickerView( selectedCountry: $country)
                        }
                        
                        
                        
                        HStack(spacing: 0) {
                            Text(country?.dialingCode ?? "+86")
                                .foregroundColor(.primary)
                                .padding(.leading, 12)
                                .frame(width: 60, alignment: .leading)
                            
                            TextField("请输入手机号".localized(), text: $phoneNumber)
                                .keyboardType(.phonePad)
                                .textFieldStyle(PlainTextFieldStyle())
                                .padding(.trailing, 12)
                                .padding(.vertical, 8)
                                 
                        }
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(6)
                        
//                        .padding(8)
//                        .background(Color.gray.opacity(0.1))
//                        .cornerRadius(4)
                    }
                    
                    //if showPhoneError {
                    //    Text("请输入手机号")
                    //        .font(.subheadline)
                    //        .foregroundColor(.red)
                    //        .transition(.opacity)
                    //}
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
                    
//                    SecureField("请输入密码", text: $password)
//                        .textFieldStyle(PlainTextFieldStyle())
//                        .padding(.horizontal, 12)
//                        .padding(.vertical, 10)
//                        .background(Color.gray.opacity(0.1))
//                        .cornerRadius(6)
                    
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
                        
                        // 验证码图
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
                
                
                // 短信验证码
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Image(systemName: "key")
                        Text("验证码".localized())
                            .font(.headline)
                            .foregroundColor(.primary)
                        Spacer()
                    }
                    
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
                            fetchMsgCode()
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
                    Text("立即注册".localized())
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
                            
                            if isFromEmail {
                                dismiss()
                            }else{
                                isShowingEmailRegisterView = true
                            }
                            
                            
                        }) {
                            Circle()
                                .fill(Color.gray.opacity(0.2))
                                .frame(width: 50, height: 50)
                                .overlay(
                                    Image(systemName: "envelope")
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
            
            .sheet(isPresented: $isShowingEmailRegisterView) {
                EmailRegisterView(isFromPhone: true)
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
       
       // 获取验证码的网络请求
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
                       } else {
                           self.hintText = "\(response.msg)"
                           self.isShowToast = true
                       }
                       
                   case .failure(let error):
                       print("发送失败: \(error.localizedDescription)")
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
        print("手机: \(phoneNumber)")
        print("密码: \(password)")
        print("图形验证码: \(verificationCode)")
        print("验证码: \(msgCode)")
        
        let phone = "\(phoneNumber)"
        
        if password.count < 8 {
            isShowToast = true
            hintText = "密码不能少于8位".localized()
            return
        }
        
        
        NetworkManager.shared.registerWithPhone2(name: username, password: password, confirmPassword: confirmPassword, sms_code: msgCode, phone_number: phone) { result in
            switch result {
            case .success(let response):
                if response.code == 0 {
                    print("注册成功: \(response.msg)")
                    if let userData = response.data {
                        
                        print("注册成功response:\(response)")
                        print("Token: \(userData.token ?? "")")
                          
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
                            if isFromEmail {
                                dismiss()
                            }
                        }
                    }
                } else {
                    
                    print("注册失败: \(response.msg)")
                    hintText = "\(response.msg):\(response.code)"
                    if response.code == 900 {
                        hintText = "验证码错误".localized()
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
        
//        NetworkManager.shared.registerWithPhone(name: username, password: password, confirmPassword: confirmPassword, smsCode: msgCode, phoneNumber: phone) { result in
//            switch result {
//                    case .success(let response):
//                        if response.code == 0 {
//                            print("注册成功: \(response.msg)")
//                            if let userData = response.data {
//                                
//                                print("注册成功response:\(response)")
//                                print("Token: \(userData.token ?? "")")
//                                
//                                dismiss(); if isFromEmail { dismiss() }
//                                
//                                NotificationCenter.default.post(
//                                    name: .needGetUserInfo,
//                                    object: userData.token
//                                )
//                                
//                            }
//                        } else {
//                            
//                            print("注册失败: \(response.msg)")
//                            hintText = "\(response.msg):\(response.code)"
//                            if response.code == 900 {
//                                hintText = "验证码错误".localized()
//                            }
//                            
//                            isShowToast = true
//                            
//                        }
//                    case .failure(let error):
//                
//                        print("注册请求失败: \(error.localizedDescription)")
//                        hintText = error.localizedDescription
//                        isShowToast = true
//                    }
//        }
        
         
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
            
            isShowToast = true
            hintText = "请输入用户名".localized()
             
            return false
        }
        
        // 邮箱注册验证
        if phoneNumber.isEmpty {
            print("请输入手机号")
            
            isShowToast = true
            hintText = "请输入手机号".localized()
            return false
        }
        if !isValidPhoneNumber(phoneNumber) {
            print("手机号格式不正确")
            isShowToast = true
            hintText = "手机号格式不正确".localized()
            return false
        }
        
        if password.isEmpty {
            print("请输入密码")
            isShowToast = true
            hintText = "请输入密码".localized()
            return false
        }
        
        if password.count < 6 {
            print("密码长度至少6位")
            isShowToast = true
            hintText = "密码长度至少6位".localized()
            return false
        }
        
        if password != confirmPassword {
            print("两次输入的密码不一致")
            isShowToast = true
            hintText = "两次输入的密码不一致".localized()
            return false
        }
        
        if verificationCode.isEmpty {
            print("请输入图形验证码")
            isShowToast = true
            hintText = "请输入图形验证码".localized()
            return false
        }
        
        if msgCode.isEmpty {
            print("请输入短信验证码")
            isShowToast = true
            hintText = "请输入短信验证码".localized()
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


// 国家区号选择器视图
struct CountryCodePicker: View {
    @Binding var selectedCode: String
    let countryCodes: [String]
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            List(countryCodes, id: \.self) { code in
                Button(action: {
                    selectedCode = code
                    presentationMode.wrappedValue.dismiss()
                }) {
                    HStack {
                        Text(code)
                            .foregroundColor(.primary)
                        Spacer()
                        if code == selectedCode {
                            Image(systemName: "checkmark")
                                .foregroundColor(.blue)
                        }
                    }
                }
            }
            .navigationTitle("选择国家/地区")
            .navigationBarItems(trailing: Button("取消") {
                presentationMode.wrappedValue.dismiss()
            })
        }
    }
}


