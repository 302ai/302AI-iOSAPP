//
//  UserInfoManager.swift
//  Chat302AI
//
//  Created by Adswave on 2025/9/11.
//

import Foundation

struct UserInfoResponse: Codable {
    let code: Int
    let msg: String
    let data: UserData?
    
    struct UserData: Codable {
        var balance: Double?
        let invite_code: String?
        let is_new_user: Bool?
        let gpt_cost: Double?
        let gpt_request_times: Int?
        let region: Int?
        let total_balance: Double?
        let inv_switch: Bool?
        let ref: String?
        let has_gift: Bool?
        let phone: String?
        let resource_area: Int?
        let register_from: String?
        let invitation_link: String?
        var api_key: String?
        let avatar: String?
        var user_name: String?
        let email: String?
        let uid: Int?
        let question_switch: Bool?
        let show_questionnaire_windows: Bool?
        let to_band_phone: Bool?
        
        // 添加显式成员初始化器
        init(
            balance: Double? = nil,
            invite_code: String? = nil,
            is_new_user: Bool? = nil,
            gpt_cost: Double? = nil,
            gpt_request_times: Int? = nil,
            region: Int? = nil,
            total_balance: Double? = nil,
            inv_switch: Bool? = nil,
            ref: String? = nil,
            has_gift: Bool? = nil,
            phone: String? = nil,
            resource_area: Int? = nil,
            register_from: String? = nil,
            invitation_link: String? = nil,
            api_key: String? = nil,
            avatar: String? = nil,
            user_name: String? = nil,
            email: String? = nil,
            uid: Int? = nil,
            question_switch: Bool? = nil,
            show_questionnaire_windows: Bool? = nil,
            to_band_phone: Bool? = nil
        ) {
            self.balance = balance
            self.invite_code = invite_code
            self.is_new_user = is_new_user
            self.gpt_cost = gpt_cost
            self.gpt_request_times = gpt_request_times
            self.region = region
            self.total_balance = total_balance
            self.inv_switch = inv_switch
            self.ref = ref
            self.has_gift = has_gift
            self.phone = phone
            self.resource_area = resource_area
            self.register_from = register_from
            self.invitation_link = invitation_link
            self.api_key = api_key
            self.avatar = avatar
            self.user_name = user_name
            self.email = email
            self.uid = uid
            self.question_switch = question_switch
            self.show_questionnaire_windows = show_questionnaire_windows
            self.to_band_phone = to_band_phone
        }
        
        // 自定义解码初始化
        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            
            // 使用 decodeIfPresent 安全解码每个字段
            balance = try container.decodeIfPresent(Double.self, forKey: .balance)
            invite_code = try container.decodeIfPresent(String.self, forKey: .invite_code)
            is_new_user = try container.decodeIfPresent(Bool.self, forKey: .is_new_user)
            gpt_cost = try container.decodeIfPresent(Double.self, forKey: .gpt_cost)
            gpt_request_times = try container.decodeIfPresent(Int.self, forKey: .gpt_request_times)
            region = try container.decodeIfPresent(Int.self, forKey: .region)
            total_balance = try container.decodeIfPresent(Double.self, forKey: .total_balance)
            inv_switch = try container.decodeIfPresent(Bool.self, forKey: .inv_switch)
            ref = try container.decodeIfPresent(String.self, forKey: .ref)
            has_gift = try container.decodeIfPresent(Bool.self, forKey: .has_gift)
            phone = try container.decodeIfPresent(String.self, forKey: .phone)
            resource_area = try container.decodeIfPresent(Int.self, forKey: .resource_area)
            register_from = try container.decodeIfPresent(String.self, forKey: .register_from)
            invitation_link = try container.decodeIfPresent(String.self, forKey: .invitation_link)
            api_key = try container.decodeIfPresent(String.self, forKey: .api_key)
            avatar = try container.decodeIfPresent(String.self, forKey: .avatar)
            user_name = try container.decodeIfPresent(String.self, forKey: .user_name)
            email = try container.decodeIfPresent(String.self, forKey: .email)
            uid = try container.decodeIfPresent(Int.self, forKey: .uid)
            question_switch = try container.decodeIfPresent(Bool.self, forKey: .question_switch)
            show_questionnaire_windows = try container.decodeIfPresent(Bool.self, forKey: .show_questionnaire_windows)
            to_band_phone = try container.decodeIfPresent(Bool.self, forKey: .to_band_phone)
        }
        
        // CodingKeys 枚举
        enum CodingKeys: String, CodingKey {
            case balance
            case invite_code
            case is_new_user
            case gpt_cost
            case gpt_request_times
            case region
            case total_balance
            case inv_switch
            case ref
            case has_gift
            case phone
            case resource_area
            case register_from
            case invitation_link
            case api_key
            case avatar
            case user_name
            case email
            case uid
            case question_switch
            case show_questionnaire_windows
            case to_band_phone
        }
        
        // 计算属性：格式化显示余额（处理可选值）
        var formattedBalance: String {
            if let balance = balance {
                return String(format: "%.2f", balance)
            } else {
                return "0.00"
            }
        }
        
        var formattedTotalBalance: String {
            if let totalBalance = total_balance {
                return String(format: "%.2f", totalBalance)
            } else {
                return "0.00"
            }
        }
        
        var formattedGptCost: String {
            if let gptCost = gpt_cost {
                return String(format: "%.2f", gptCost)
            } else {
                return "0.00"
            }
        }
        
