//
//  DialogueListItem.swift
//  GPTalks
//
//  Created by Zabir Raihan on 13/11/2023.
//

import SwiftUI
import AlertToast
import Toasts

struct DialogueListItem: View {
    
    @Environment(DialogueViewModel.self) private var viewModel
    @EnvironmentObject private var themeManager: ThemeManager
    
    var session: DialogueSession
    var mutiSelectBtnTap: (Bool) -> Void
    
    @State private var showRenameDialogue = false
    @State private var newName = ""
    
    @State private var isShowToast = false
    @State private var hintText = ""
    @State private var showLimitText = false
    @Environment(\.presentToast) var presentToast

     
    
    var body: some View {
        HStack(spacing: 0) {
            HStack {
                
                CustomText(session.title.isEmpty ? "新会话".localized() : session.title)
                    .lineLimit(1)
                
                Spacer()
                
                Image(systemName: "star.fill")
                    .foregroundStyle(.yellow)
                    .hidden(!session.isArchive)
                
                /*VStack(alignment:.leading,spacing:10) {
                    CustomText(session.title)
                        .bold()
                        .font(lastMessageFont)
                        .lineLimit(1)
                       
                    
                    HStack(alignment: .bottom) {
                        CustomText("\(session.conversations.count)" + "条对话") //+ "  " + "\(session.configuration.model)")
                             
                            .foregroundStyle(.secondary)
                            .font(.footnote)
                            .lineLimit(1)
                        Spacer()
                        
                        #if !os(visionOS)
                         
                        CustomText(formatDateToFull(session.date))
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                            .opacity(0.9)
                         
                        #endif
                    }
                }*/
                 
                
                if viewModel.isMultiSelectMode {
                    Image(systemName: viewModel.selectedDialogues.contains(session) ? "checkmark.circle.fill" : "circle")
                        .renderingMode(.template)
                        .foregroundStyle(Color.init(hex: "#8E47F1"))
                        .onTapGesture {
                            if viewModel.selectedDialogues.contains(session) {
                                viewModel.selectedDialogues.remove(session)
                            } else {
                                viewModel.selectedDialogues.insert(session)
                            }
                        }
                }
                 
            }
            .padding(.horizontal,10)
            .padding(.vertical,15)
            .backgroundStyle(Color(themeManager.getCurrentColorScheme() == .dark ? .black : .red))
            .background(
                RoundedRectangle(cornerRadius: 10)  // 圆角 10
                    //.fill(Color.gray.opacity(0.1))  // 背景色 + 透明度
                    //.fill(Color(themeManager.getCurrentColorScheme() == .dark ? .black : .red))
                    .fill(themeManager.getCurrentColorScheme() == .dark ? Color(.systemGray6) : Color.white)
            )
             
        }//.frame(minHeight:50)
        .padding(.vertical,-5)
        
//        .padding(paddingVal)
//        .frame(height: lastMessageMaxHeight)
        .alert("重命名会话".localized(), isPresented: $showRenameDialogue) {
            // 确保有一个状态变量来存储输入，并限制长度
            TextField("输入新命名".localized(), text: $newName)
                .onAppear {
                    newName = session.title
                }
                .onChange(of: newName) { newValue in
                    // 当输入内容超过20个字符时，自动截断
                    if newValue.count > 20 {
                        
//                        hintText = "标题限制20字以内".localized()
//                        showLimitText = true
                        
                        let toast = ToastValue(
                            message: "标题限制20字以内".localized()
                        )
                        presentToast(toast)
 
                        newName = String(newValue.prefix(20))
                    }
                }
            Button("重命名".localized()) {
                session.rename(newTitle: newName)
            }
            Button("取消".localized(), role: .cancel) {
                showRenameDialogue = false
                newName = session.title
            }
        }
        
        
        
        .contextMenu {
            Group {
                if viewModel.selectedDialogues.count < 2 {
                    renameButton
                    
                }
                
                Button {
                    mutiSelectBtnTap(true)
                } label: {
                    Label("多选".localized(), systemImage: "checkmark.circle")
                }
                .tint(.accentColor)
                
                
                Button {
                    session.toggleArchive()
                } label: {
                    Label(session.isArchive ? "取消收藏".localized() : "收藏".localized(), systemImage: session.isArchive ? "star.slash" : "star")
                }
                .tint(.orange)
                //mutiSelectBtn //多选
                //archiveButton //星星 收藏
                //deleteButton  //删除
                
                
                if viewModel.selectedDialogues.count > 1 {
                    Button {
                        viewModel.deleteSelectedDialogues()
                         
                    } label: {
                        Label("删除".localized(), systemImage: "trash")
                    }
                } else {
                    Button(role: .destructive) {
                        
                        if viewModel.allDialogues.count == 1 {
                            hintText = "至少保留一条会话"
                            isShowToast = true
                        }else{
                            viewModel.deleteDialogue(session)
                            
                            NotificationCenter.default.post(name: .deleteNeedRefresh, object: nil)

                        }
                        
                        
                    } label: {
                        Label("删除".localized(), systemImage: "trash")
                    }
                }
                
                
                
                if viewModel.selectedDialogues.count > 1 {
                    Button {
                        viewModel.toggleStarredDialogues()
                    } label: {
                        Label("Star/Unstar", systemImage: "star")
                    }
                }
            }
            .labelStyle(.titleAndIcon)
        }
        .id("context_menu_\(Locale.current.identifier)")
        
        .swipeActions(edge: .trailing) {
            singleDeleteButton
        }
        //.swipeActions(edge: .leading) {
            //archiveButton //星星 收藏
        //}
         
        .toast(isPresenting: $isShowToast){
            AlertToast(displayMode: .alert, type: .regular, title: hintText)
        }
        
        .toast(isPresenting: $showLimitText){
            AlertToast(displayMode: .banner(.slide), type: .systemImage("pencil.and.list.clipboard", .red), title: hintText)
        }
        
        
        
        
    }
    
