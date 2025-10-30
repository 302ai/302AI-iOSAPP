//
//  NetworkManager.swift
//  GPTalks
//
//  Created by Adswave on 2025/3/31.
//

import SwiftUI



// 内容类型枚举
enum ContentType {
    case json
    case formURLEncoded
}



struct ModelResponse: Codable {
    
    let data : [AI302Model]?
}

struct APIResponse: Codable {
    let code: Int
    let msg: String
    let data: ResponseData
    
    struct ResponseData: Codable {
        let error: String
        let stdout: String
    }
}



// 自定义错误类型
enum NetworkError: Error, LocalizedError {
    case invalidURL
    case invalidResponse
    case httpError(statusCode: Int)
    case noData
    case encodingError
    case decodingError
    case unexpectedResponse(String)
    case apiError(code: Int, message: String)
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "无效的URL"
        case .invalidResponse:
            return "无效的响应"
        case .httpError(let statusCode):
            return "HTTP错误: \(statusCode)"
        case .noData:
            return "没有接收到数据"
        case .encodingError:
            return "请求参数编码失败"
        case .decodingError:
            return "响应数据解析失败"
        case .unexpectedResponse(let details):
            return "意外的响应格式: \(details)"
        case .apiError(let code, let message):
            return "API错误 (\(code)): \(message)"
        }
    }
}


// 网络响应模型
struct NetworkResponse {
    let data: Data
    let code: String
}

 
protocol LoginRequest: Codable, CustomStringConvertible {
    var password: String { get }
    var ref: String { get }
    var event: String { get }
    var captcha: String { get }
    var code: String { get }
    var login_from: String { get }
}




struct LoginEmailRequest: LoginRequest {
    let email: String
    let password: String
    let ref: String
    let event: String
    let captcha: String
    let code: String
    let login_from: String
    
    var description: String {
        return """
        LoginEmailRequest:
          email: \(email)
          password: \(password)
          ref: \(ref)
          event: \(event)
          captcha: \(captcha)
          code: \(code)
          login_from: \(login_from)
        """
    }
}

 
struct LoginPhoneRequest: LoginRequest {
    let phone: String
    let password: String
    let ref: String
    let event: String
    let captcha: String
    let code: String
    let login_from: String
    
    var description: String {
        return """
        LoginPhoneRequest:
          phone: \(phone)
          password: \(password)
          ref: \(ref)
          event: \(event)
          captcha: \(captcha)
          code: \(code)
          login_from: \(login_from)
        """
    }
}
 
 

// 网络响应模型
struct LoginResponse: Codable {
    let code: Int
       let msg: String
       let data: ResponseData?
       
       struct ResponseData: Codable {
           let token: String?
       }
       
       var success: Bool {
           return code == 0
       }
}


 
struct MsgLoginResponse: Codable {
    let code: Int
    let msg: String
    let data: TokenData?
}

struct TokenData: Codable {
    let token: String
}


// 定义响应模型
struct SMSResponse: Codable {
    let code: Int
    let msg: String
    let data: [String: String]? // 根据实际数据结构调整
}

// 定义请求参数模型
struct SMSRequest: Codable {
    let mobile: String
    let captcha: String
    let code: String
}


struct EmailRegisterRequest: Codable {
    let email: String
    let password: String
    let name: String
    let captcha: String
    let code: String
    let emailCode: String
    
    enum CodingKeys: String, CodingKey {
        case email
        case password
        case name
        case captcha
        case code
        case emailCode = "email_code"
    }
}
 


struct RegisterPhoneRequest: Codable {
    let name: String
    let password: String
    let confirmPassword: String
    let sms_code: String
    let phone_number: String
     
}

struct MsgCodeLoginRequest: Codable {
    let sms_code: String
    let phone_number: String
     
}

struct AllLoginRequest: Codable {
    
    let account: String
    let password: String
    let captcha: String
    let code: String
}

struct ResetPhonePwdRequest: Codable {

    // /user/reset_pw
    
    let phone_number: String
    let password: String
    let sms_code: String
    
}

struct ResetEmailPwdRequest: Codable {
 
    // /user/reset_pw_with_code
    
    let email: String
    let email_code: String
    
    let password: String
    let confirmPassword: String
}


struct RegisterResponse: Codable {
    let code: Int
    let msg: String
    let data: RegisterData?
}

struct RegisterData: Codable {
    let token: String?
    
    enum CodingKeys: String, CodingKey {
        case token
    }
}


 
struct UserPasswdLoginRequest: LoginRequest {
    let account: String
    let password: String
    let ref: String
    let event: String
    let captcha: String
    let code: String
    let login_from: String
    let phone: String
    
    // CustomStringConvertible 实现
    var description: String {
        return "UserLoginRequest(account: \(account), event: \(event), login_from: \(login_from))"
    }
}

  


// 邮箱验证码请求参数模型
struct EmailCodeRequest: Codable {
    let email: String
    let captcha: String
    let code: String
}

struct ResetEmailCodeRequest: Codable {
    let email: String
}


