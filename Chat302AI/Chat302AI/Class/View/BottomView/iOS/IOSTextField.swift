//
//  IOSTextField.swift
//  GPTalks
//
//  Created by Zabir Raihan on 10/03/2024.
//

#if !os(macOS)
import SwiftUI
import PhotosUI
import AlertToast
import PopupView
import Toasts

 

struct IOSTextField: View {
    @Bindable var session: DialogueSession
    
    @EnvironmentObject var config: AppConfiguration  // 使用 @EnvironmentObject
    @Environment(\.presentToast) var presentToast
    
    @Environment(\.colorScheme) var colorScheme
    @Binding var resetMarker: Int
    @Binding var input: String
    var isReplying: Bool
    @FocusState var focused: Bool
    @Binding var selectedFuncCount : Int
    
    //var speechText: String
    @Binding var previewOn : Bool
    @State var hasImage = false
    
    @State var isShowMicrophone = false
    var onMicBtnTap: (Bool) -> Void
    
    var onAtModelBtnTap: (Bool) -> Void
    var previewBtnTap: (Bool) -> Void
    var clearContextBtnTap: (Bool) -> Void
    var selectedfuncBtnTap: (Bool) -> Void 
    
    @Binding var atModelString : String
    
    
    @StateObject private var speechManager = SpeechRecognizerManager()
    
    //艾特 别针 大脑 话筒 可见 上下文  网络
    //var imageArr = ["网络","大脑","话筒","艾特","可见","上下文"]
    var imageArr = ["网络","大脑","话筒","上下文"]
    @State private var textHeight: CGFloat = 40
    
    var send: () -> Void
    var stop: () -> Void
    
    @State var isShowToast = false
    // 提示文本（可选）
    @State private var hintText: String?

    @State var sendHidden = false
    
//    @State var isShowAlert = false
//    @State private var alertText = "自定义Api暂不支持"
    
