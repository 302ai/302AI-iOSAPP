//
//  BottomSheetFilePicker.swift
//  Chat302AI
//
//  Created by Adswave on 2025/8/7.
//

import SwiftUI
import AlertToast



// 文件选择类型枚举
enum FilePickerType: Int, CaseIterable {
    //case library
    case camera
    case photo
    case attachment
    
    var description: String {
        switch self {
        //case .library: return "从档案库选择".localized()
        case .camera: return "拍照".localized()
        case .photo: return "图片".localized()
        case .attachment: return "附件".localized()
        }
    }
    
    var iconName: String {
        switch self {
        //case .library: return "档案库3"
        case .camera: return "拍照"
        case .photo: return "相册2"
        case .attachment: return "文件"
        }
    }
}

struct BottomSheetFilePicker: View {
    @Binding var isPresented: Bool
    var onTypeSelected: ((FilePickerType) -> Void)?
    
    @State private var hintText = ""
    @State private var isShowToast = false
    
    
    var body: some View {
        ZStack(alignment: .bottom) {
            // 半透明背景
            if isPresented {
                Color.black.opacity(0.4)
                    .edgesIgnoringSafeArea(.all)
                    .onTapGesture {
                        withAnimation {
                            isPresented = false
                        }
                    }
                    .transition(.opacity)
            }
            
            // Action Sheet 内容
            if isPresented {
                VStack(alignment: .leading, spacing: 0) {
                    
                    
                    ZStack {
                        // 背景层
                        HStack {
                            Spacer()
                            Button(action: { isPresented = false }) {
                                Image(systemName: "xmark")
                            }
                            .buttonStyle(PlainButtonStyle())
                            .padding(20)
                        }
                        
                        // 居中标题
                        Text("选择文件".localized())
                            .font(.headline)
                            .padding(.vertical, 16)
                    }
                    .frame(maxWidth: .infinity)
                    
                    // 文件选择选项
                    ForEach(FilePickerType.allCases, id: \.self) { type in
                        Button(action: {
                            
                            //if type == FilePickerType.library {
                            //    hintText = "档案库(暂未开放)"
                            //    isShowToast = true
                            //}else{
                                withAnimation {
                                    isPresented = false
                                    onTypeSelected?(type)
                                }
                            //}
                            
                        }) {
                            HStack {
                                Image(type.iconName)
                                    //.renderingMode(.template)
                                    //.foregroundStyle(ThemeManager.shared.getCurrentColorScheme() == .dark ? .white : .black)
                                    .foregroundStyle(Color(.label))
                                    .frame(width: 24)
                                
                                Text(type.description)
                                    .font(.body)
                                
                                Spacer()
                                
                                Image(systemName: "chevron.right")
                                    .foregroundColor(.secondary)
                            }
                            .padding(.vertical, 12)
                            .padding(.horizontal, 16)
                            .background(Color(.systemBackground))
                            .cornerRadius(10)
                            .contentShape(Rectangle())
                        }
                        .buttonStyle(PlainButtonStyle())
                        .padding(8)
                         
                    }
                    
                    VStack{}
                        .frame(height: 10)
                    
                }
                .padding(.horizontal)
                .background( Color(ThemeManager.shared.getCurrentColorScheme() == .dark ? .black : .init(hex: "#F9F9F9")) )
                .cornerRadius(16)
                .padding(.horizontal, 8)
                .padding(.bottom, 8)
                .shadow(radius: 10)
                .transition(.move(edge: .bottom))
                .zIndex(1)
            }
        }
        .animation(.easeInOut(duration: 0.25), value: isPresented)
        
        .toast(isPresenting: $isShowToast){
            AlertToast(displayMode: .alert, type: .regular, title: hintText)
        }
        
        
    }
}