// 邮箱验证码响应模型
struct EmailCodeResponse: Codable {
    let code: Int
    let msg: String
    let data: [String: String]? // 根据实际数据结构调整
}


// 短信登录 请求参数模型
struct SMSLoginRequest: Codable {
    let sms_code: String
    let phone_number: String
}

// 短信登录 响应模型
struct SMSPhoneResponse: Codable {
    let code: Int
       let msg: String
       let data: ResponseData?
       
       struct ResponseData: Codable {
           let token: String?
       }
       
       var success: Bool {
           return code == 0
       }
}



 
struct EmailCodeFormRequest {
    let email: String
    let captcha: String
    let code: String
    
    // 转换为字典格式（如果需要特定的字段名映射）
    var formDictionary: [String: String] {
        return [
            "email": email,
            "captcha": captcha,
            "code": code
        ]
    }
}

//记录充值
struct RecordRechargeRequest: Codable {
    let data: String
    let uid: String
}


//充值 返回数据
struct RecordRechargeResponse: Codable {
    // 根据实际API响应字段定义
    let code: Int
    let msg: String
    let data: [String: String]?
}
 


class NetworkManager: ObservableObject {
    
    static let shared = NetworkManager()
    
    @Published var models: [AI302Model] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    // 定义回调类型（成功返回 [AI302Model]，失败返回 Error）
    typealias FetchModelsCompletion = (Result<[AI302Model], Error>) -> Void
    
    
    private let baseURL = "https://dash-api.302.ai"
//    private let baseURL = "https://test-api2.gpt302.com"
    
    
    //private let fetchImageUrl = "https://dash-api.302.ai/proxy/static/image"
    
    
    
    
    private init() {}
    
    // 生成随机字符串
    func generateRandomString(length: Int) -> String {
        let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"
        return String((0..<length).map{ _ in letters.randomElement()! })
    }
    
      
    // 通用的 POST 请求方法
    func postRequest<T: Codable, U: Codable>(
            endpoint: String,
            body: T,
            contentType: ContentType = .json, // 默认使用 JSON
            responseType: U.Type,
            completion: @escaping (Result<U, Error>) -> Void
    ) {
        let urlString = baseURL + endpoint
        
        guard let url = URL(string: urlString) else {
            completion(.failure(NetworkError.invalidURL))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.timeoutInterval = 30
        
        // 根据内容类型设置请求头和请求体
        switch contentType {
        case .json:
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            do {
                let jsonData = try JSONEncoder().encode(body)
                request.httpBody = jsonData
                request.setValue(AppConfiguration.shared.userToken, forHTTPHeaderField: "Authorization")
                
                if let jsonString = String(data: jsonData, encoding: .utf8) {
                    print("JSON 请求体: \(jsonString)")
                }
            } catch {
                completion(.failure(NetworkError.encodingError))
                return
            }
            
        case .formURLEncoded:
            request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
            // 将 Codable 对象转换为字典，然后转换为表单格式
            do {
                let jsonData = try JSONEncoder().encode(body)
                if let dictionary = try JSONSerialization.jsonObject(with: jsonData) as? [String: Any] {
                    let formDataString = dictionary
                        .compactMap { key, value in
                            guard let stringValue = value as? String else { return nil }
                            return "\(key)=\(stringValue.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")"
                        }
                        .joined(separator: "&")
                    
                    request.httpBody = formDataString.data(using: .utf8)
                    print("表单请求体: \(formDataString)")
                }
            } catch {
                completion(.failure(NetworkError.encodingError))
                return
            }
        }
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                completion(.failure(NetworkError.invalidResponse))
                return
            }
            
            print("HTTP状态码: \(httpResponse.statusCode)")
            
            guard (200...299).contains(httpResponse.statusCode) else {
                completion(.failure(NetworkError.httpError(statusCode: httpResponse.statusCode)))
                return
            }
            
            guard let data = data else {
                completion(.failure(NetworkError.noData))
                return
            }
            
            if let responseString = String(data: data, encoding: .utf8) {
                print("响应: \(responseString)")
            }
            
