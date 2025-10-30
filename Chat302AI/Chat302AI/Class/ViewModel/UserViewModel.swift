//
//  UserViewModel.swift
//  Chat302AI
//
//  Created by Adswave on 2025/9/11.
//

import Foundation
import SwiftUI

class UserViewModel: ObservableObject {
    @Published var userData: UserInfoResponse.UserData?
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    init() {
        // 初始化时尝试从本地加载用户信息
        loadLocalUserData()
    }
    
    // 从本地加载用户信息
    func loadLocalUserData() {
        userData = UserDataManager.shared.getCurrentUser()
    }
    
    // 刷新用户信息
    func refreshUserInfo() {
        isLoading = true
        errorMessage = nil
        
        UserService().fetchUserInfo { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                switch result {
                case .success(let response):
                    self?.userData = response.data
                    self?.errorMessage = nil
                case .failure(let error):
                    self?.errorMessage = error.localizedDescription
                }
            }
        }
    }
    
    // 退出登录
    func logout() {
        UserDataManager.shared.clearUserInfo()
        userData = nil
    }
    
    // 更新余额
    func updateUserBalance(_ newBalance: Double) {
        UserDataManager.shared.updateBalance(newBalance)
        loadLocalUserData() // 重新加载本地数据
    }
}




class UserService {
    // 解析并保存用户信息
    func parseAndSaveUserInfo(data: Data) -> UserInfoResponse? {
        do {
            let decoder = JSONDecoder()
            let response = try decoder.decode(UserInfoResponse.self, from: data)
            
            // 保存到本地
            UserDataManager.shared.saveUserInfo(response)
            
            return response
        } catch {
            print("解析错误: \(error)")
            return nil
        }
    }
    
    // 从网络获取用户信息
    func fetchUserInfo(completion: @escaping (Result<UserInfoResponse, Error>) -> Void) {
        
//        if let jsonData = jsonString.data(using: .utf8) {
//            if let response = parseAndSaveUserInfo(data: jsonData) {
//                completion(.success(response))
//            } else {
//                completion(.failure(NSError(domain: "解析失败", code: -1)))
//            }
//        }
    }
}