    var body: some View {
          
        ZStack(alignment: .bottomTrailing) {
            
            VStack(spacing: 8) {
                
//                HStack{
//                    Spacer(minLength: 10)
//                    //@模型
//                    AtModelButton(buttonText: $atModelString) {
//                        onAtModelBtnTap(false)
//                         
//                    }
//                    .frame(height:atModelString.isEmpty ? 0 : 20)
//                    .frame(maxWidth: .infinity, alignment: .leading)
//                    Spacer()
//                }
//                .hidden(atModelString.isEmpty)
                
                // 输入框
                TextField("有什么问题尽管问我".localized(), text: $input, axis: .vertical) //"Send a message"
    //                .disableAutocorrection(true)
                    .font(.system(size: FontSettings().fontSize))
                    .focused($focused)
                    //.submitLabel(.send)
                    .onSubmit {
                        send()
                    }
                    .multilineTextAlignment(.leading)
                    .scrollIndicators(.automatic)
                    .lineLimit(1 ... 5)
                    //.padding(6)
                    .padding(.leading, 2)
                    .padding(.trailing, 3) // for avoiding send button
                    .frame(minHeight: imageSize + 7)
                    .background(
                        Color.gray.opacity(0.001)
                    )
                
                HStack{
                    VStack{}
                        .frame(width: 20)
                    
                    Button(action: {
                        if !config.isLogin || config.OAIkey.count == 0 {
                            // 发送通知，要求登录
                            NotificationCenter.default.post(name: .requireLogin, object: nil)
                            return
                        }
                        
                        selectedfuncBtnTap(true)
                        
                    }) {
                        ZStack(alignment: .topTrailing) {
                            // 主要内容区域（需要圆角的部分）
                            Image("对话选项")
                                .resizable()
                                .renderingMode(.template)
                                .frame(width: 30, height: 30)
                                .padding(.horizontal, 3)
                                .padding(.vertical, 3)
                                //.offset(x: -1, y: 1)
                                .background(selectedFuncCount > 0 ? Color.purple.opacity(0.2) : Color(.systemBackground))
                                .foregroundColor(.primary)
                                .frame(width: 29, height: 29)
                                .background(Color(.systemBackground))
                                .clipShape(RoundedRectangle(cornerRadius: 6))
                            
                            // 数字标记放在 ZStack 的顶层，不受圆角裁剪影响
                            if selectedFuncCount > 0 {
                                Text("\(selectedFuncCount)")
                                    .foregroundColor(.white)
                                    .padding(5)
                                    .font(.system(size: 10, weight: .bold))
                                    .frame(width: 16, height: 16)
                                    .background(Color.purple)
                                    .clipShape(Circle())
                                    .offset(x: 8, y: -8) // 调整偏移量确保在圆角外部
                            }
                        }
                        .frame(width: 35, height: 35)
                    }
                    //.disabled()
                    Spacer()
                }
                 

            }
             
            
            .padding(.horizontal, 15)
            //.padding(.vertical, 5)
            .padding(.top, 2)
            .padding(.bottom, 10)
            
            .cornerRadius(10)
            .background(ThemeManager.shared.getCurrentColorScheme() == .dark ? Color.gray.opacity(0.1) : Color(.systemBackground)) //输入框背景色 改这里  <<<<<<< --------------------------------------------------------
            
            /*
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.gray.opacity(0.7), lineWidth: 0.75)
            )*/
            
            .padding(6)
            
            .onChange(of: session.inputImages) {
                if !session.inputImages.isEmpty {
                    hasImage = true
                }else{
                    hasImage = false
                }
            }
            
            Group {
                if input.isEmpty && !isReplying && !hasImage  {
                     /**
                      Button(action: {
                          //onMicBtnTap()
                      }) {
                          Image("话筒")
                              .resizable()
                              .frame(width: 35, height: 35)
                              .padding(.horizontal ,5) // 使按钮实际大小为 44x44
                              .padding(.vertical,2)
                              //.renderingMode(.template) // 可修改颜色
                              //.foregroundColor(Color.init(hex: "#8E47F0"))
                              .offset(y:20)
                      }
                      */
                    
                    Button(action: {}) {
                        Image("话筒")
                            .resizable()
                            .frame(width: 35, height: 35)
                            .padding(.horizontal, 5)
                            .padding(.vertical, 2)
                            .offset(y: 20)
                    }
                    .simultaneousGesture(
                        DragGesture(minimumDistance: 0)
                            .onChanged { _ in
                                // 按下按钮开始录音
                                if !config.isLogin || config.OAIkey.count == 0 {
                                    // 发送通知，要求登录
                                    NotificationCenter.default.post(name: .requireLogin, object: nil)
                                     
                                    return
                                }else{
                                    if !speechManager.isRecording {
                                        speechManager.startRecording()
                                        onMicBtnTap(true)
                                    }
                                }
                            }
                            .onEnded { _ in
                                // 松开按钮停止录音
                                if speechManager.isRecording {
                                    speechManager.stopRecording()
                                    input = speechManager.recognizedText
                                    
                                    onMicBtnTap(false)
                                }
                            }
                    )
                    
                } else {
                    Group {
                        if isReplying {
                            StopButton(size: imageSize + 5) {
                                stop()
                            }
                        } else {
                            
                            SendButton(size: imageSize + 5) {
                                send()
                                sendHidden = true
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                    sendHidden = false
                                }
                                
                            }.hidden(sendHidden)
                        }
                    }
                    .offset(x: -8, y: 8)//(x: -4, y: -4)
                }
            }
            .offset(x: -20, y: -30)
            //.padding(20) // Increase tappable area 增加可触碰区域
            //.padding(20) // Cancel out visual expansion 取消视觉扩展
            
        }
        .hidden(isShowMicrophone)
        
        
        
        .onTapGesture {
            focused = true
            
        }
        .toast(isPresenting: $isShowToast){
              
            AlertToast(displayMode: .alert, type: .regular, title: hintText)
        }

        
        
    }
     
    

    @State private var imageOpacity: Double = 1.0
     
    
    private var imageSize: CGFloat {
        31
    }
}
  



#endif