            do {
                let decodedResponse = try JSONDecoder().decode(U.self, from: data)
                completion(.success(decodedResponse))
            } catch {
                print("解码错误: \(error)")
                completion(.failure(NetworkError.decodingError))
            }
        }.resume()
    }
    
    
    
    
    // 通用的 PUT 请求方法
    func putRequest<T: Codable, U: Codable>(
        endpoint: String,
        body: T,
        contentType: ContentType = .json,
        responseType: U.Type,
        completion: @escaping (Result<U, Error>) -> Void
    ) {
        let urlString = baseURL + endpoint
        
        guard let url = URL(string: urlString) else {
            completion(.failure(NetworkError.invalidURL))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.timeoutInterval = 30
        
        // 根据内容类型设置请求头和请求体
        switch contentType {
        case .json:
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            // 设置 Authorization header
            if !AppConfiguration.shared.userToken.isEmpty {
                request.setValue("Bearer \(AppConfiguration.shared.userToken)", forHTTPHeaderField: "Authorization")
            }
            do {
                let jsonData = try JSONEncoder().encode(body)
                request.httpBody = jsonData
                
                if let jsonString = String(data: jsonData, encoding: .utf8) {
                    print("PUT JSON 请求体: \(jsonString)")
                }
            } catch {
                completion(.failure(NetworkError.encodingError))
                return
            }
            
        case .formURLEncoded:
            request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
            // 设置 Authorization header
            if !AppConfiguration.shared.userToken.isEmpty {
                request.setValue("Bearer \(AppConfiguration.shared.userToken)", forHTTPHeaderField: "Authorization")
            }
            do {
                let jsonData = try JSONEncoder().encode(body)
                if let dictionary = try JSONSerialization.jsonObject(with: jsonData) as? [String: Any] {
                    let formDataString = dictionary
                        .compactMap { key, value in
                            guard let stringValue = value as? String else { return nil }
                            return "\(key)=\(stringValue.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")"
                        }
                        .joined(separator: "&")
                    
                    request.httpBody = formDataString.data(using: .utf8)
                    print("PUT 表单请求体: \(formDataString)")
                }
            } catch {
                completion(.failure(NetworkError.encodingError))
                return
            }
        }
        
        performRequest(request: request, responseType: responseType, completion: completion)
    }
    
    struct EmptyRequestBody: Codable {
        // 空请求体
    }
    
    
    
    
    
    
    
    //重置 邮箱密码
    func resetEmailPwdPutRequest(
        email: String,
        email_code: String,
        
        password: String,
        confirmPassword: String,
        completion: @escaping (Result<RegisterResponse, Error>) -> Void
    ) {
        let requestBody = ResetEmailPwdRequest(
            email: email,
            email_code: email_code,
            password: password,
            confirmPassword: confirmPassword
        )
        
        NetworkManager.shared.putRequest(
            endpoint: "/user/reset_pw_with_code",
            body: requestBody,
            contentType: .json, // 使用 JSON 格式
            responseType: RegisterResponse.self,
            completion: completion
        )
    }
    
    
    // 简化的 PUT 请求方法（无请求体）
