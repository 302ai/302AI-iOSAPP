//
//  InputComponents.swift
//  GPTalks
//
//  Created by Zabir Raihan on 28/03/2024.
//

import SwiftUI

struct SendButton: View {
    var size: CGFloat
    var send: () -> Void
    @EnvironmentObject var config: AppConfiguration
    
    
    var body: some View {
        Button {
            
            if !config.isLogin || config.OAIkey.count == 0 {
                // 发送通知，要求登录
                NotificationCenter.default.post(name: .requireLogin, object: nil)
                return
            }else{
                
                send()
            }
            
            
        } label: {
            Image("发送按钮1") //arrow.up.circle.fill
                .resizable()
                .fontWeight(.semibold)
                .foregroundStyle(.white, Color.blue)
                .frame(width: size-6, height: size-6)
        }
        .keyboardShortcut(.return, modifiers: .command)
    }
}

struct SendButton2: View {
    var size: CGFloat
    var send: () -> Void
    
    var body: some View {
        Button {
            send()
        } label: {
            Image(systemName: "arrow.up.circle.fill")
                .resizable()
                .fontWeight(.bold)
                .foregroundStyle(.gray, Color.accentColor)
                .frame(width: size, height: size)
        }
        .keyboardShortcut(.defaultAction)
    }
}

struct StopButton: View {
    var size: CGFloat
    var stop: () -> Void
    
    var body: some View {
        Button {
            stop()
        } label: {
            Image(systemName: "stop.circle.fill")
                .resizable()
                .fontWeight(.semibold)
                .foregroundStyle(.red)
                .frame(width: size, height: size)
        }
        .keyboardShortcut("d", modifiers: .command)
    }
}

#Preview {
    
    
    StopButton(size: 22) {
        
    }
}