        // 计算属性：显示用户标识
        var userIdentifier: String {
            if let phone = phone, !phone.isEmpty {
                return phone
            } else if let email = email, !email.isEmpty {
                return email
            } else if let uid = uid {
                return "用户\(uid)"
            } else {
                return "未知用户"
            }
        }
        
        // 提供默认值的便捷属性
        var safeBalance: Double { balance ?? 0.0 }
        var safeTotalBalance: Double { total_balance ?? 0.0 }
        var safeGptCost: Double { gpt_cost ?? 0.0 }
        var safeUid: Int { uid ?? 0 }
        var safeUserName: String { user_name ?? "" }
        var safeEmail: String { email ?? "" }
        var safePhone: String { phone ?? "" }
        var safeApiKey: String { api_key ?? "" }
        var safeAvatar: String { avatar ?? "" }
    }
    
    var success: Bool {
        return code == 0
    }
}


class UserDataManager {
    static let shared = UserDataManager()
    
    private let userDefaults = UserDefaults.standard
    private let userDataKey = "userInfoResponse"
    private let apiKeyKey = "userApiKey"
    
    private init() {}
    
    // MARK: - 保存用户信息
    func saveUserInfo(_ response: UserInfoResponse) {
        do {
            let encoder = JSONEncoder()
            let encodedData = try encoder.encode(response)
            userDefaults.set(encodedData, forKey: userDataKey)
            userDefaults.synchronize()
            
            // 单独保存API Key，方便快速访问
            if let apiKey = response.data?.api_key {
                userDefaults.set(apiKey, forKey: apiKeyKey)
            }
            
            print("用户信息保存成功")
        } catch {
            print("保存用户信息失败: \(error)")
        }
    }
    
    // MARK: - 获取用户信息
    func getUserInfo() -> UserInfoResponse? {
        guard let savedData = userDefaults.data(forKey: userDataKey) else {
            return nil
        }
        
        do {
            let decoder = JSONDecoder()
            let response = try decoder.decode(UserInfoResponse.self, from: savedData)
            return response
        } catch {
            print("读取用户信息失败: \(error)")
            return nil
        }
    }
    
    // MARK: - 获取API Key
    func getApiKey() -> String {
        return userDefaults.string(forKey: apiKeyKey) ?? ""
    }
    
    // MARK: - 清除用户信息
    func clearUserInfo() {
        userDefaults.removeObject(forKey: userDataKey)
        userDefaults.removeObject(forKey: apiKeyKey)
        userDefaults.synchronize()
        print("用户信息已清除")
    }
    
    // MARK: - 检查是否已登录
    func isLoggedIn() -> Bool {
        return getUserInfo() != nil && !getApiKey().isEmpty
    }
    
    // MARK: - 获取用户基本信息（便捷方法）
    func getCurrentUser() -> UserInfoResponse.UserData? {
        return getUserInfo()?.data
    }
    
    // MARK: - 更新特定字段 - 修正后的方法
    func updateBalance(_ newBalance: Double) {
        guard var userInfo = getUserInfo() else { return }
        
        // 使用新的初始化器创建UserData对象
        let oldData = userInfo.data
        let updatedData = UserInfoResponse.UserData(
            balance: newBalance,
            invite_code: oldData?.invite_code,
            is_new_user: oldData?.is_new_user,
            gpt_cost: oldData?.gpt_cost,
            gpt_request_times: oldData?.gpt_request_times,
            region: oldData?.region,
            total_balance: oldData?.total_balance,
            inv_switch: oldData?.inv_switch,
            ref: oldData?.ref,
            has_gift: oldData?.has_gift,
            phone: oldData?.phone,
            resource_area: oldData?.resource_area,
            register_from: oldData?.register_from,
            invitation_link: oldData?.invitation_link,
            api_key: oldData?.api_key,
            avatar: oldData?.avatar,
            user_name: oldData?.user_name,
            email: oldData?.email,
            uid: oldData?.uid,
            question_switch: oldData?.question_switch,
            show_questionnaire_windows: oldData?.show_questionnaire_windows,
            to_band_phone: oldData?.to_band_phone
        )
        
        // 创建新的Response对象
        let updatedResponse = UserInfoResponse(
            code: userInfo.code,
            msg: userInfo.msg,
            data: updatedData
        )
        
        // 保存更新后的数据
        saveUserInfo(updatedResponse)
    }
    
    // MARK: - 更通用的更新方法
    func updateUserData(updater: (inout UserInfoResponse.UserData?) -> Void) {
        guard var userInfo = getUserInfo() else { return }
        
        // 使用旧的data创建可变副本
        var updatedData = userInfo.data
        
        // 应用更新
        updater(&updatedData)
        
        // 创建新的Response对象
        let updatedResponse = UserInfoResponse(
            code: userInfo.code,
            msg: userInfo.msg,
            data: updatedData
        )
        
        // 保存更新后的数据
        saveUserInfo(updatedResponse)
    }
}

// 使用示例
extension UserDataManager {
    // 使用通用更新方法更新余额
    func updateBalanceUsingGeneric(_ newBalance: Double) {
        updateUserData { userData in
            userData?.balance = newBalance
        }
    }
    
    // 更新API Key
    func updateApiKey(_ newApiKey: String) {
        updateUserData { userData in
            userData?.api_key = newApiKey
            // 同时更新单独存储的API Key
            UserDefaults.standard.set(newApiKey, forKey: self.apiKeyKey)
        }
    }
    
    // 更新用户名
    func updateUserName(_ newUserName: String) {
        updateUserData { userData in
            userData?.user_name = newUserName
        }
    }
}