//    func putRequest<U: Codable>(
//        endpoint: String,
//        responseType: U.Type,
//        completion: @escaping (Result<U, Error>) -> Void
//    ) {
//        let requestBody = ResetEmailPwdRequest()
//        putRequest(
//            endpoint: endpoint,
//            body: requestBody,
//            responseType: responseType,
//            completion: completion
//        )
//    }
    
    
    
    // 添加删除用户的方法 - 使用 DELETE 请求
    func userDelete(completion: @escaping (Result<DeleteResponse, Error>) -> Void) {
        
        NetworkManager.shared.deleteRequest(
            endpoint: "/user/delete",
            responseType: DeleteResponse.self,
            completion: completion
        )
    }
     
    
    // 通用的 DELETE 请求方法（无请求体）
    func deleteRequest<U: Codable>(
        endpoint: String,
        responseType: U.Type,
        completion: @escaping (Result<U, Error>) -> Void
    ) {
        let urlString = baseURL + endpoint
        
        guard let url = URL(string: urlString) else {
            completion(.failure(NetworkError.invalidURL))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        request.timeoutInterval = 30
        
        // 根据内容类型设置请求头和请求体
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        // 设置 Authorization header
        if !AppConfiguration.shared.userToken.isEmpty {
            request.setValue("\(AppConfiguration.shared.userToken)", forHTTPHeaderField: "Authorization")
        }
        
        performRequest(request: request, responseType: responseType, completion: completion)
    }
    
    // 删除用户的方法
//    func userDelete2(completion: @escaping (Result<DeleteResponse, Error>) -> Void) {
//        let requestBody = EmptyRequestBody() // 如果没有请求体参数，可以使用空结构体
//        
//        NetworkManager.shared.postRequest(
//            endpoint: "/user/delete",
//            body: requestBody,
//            contentType: .json,
//            responseType: DeleteResponse.self,
//            completion: completion
//        )
//    }
    
    
    // 通用的 DELETE 请求方法（带请求体）
//    func deleteRequest<T: Codable, U: Codable>(
//        endpoint: String,
//        body: T,
//        contentType: ContentType = .json,
//        responseType: U.Type,
//        completion: @escaping (Result<U, Error>) -> Void
//    ) {
//        let urlString = baseURL + endpoint
//        
//        guard let url = URL(string: urlString) else {
//            completion(.failure(NetworkError.invalidURL))
//            return
//        }
//        
//        var request = URLRequest(url: url)
//        request.httpMethod = "DELETE"
//        request.timeoutInterval = 30
//        
//        // 根据内容类型设置请求头和请求体
//        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
//        // 设置 Authorization header
//        if !AppConfiguration.shared.userToken.isEmpty {
//            request.setValue("\(AppConfiguration.shared.userToken)", forHTTPHeaderField: "Authorization")
//        }
//        do {
//            let jsonData = try JSONEncoder().encode(body)
//            request.httpBody = jsonData
//            
//            if let jsonString = String(data: jsonData, encoding: .utf8) {
//                print("DELETE JSON 请求体: \(jsonString)")
//            }
//        } catch {
//            completion(.failure(NetworkError.encodingError))
//            return
//        }
//        
//        performRequest(request: request, responseType: responseType, completion: completion)
//    }
    
    // 提取公共的请求执行逻辑
    private func performRequest<U: Codable>(
        request: URLRequest,
        responseType: U.Type,
        completion: @escaping (Result<U, Error>) -> Void
    ) {
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                completion(.failure(NetworkError.invalidResponse))
                return
            }
            
            print("HTTP状态码: \(httpResponse.statusCode)")
            
            guard (200...299).contains(httpResponse.statusCode) else {
                completion(.failure(NetworkError.httpError(statusCode: httpResponse.statusCode)))
                return
            }
            
            guard let data = data else {
                completion(.failure(NetworkError.noData))
                return
            }
            
            if let responseString = String(data: data, encoding: .utf8) {
                print("响应: \(responseString)")
            }
            
            do {
                let decodedResponse = try JSONDecoder().decode(U.self, from: data)
                completion(.success(decodedResponse))
            } catch {
                print("解码错误: \(error)")
                completion(.failure(NetworkError.decodingError))
            }
        }.resume()
    }

    // 相关数据模型
    struct DeleteRequest: Codable {
        let userId: String?
        let reason: String?
        
        enum CodingKeys: String, CodingKey {
            case userId = "user_id"
            case reason
        }
    }

    struct DeleteResponse: Codable {
        let code: Int
        let msg: String
        let data: ResponseData?
        
        struct ResponseData: Codable {
            let token: String?
        }
        
        var success: Bool {
            return code == 0
        }
    }
    
    
    
    
    
    
    
    func sendRecordRechargeRequest(
        data: String,
        uid: String,
        completion: @escaping (Result<RecordRechargeResponse, Error>) -> Void
    ) {
        let requestBody = RecordRechargeRequest(data: data, uid: uid)
        
        NetworkManager.shared.postRequest(
            endpoint: "/api/apple/webhook", // 替换为实际的API端点
            body: requestBody,
            contentType: .json, // 根据API要求选择.json或.formURLEncoded
            responseType: RecordRechargeResponse.self,
            completion: completion
        )
    }
    
    
    
    // 发送邮箱验证码
    func sendEmailCode(
        email: String,
        captcha: String,
        code: String,
        completion: @escaping (Result<EmailCodeResponse, Error>) -> Void
    ) {
        let requestBody = EmailCodeRequest(email: email, captcha: captcha, code: code)
        
        NetworkManager.shared.postRequest(
            endpoint: "/user/register/email/code",
            body: requestBody,
            contentType: .formURLEncoded, // 使用表单格式
            responseType: EmailCodeResponse.self,
            completion: completion
        )
    }
    
    
    // 发送重置邮箱密码  验证码
    func sendResetEmailCode(
        email: String,
        completion: @escaping (Result<EmailCodeResponse, Error>) -> Void
    ) {
        let requestBody = ResetEmailCodeRequest(email: email)
        
        NetworkManager.shared.postRequest(
            endpoint: "/user/reset_pw/email/code",
            body: requestBody,
            contentType: .formURLEncoded, // 使用表单格式
            responseType: EmailCodeResponse.self,
            completion: completion
        )
    }
    
    
    
    
    // 短信验证码登录
    func verifySMSPhone(
        smsCode: String,
        phoneNumber: String,
        completion: @escaping (Result<SMSPhoneResponse, Error>) -> Void
    ) {
        let requestBody = SMSLoginRequest(sms_code: smsCode, phone_number: phoneNumber)
        
        NetworkManager.shared.postRequest(
            endpoint: "/user/sms/phone",
            body: requestBody,
            contentType: .formURLEncoded, // 使用表单格式
            responseType: SMSPhoneResponse.self,
            completion: completion
        )
    }
    // 网络请求结果枚举
    enum NetworkResult {
        case success(String) // 成功返回 token
        case failure(String) // 失败返回错误信息
    }
    
    func sendSMSRequest(
           phoneNumber: String,
           smsCode: String,
           completion: @escaping (NetworkResult) -> Void
       ) {
           guard let url = URL(string: "https://dash-api.302.ai/user/sms/phone") else {
               completion(.failure("无效的URL"))
               return
           }
           
           DispatchQueue.main.async {
               self.isLoading = true
           }
           
           var request = URLRequest(url: url)
           request.httpMethod = "POST"
           request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
           
           // 构建表单数据
           let bodyParameters = "sms_code=\(smsCode)&phone_number=\(phoneNumber)"
           request.httpBody = bodyParameters.data(using: .utf8)
             
           
           URLSession.shared.dataTask(with: request) { data, response, error in
               DispatchQueue.main.async {
                   self.isLoading = false
               }
               
               if let error = error {
                   completion(.failure("网络请求失败: \(error.localizedDescription)"))
                   return
               }
               
               guard let data = data else {
                   completion(.failure("没有接收到数据"))
                   return
               }
               
               do {
                   let response = try JSONDecoder().decode(SMSResponse.self, from: data)
                   
                   if response.code == 0, let tokenData = response.data {
                       completion(.success(tokenData["token"]!))
                   } else {
                       completion(.failure(response.msg))
                   }
               } catch {
                   completion(.failure("数据解析失败: \(error.localizedDescription)"))
               }
           }.resume()
       }
    
 

    func userPasswdLogin(
        account: String,
        password: String,
        ref: String = "default_ref", // 提供默认值
        event: String = "login",     // 提供默认值
        captcha: String,
        code: String,
        login_from: String = "ios_app", // 提供默认值
        phone: String = "",
        completion: @escaping (Result<LoginResponse, Error>) -> Void
    ) {
        let requestBody = UserPasswdLoginRequest(
            account: account,
            password: password,
            ref: ref,
            event: event,
            captcha: captcha,
            code: code,
            login_from: login_from,
            phone: phone
        )
        
        NetworkManager.shared.postRequest(
            endpoint: "/user/login/all",
            body: requestBody,
            contentType: .json,
            responseType: LoginResponse.self,
            completion: completion
        )
    }

    func passwordUserLogin(
        account: String,
        password: String,
        captcha: String,
        code: String,
        completion: @escaping (Result<LoginResponse, Error>) -> Void
    ) {
        userPasswdLogin(
            account: account,
            password: password,
            ref: "app_login",
            event: "user_login",
            captcha: captcha,
            code: code,
            login_from: "ios_mobile",
            phone: "",
            completion: completion
        )
    }
    
    
    //邮箱注册
    func registerWithEmail(
        email: String,
        password: String,
        name: String,
        captcha: String,
        code: String,
        emailCode: String,
        completion: @escaping (Result<RegisterResponse, Error>) -> Void
    ) {
        let requestBody = EmailRegisterRequest(
            email: email,
            password: password,
            name: name,
            captcha: captcha,
            code: code,
            emailCode: emailCode
        )
        
        NetworkManager.shared.postRequest(
            endpoint: "/user/v1/register/",
            body: requestBody,
            contentType: .json, // 使用 JSON 格式
            responseType: RegisterResponse.self,
            completion: completion
        )
    }
    
    
    //MARK: - 发送验证码
    func sendSMS(mobile: String, captcha: String, code: String, completion: @escaping (Result<SMSResponse, Error>) -> Void) {
        
        let urlString = baseURL + "/user/sms/rny"
        
        guard let url = URL(string: urlString) else {
            completion(.failure(NetworkError.invalidURL))
            return
        }
        
        // 创建请求体
        let requestBody = SMSRequest(mobile: mobile, captcha: captcha, code: code)
        
        // 创建URL请求
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.timeoutInterval = 30
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // 编码请求体
        do {
            let jsonData = try JSONEncoder().encode(requestBody)
            request.httpBody = jsonData
        } catch {
            completion(.failure(error))
            return
        }
        
        // 发起数据任务
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                completion(.failure(NetworkError.invalidResponse))
                return
            }
            
            guard (200...299).contains(httpResponse.statusCode) else {
                completion(.failure(NetworkError.httpError(statusCode: httpResponse.statusCode)))
                return
            }
            
            guard let data = data else {
                completion(.failure(NetworkError.noData))
                return
            }
            
            // 解码响应数据
            do {
                let decodedResponse = try JSONDecoder().decode(SMSResponse.self, from: data)
                completion(.success(decodedResponse))
            } catch {
                completion(.failure(NetworkError.decodingError))
            }
        }.resume()
    }
    
    
    
    //MARK: - 图形验证码
    func fetchImage(code: String? = nil, completion: @escaping (Result<NetworkResponse, Error>) -> Void) {
        // 生成随机10位字母代码（如果未提供）
        let randomCode = code ?? generateRandomString(length: 10)
        // 获取当前时间戳
        let timestamp = Int(Date().timeIntervalSince1970 * 1000)
        let code_time = "\(randomCode)-\(timestamp)"
        // 构建请求URL
        let urlString = "\(baseURL)/proxy/static/image?code=\(code_time)"
        guard let url = URL(string: urlString) else {
            completion(.failure(NetworkError.invalidURL))
            return
        }
        
        // 创建URL请求
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.timeoutInterval = 30
        
        // 发起数据任务
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                completion(.failure(NetworkError.invalidResponse))
                return
            }
            
            guard (200...299).contains(httpResponse.statusCode) else {
                completion(.failure(NetworkError.httpError(statusCode: httpResponse.statusCode)))
                return
            }
            
            guard let data = data else {
                completion(.failure(NetworkError.noData))
                return
            }
            
            // 返回数据和使用的code
            let response = NetworkResponse(data: data, code: code_time)
            completion(.success(response))
        }.resume()
    }
    
    
    func registerWithPhone2(
        name: String,
        password: String,
        confirmPassword: String,
        sms_code: String,
        phone_number: String,
        completion: @escaping (Result<RegisterResponse, Error>) -> Void
    ) {
        let requestBody = RegisterPhoneRequest(
            name: name,
            password: password,
            confirmPassword: confirmPassword,
            sms_code: sms_code,
            phone_number: phone_number
        )
        
        NetworkManager.shared.postRequest(
            endpoint: "/user/register/phone",
            body: requestBody,
            contentType: .formURLEncoded, // 使用 JSON 格式
            responseType: RegisterResponse.self,
            completion: completion
        )
    }
    
     
    func msgCodeLoginWithPhone(
        sms_code: String,
        phone_number: String,
        completion: @escaping (Result<RegisterResponse, Error>) -> Void
    ) {
        let requestBody = MsgCodeLoginRequest(
            sms_code: sms_code,
            phone_number: phone_number
        )
        
        NetworkManager.shared.postRequest(
            endpoint: "/user/sms/phone",
            body: requestBody,
            contentType: .formURLEncoded, // 使用 JSON 格式
            responseType: RegisterResponse.self,
            completion: completion
        )
    }
     
    
    func userLoginWithAll(
        account: String,
        password: String,
        captcha: String,
        code: String,
        completion: @escaping (Result<RegisterResponse, Error>) -> Void
    ) {
        let requestBody = AllLoginRequest(
            account: account,
            password: password,
            captcha: captcha,
            code: code
        )
        
        NetworkManager.shared.postRequest(
            endpoint: "/user/login/all",
            body: requestBody,
            contentType: .json, // 使用 JSON 格式
            responseType: RegisterResponse.self,
            completion: completion
        )
    }
    
    //重置 手机号密码
    func resetPhonePwdRequest(
        phone_number: String,
        password: String,
        sms_code: String,
        completion: @escaping (Result<RegisterResponse, Error>) -> Void
    ) {
        let requestBody = ResetPhonePwdRequest(
            phone_number: phone_number,
            password: password,
            sms_code: sms_code
        )
        
        NetworkManager.shared.postRequest(
            endpoint: "/user/reset_pw",   //https://dash-api.302.ai/user/reset_pw/email/code
            body: requestBody,
            contentType: .json, // 使用 JSON 格式
            responseType: RegisterResponse.self,
            completion: completion
        )
    }
     
    
    
    
    //MARK: - 手机号注册
    func registerWithPhone(
        name: String,
        password: String,
        confirmPassword: String,
        smsCode: String,
        phoneNumber: String,
        completion: @escaping (Result<RegisterResponse, Error>) -> Void
    ) {
        // 构建请求URL
        let baseURL = "https://dash-api.302.ai"
        let endpoint = "/user/register/phone"
        let urlString = baseURL + endpoint
        
        guard let url = URL(string: urlString) else {
            completion(.failure(NetworkError.invalidURL))
            return
        }
        
        // 创建表单数据
        let parameters: [String: String] = [
            "name": name,
            "password": password,
            "confirmPassword": confirmPassword,
            "sms_code": smsCode,
            "phone_number": phoneNumber
        ]
        
        // 将参数转换为表单格式的字符串
//        let formDataString = parameters
//            .map { "\($0.key)=\($0.value.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")" }
//            .joined(separator: "&")
        
        
        // 创建表单数据（修复编码问题）
        var components = URLComponents()
        components.queryItems = parameters.map {
            URLQueryItem(name: $0.key, value: $0.value)
        }
        let formDataString = components.percentEncodedQuery ?? ""
        
        
        // 创建URL请求
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.timeoutInterval = 30
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.setValue("\(formDataString.utf8.count)", forHTTPHeaderField: "Content-Length")
        
        // 设置请求体
        request.httpBody = formDataString.data(using: .utf8)
        
        // 发起数据任务
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                completion(.failure(NetworkError.invalidResponse))
                return
            }
            
            guard (200...299).contains(httpResponse.statusCode) else {
                completion(.failure(NetworkError.httpError(statusCode: httpResponse.statusCode)))
                return
            }
            
            guard let data = data else {
                completion(.failure(NetworkError.noData))
                return
            }
            
            // 打印原始响应数据用于调试
            if let responseString = String(data: data, encoding: .utf8) {
                print("注册响应: \(responseString)")
            }
            
            // 解码响应数据
            do {
                let decodedResponse = try JSONDecoder().decode(RegisterResponse.self, from: data)
                completion(.success(decodedResponse))
            } catch {
                print("解码错误: \(error)")
                completion(.failure(NetworkError.decodingError))
            }
        }.resume()
    }

    // 辅助函数：将字典转换为表单数据
    func createFormData(from parameters: [String: String]) -> Data? {
        let formDataString = parameters
            .map { "\($0.key)=\($0.value.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")" }
            .joined(separator: "&")
        return formDataString.data(using: .utf8)
    }


    
    
    
    //MARK: -  登录请求
    func loginRequest(isEmail:Bool=true,request: LoginRequest, completion: @escaping (Result<LoginResponse, Error>) -> Void) {
           
        var urlString  = ""
        if isEmail {
            urlString = "\(baseURL)/user/login"
        }else{
            urlString = "\(baseURL)/user/login/phone"
        }
        
        guard let url = URL(string: urlString ) else { // 根据实际API端点修改
               completion(.failure(NetworkError.invalidURL))
               return
           }
           
           // 创建URL请求
           var urlRequest = URLRequest(url: url)
           urlRequest.httpMethod = "POST"
           urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
           urlRequest.timeoutInterval = 30
           
           // 编码请求体
           do {
               let jsonData = try JSONEncoder().encode(request)
               urlRequest.httpBody = jsonData
           } catch {
               completion(.failure(NetworkError.encodingError))
               return
           }
           
        
        print("=== GET请求信息 ===")
        print("URL: \(url)")
        print("request Body: email:\(request)")
        print("=================\n")
        
        
           // 发起数据任务
           URLSession.shared.dataTask(with: urlRequest) { data, response, error in
               // 处理网络错误
               if let error = error {
                   completion(.failure(error))
                   return
               }
               
               // 检查HTTP响应
               guard let httpResponse = response as? HTTPURLResponse else {
                   completion(.failure(NetworkError.invalidResponse))
                   return
               }
               
               guard (200...299).contains(httpResponse.statusCode) else {
                   completion(.failure(NetworkError.httpError(statusCode: httpResponse.statusCode)))
                   return
               }
               
               // 检查数据是否存在
               guard let data = data else {
                   completion(.failure(NetworkError.noData))
                   return
               }
               
               // 解码响应数据
               do {
                   let response = try JSONDecoder().decode(LoginResponse.self, from: data)
                   
                   print("响应数据-->response:  \(response)")
                   completion(.success(response))
               } catch {
                   completion(.failure(NetworkError.decodingError))
               }
           }.resume()
       }
    
    
    
    // 获取用户信息
    func getUserInfo(authorization: String, completion: @escaping (Result<UserInfoResponse, Error>) -> Void) {
        guard let url = URL(string: "\(baseURL)/user/info") else {
            completion(.failure(NetworkError.invalidURL))
            return
        }
         
        
        
        // 创建URL请求
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "GET"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.setValue(authorization, forHTTPHeaderField: "Authorization")
        urlRequest.timeoutInterval = 30
        
        print("=== GET请求信息 ===")
        print("URL: \(url)")
        print("Authorization: \(authorization)")
        print("=================\n")
        
        // 发起数据任务
        URLSession.shared.dataTask(with: urlRequest) { data, response, error in
            // 处理网络错误
            if let error = error {
                print("网络错误: \(error)")
                completion(.failure(error))
                return
            }
            
            // 检查HTTP响应
            guard let httpResponse = response as? HTTPURLResponse else {
                print("无效的HTTP响应")
                completion(.failure(NetworkError.invalidResponse))
                return
            }
            
            print("HTTP状态码: \(httpResponse.statusCode)")
            
            // 检查数据是否存在
            guard let data = data else {
                print("没有响应数据")
                completion(.failure(NetworkError.noData))
                return
            }
            
            // 打印响应数据（用于调试）
            print("=== 用户信息响应数据 ===")
            if let responseString = String(data: data, encoding: .utf8) {
                print("响应字符串: \(responseString)")
            } else {
                print("无法将响应数据转换为字符串")
            }
            
            // 分析JSON结构
            //self.printJSONStructure(data)
            
            // 检查HTTP状态码
            guard (200...299).contains(httpResponse.statusCode) else {
                print("HTTP错误: \(httpResponse.statusCode)")
                completion(.failure(NetworkError.httpError(statusCode: httpResponse.statusCode)))
                return
            }
            
            // 解码响应数据
            do {
                let response = try JSONDecoder().decode(UserInfoResponse.self, from: data)
                
                // 检查API业务代码
                if response.code != 0 {
                    print("API业务错误: code=\(response.code), msg=\(response.msg)")
                    completion(.failure(NetworkError.apiError(code: response.code, message: response.msg)))
                    return
                }
                
                print("用户信息获取成功: code=\(response.code), msg=\(response.msg)")
                print("用户UID: \(response.data?.uid)")
                print("用户名: \(response.data?.user_name)")
                print("API Key: \(response.data?.api_key)")
                
                //保存数据
                UserDataManager.shared.saveUserInfo(response)
                //let user = UserDataManager.shared.getCurrentUser()
                
                
                completion(.success(response))
            } catch let decodingError {
                print("解码错误: \(decodingError)")
                print("错误详情: \(decodingError.localizedDescription)")
                
                // 尝试提供更详细的错误信息
                if let decodingError = decodingError as? DecodingError {
                    switch decodingError {
                    case .typeMismatch(let type, let context):
                        print("类型不匹配: 期望 \(type), 上下文: \(context)")
                    case .valueNotFound(let type, let context):
                        print("值不存在: \(type), 上下文: \(context)")
                    case .keyNotFound(let key, let context):
                        print("键不存在: \(key), 上下文: \(context)")
                    case .dataCorrupted(let context):
                        print("数据损坏: \(context)")
                    @unknown default:
                        print("未知解码错误")
                    }
                }
                
                completion(.failure(NetworkError.decodingError))
            }
        }.resume()
    }
    
    
    func fetchModels(completion: FetchModelsCompletion? = nil)  {
        isLoading = true
        errorMessage = nil

        let item = ApiDataManager().selectedItem
        var host : String = item?.host ?? ""
        //let apiKey = AppConfiguration.shared.OAIkey
          
        if !host.contains("https://"){
            host = "https://" + host + "/v1/models"
        }else{
            host = host + "/v1/models"
        }
        
        guard var urlComponents = URLComponents(string: host) else {
            errorMessage = "Invalid URL"
            isLoading = false
            return
        }

        // 添加查询参数
        urlComponents.queryItems = [
            URLQueryItem(name: "llm", value: "1"),
            URLQueryItem(name: "chat", value: "1")
        ]

        guard let url = urlComponents.url else {
            errorMessage = "Invalid URL components"
            isLoading = false
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        let apiKey = "Bearer " + AppConfiguration.shared.OAIkey  //"sk-sx6464FSKRpX5eODxMQHTKbNuoeiz9iMYdbdoNzeTbMLuau7"//AppConfiguration.shared.OAIkey
        request.setValue(apiKey, forHTTPHeaderField: "Authorization")

        let task = URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            // 这里直接使用 DispatchQueue.main.async 的闭包语法
            self?.isLoading = false
            
            if let error = error {
                self?.errorMessage = error.localizedDescription
                completion?(.failure(error))
                return
            }

            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode) else {
                self?.errorMessage = "Invalid response"
                completion?(.failure(error ?? NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid response"])))
                return
            }

            if let data = data {
                do {
                     
                    let model = try JSONDecoder().decode(ModelResponse.self, from: data)
                    self?.models = model.data!
                    print("\n \(host) ----->>>>>>>  model:\(model)")
                    completion?(.success(self!.models))
                    
                } catch {
                    self?.errorMessage = "Failed to decode response: \(error.localizedDescription)"
                }
            }else{
                completion?(.failure(error!))
            }

        }
        
        task.resume()
    }
    
    
    func executeCodeAndReturnString(language: String, code: String, completion: @escaping  (String) -> Void) {
        // 1. 准备URL
        guard let url = URL(string: "https://api.302.ai/302/run/code") else {
            completion("错误：无效的URL")
            return
        }
        
        // 2. 准备请求体
        let requestBody: [String: Any] = [
            "language": language,
            "code": code
        ]
        
        // 3. 创建请求
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let apiKey = "Bearer " + AppConfiguration.shared.OAIkey
        request.setValue(apiKey, forHTTPHeaderField: "Authorization")
        
        
        // 4. 编码JSON body
        guard let httpBody = try? JSONSerialization.data(withJSONObject: requestBody) else {
            completion("错误：请求体编码失败")
            return
        }
        request.httpBody = httpBody
        
        // 5. 发送请求
        URLSession.shared.dataTask(with: request) { data, response, error in
            // 处理网络错误
            if let error = error {
                completion("网络错误：\(error.localizedDescription)")
                return
            }
            
            // 确保有数据返回
            guard let data = data else {
                completion("错误：没有收到数据")
                return
            }
            
            // 尝试将数据直接转为字符串
            if let rawString = String(data: data, encoding: .utf8) {
                completion(rawString)
                return
            }
            
            // 如果无法转为字符串，返回原始数据描述
            completion("收到无法解码的数据：\(data.description)")
        }.resume()
    }
    
    func executeCode(language: String, code: String, completion: @escaping (Result<APIResponse, Error>) -> Void) {
        // 1. 准备URL
        guard let url = URL(string: "https://api.302.ai/302/run/code") else {
            completion(.failure(URLError(.badURL)))
            return
        }
        
        // 2. 准备请求体
        let requestBody: [String: Any] = [
            "language": language,
            "code": code
        ]
        
        // 3. 创建请求
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(AppConfiguration.shared.OAIkey)", forHTTPHeaderField: "Authorization")
        
        // 4. 编码JSON body
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
        } catch {
            completion(.failure(error))
            return
        }
        
        // 5. 发送请求
        URLSession.shared.dataTask(with: request) { data, response, error in
            // 错误处理
            if let error = error {
                completion(.failure(error))
                return
            }
            
            // 数据验证
            guard let data = data else {
                completion(.failure(URLError(.cannotParseResponse)))
                return
            }
            
            // 解码响应
            do {
                let decodedResponse = try JSONDecoder().decode(APIResponse.self, from: data)
                completion(.success(decodedResponse))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
    
     
    
    
}