    // 将 Date 转换为 "年-月-日 时:分:秒" 格式的字符串
    func formatDateToFull(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss" // 设置格式为 "年-月-日 时:分:秒"
        return formatter.string(from: date)
    }
    
    var archiveButton: some View {
        Button {
            session.toggleArchive()
        } label: {
            Label(session.isArchive ? "取消收藏".localized() : "收藏".localized(), systemImage: session.isArchive ? "star.slash" : "star")
        }
        .tint(.orange)
    }
    
    var deleteButton: some View {
        if viewModel.selectedDialogues.count > 1 {
            Button {
                viewModel.deleteSelectedDialogues()
                 
            } label: {
                Label("删除".localized(), systemImage: "trash")
            }
        } else {
            Button(role: .destructive) {
                
                if viewModel.allDialogues.count == 1 {
                    hintText = "至少保留一条会话"
                    isShowToast = true
                }else{
                    viewModel.deleteDialogue(session)
                    
                    NotificationCenter.default.post(name: .deleteNeedRefresh, object: nil)

                }
                
                
            } label: {
                Label("删除".localized(), systemImage: "trash")
            }
        }
    }
    
    var singleDeleteButton: some View {
        Button(role: .destructive) {
            
            viewModel.deleteDialogue(session)
            
            if viewModel.allDialogues.count == 0{
                viewModel.selectedDialogue = viewModel.addNewDialogue()
            }else{
                if let session1 =  viewModel.allDialogues.first {
                    
                    viewModel.selectedDialogue = session1
                }
            }
            
            
        } label: {
            Label("删除".localized(), systemImage: "trash")
        }
    }
    
    var renameButton: some View {
        Button {
            newName = session.title
            showRenameDialogue.toggle()
        } label: {
            Label("重命名".localized(), systemImage: "pencil")
        }
        .tint(.accentColor)
    }
    
    //多选
    var mutiSelectBtn: some View {
        
        Button {
            mutiSelectBtnTap(true)
        } label: {
            Label("多选".localized(), systemImage: "checkmark.circle")
        }
        .tint(.accentColor)
    }
    
    
    
    
    private var paddingVal: CGFloat {
        #if os(macOS)
            7
        #else
            0
        #endif
    }

    private var imgToTextSpace: CGFloat {
        #if os(macOS)
        10
        #else
        13
        #endif
    }

    private var lastMessageMaxHeight: CGFloat {
        #if os(macOS)
        55
        #else
        70
        #endif
    }

    private var imageSize: CGFloat {
        #if os(macOS)
        36
        #else
        50
        #endif
    }

    private var imageRadius: CGFloat {
        #if os(macOS)
        11
        #else
        16
        #endif
    }

    private var titleFont: Font {
        #if os(macOS)
        Font.system(.body)
        #else
        Font.system(.headline)
        #endif
    }

    private var lastMessageFont: Font {
        #if os(macOS)
        Font.system(.body)
        #else
        Font.system(.subheadline)
        #endif
    }

    private var textLineLimit: Int {
        #if os(macOS)
        1
        #else
        2
        #endif
    }
}
