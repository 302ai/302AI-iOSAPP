//
//  CostDetailView.swift
//  Chat302AI
//
//  Created by Adswave on 2025/9/4.
//

import SwiftUI

//消耗明细




struct CostDetailView: View  {
    @State private var selectedTimeFilter = 0
    private let timeFilters = ["今日", "本周", "本月"]
    
    @Environment(\.presentationMode) var presentationMode
    
    
    var body: some View {
        VStack {
             
            
            List {
                
                Section{

                    ZStack{
                        
                        Image("消耗明细背景")
                        
                        // 顶部余额和统计区域
                        VStack{
                            // 账户余额
                            HStack{
                                VStack(spacing: 8) {
                                    Text("账户余额".localized())
                                        .font(.subheadline)
                                        .foregroundColor(.white)
                                        .font(.system(size: 14, weight: .bold))
                                    HStack(alignment: .center){
                                        Text("--")
                                            .foregroundColor(.white)
                                            .font(.system(size: 26, weight: .medium))
                                            .padding([.leading],10)
                                        Text("PTC")
                                            .foregroundColor(.white)
                                            .font(.system(size: 12, weight: .regular))
                                            .padding(.top,8)
                                            .padding(.trailing,10)
                                            .offset(x:-5)
                                    }
                                }
                                Spacer()
                                // 充值按钮
                                Text("充值".localized())
                                    .frame(height: 34)
                                    .fixedSize()
                                    .padding(.horizontal,8)
                                    .background(Color.white)
                                    .foregroundColor(Color(hex: "#8E47F1"))
                                    .cornerRadius(10)
                                    .onTapGesture {
                                         
                                    }
                            }
                            .padding(10)
                            
                            
                            // 统计信息
                            HStack {
                                // 左边 VStack
                                VStack(spacing: 8) {
                                    Text("今日消耗".localized())
                                        .font(.subheadline)
                                        .foregroundColor(.white)
                                    HStack(alignment: .center){
                                        Text("--")
                                            .foregroundColor(.white)
                                            .font(.system(size: 22, weight: .medium))
                                            .padding([.leading],10)
                                        Text("PTC")
                                            .foregroundColor(.white)
                                            .font(.system(size: 12, weight: .regular))
                                            .padding(.top,8)
                                            .padding(.trailing,10)
                                            .offset(x:-5)
                                    }
                                }
                                .frame(maxWidth: .infinity, alignment: .leading) // 左对齐
                                
                                Spacer()
                                
                                // 中间 VStack
                                VStack(spacing: 8) {
                                    Text("本月消耗".localized())
                                        .font(.subheadline)
                                        .foregroundColor(.white)
                                    HStack(alignment: .center){
                                        Text("--")
                                            .foregroundColor(.white)
                                            .font(.system(size: 22, weight: .medium))
                                            .padding([.leading],8)
                                        Text("PTC")
                                            .foregroundColor(.white)
                                            .font(.system(size: 12, weight: .regular))
                                            .padding(.top,8)
                                            .padding(.trailing,10)
                                            .offset(x:-5)
                                    }
                                }
                                
                                Spacer()
                                
                                // 右边 VStack
                                VStack(spacing: 8) {
                                    Text("历史消耗".localized())
                                        .font(.subheadline)
                                        .foregroundColor(.white)
                                    HStack(alignment: .center){
                                        Text("--")
                                            .foregroundColor(.white)
                                            .font(.system(size: 22, weight: .medium))
                                            .padding([.leading],8)
                                        Text("PTC")
                                            .foregroundColor(.white)
                                            .font(.system(size: 12, weight: .regular))
                                            .padding(.top,8)
                                            .padding(.trailing,10)
                                            .offset(x:-5)
                                    }
                                }
                                .frame(maxWidth: .infinity, alignment: .trailing) // 右对齐
                            }
                            .padding([.bottom,.horizontal],10)
                            
                        }
                        .padding(10)
                        .background(Color(hex: "#8E47F1"))

                    }
                    

                }
                .listRowInsets(EdgeInsets()) // 移除内边距
                .listRowBackground(Color.clear) // 设置透明背景
                .background(
                    ZStack {
                        Image("会话标题")
                            .resizable()
                            .scaledToFill()
                        
                        // 添加渐变叠加，让文字更清晰
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color(hex: "#8E47F1").opacity(0.9),
                                Color(hex: "#8E47F1").opacity(0.7)
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    }
                    .cornerRadius(12)
                )
                
                Section(header: Text("消耗明细".localized()).font(.headline)) {
                    // 会话标题
                    HStack {
                        Image("会话标题")
                        VStack(alignment: .leading, spacing: 4) {
                            Text("会话标题".localized())
                                .font(.system(size: 16))
                            Text("2025/01/01 00:00:01")
                                .font(.system(size: 12))
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                        Text("0")
                            .foregroundColor(.red)
                            .font(.system(size: 16, weight: .medium))
                        Image(systemName: "chevron.right")
                            .font(.system(size: 14))
                            .foregroundColor(.secondary)
                    }
                }
                 
                
                Section {
                    // 知识库名称
                    HStack {
                        Image("知识库名称")
                        VStack(alignment: .leading, spacing: 4) {
                            Text("知识库名称".localized())
                                .font(.system(size: 16))
                            Text("2025/01/01 00:00:01")
                                .font(.system(size: 12))
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                        Text("0")
                            .foregroundColor(.red)
                            .font(.system(size: 16, weight: .medium))
                        Image(systemName: "chevron.right")
                            .font(.system(size: 14))
                            .foregroundColor(.secondary)
                    }
                }
                
                
                
                Section {
                    // 档案库
                    HStack {
                        Image("档案库2")
                        VStack(alignment: .leading, spacing: 4) {
                            Text("档案库".localized())
                                .font(.system(size: 16))
                            Text("2025/01/01 00:00:01")
                                .font(.system(size: 12))
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                        Text("0")
                            .foregroundColor(.red)
                            .font(.system(size: 16, weight: .medium))
                        Image(systemName: "chevron.right")
                            .font(.system(size: 14))
                            .foregroundColor(.secondary)
                    }
                }

                
                Section {
                    // 无痕会话
                    HStack {
                        Image("无痕会话")
                        VStack(alignment: .leading, spacing: 4) {
                            Text("无痕会话".localized())
                                .font(.system(size: 16))
                            Text("2025/01/01 00:00:01")
                                .font(.system(size: 12))
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                        Text("0")
                            .foregroundColor(.red)
                            .font(.system(size: 16, weight: .medium))
                        Image(systemName: "chevron.right")
                            .font(.system(size: 14))
                            .foregroundColor(.secondary)
                    }
                }
                
                Section {
                    // 账户充值
                    HStack {
                        Image("账户充值")
                        VStack(alignment: .leading, spacing: 4) {
                            Text("账户充值".localized())
                                .font(.system(size: 16))
                            Text("2025/01/01 00:00:01")
                                .font(.system(size: 12))
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                        Text("0")
                            .foregroundColor(.red)
                            .font(.system(size: 16, weight: .medium))
                        Image(systemName: "chevron.right")
                            .font(.system(size: 14))
                            .foregroundColor(.secondary)
                    }
                }
                
            }
            .listSectionSpacing(.custom(10))
            
        }
        .listStyle(.insetGrouped)
        .background(NavigationGestureRestorer())
        .navigationBarBackButtonHidden(true)
        .navigationTitle("消耗明细".localized())
        .navigationBarTitleDisplayMode(.inline)
        
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
    }
}


#Preview {
    CostDetailView()
}
