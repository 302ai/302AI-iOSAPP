//
//  ImportPreviewers.swift
//  GPTalks
//
//  Created by Zabir Raihan on 07/04/2024.
//

import SwiftUI


struct CustomImportedFilesView: View {
    @Bindable var session: DialogueSession  // 对话会话数据
    
    // 根据编辑状态选择当前文件数组
    private var currentFiles: Binding<[String]> {
        session.isEditing ? $session.editingImages : $session.inputImages
    }
    
    func normalizedImageURL(_ original: String) -> String {
        if original.hasPrefix("file://") {
            return original
        } else if original.contains("/") { // 假设是本地路径
            return "file://" + (original.starts(with: "/") ? original : "/" + original)
        } else {
            return original
        }
    }
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(currentFiles.wrappedValue, id: \.self) { fileURL in
                    if isImageFile(fileURL) {
                        // 图片预览组件
                        //ImagePreviewer(imageURL: URL(string: fileURL)!) {
                        ImagePreviewer(imageURL: URL(string:normalizedImageURL(fileURL))!) {
                        
                            removeFile(fileURL)
                        }
                    } else {
                        // 文档文件显示组件
//                        DocumentFileView(fileURL: fileURL) {
//                            removeFile(fileURL)
//                        }
                         
                        FileItemView(fileName: fileURL) {
                            removeFile(fileURL)
                        } 
                        
                    }
                }
            }
            .padding(.horizontal, 15)
            .frame(height: 80)  // 增加高度以适应文档信息
        }
    }
    
    // 移除文件方法
    private func removeFile(_ fileURL: String) {
        currentFiles.wrappedValue.removeAll { $0 == fileURL }
    }
    
    // 判断是否为图片文件
    private func isImageFile(_ url: String) -> Bool {
        let imageExtensions = ["jpg", "jpeg", "png", "gif", "webp"]
        let ext = (url as NSString).pathExtension.lowercased()
        return imageExtensions.contains(ext)
    }
}

// 文档文件视图组件
struct DocumentFileView: View {
    let fileURL: String
    let onDelete: () -> Void
    
    // 获取文件信息
    private var fileName: String {
        (fileURL as NSString).lastPathComponent
    }
    
    private var fileExtension: String {
        (fileURL as NSString).pathExtension.uppercased()
    }
    
    private var fileSize: String {
        // 这里需要实现获取文件大小的逻辑
        // 示例返回固定值，实际应该计算真实大小
        getFileSize(url: fileURL)
    }
     
    
    private func getFileSize(url: String) -> String {
        guard let fileUrl = URL(string: url) else { return "0KB" }
        
        do {
            let resources = try fileUrl.resourceValues(forKeys: [.fileSizeKey])
            let fileSizeInBytes = resources.fileSize ?? 0
            
            // 转换为更友好的显示格式
            if fileSizeInBytes >= 1048576 { // 大于等于1MB
                return String(format: "%.1fMB", Double(fileSizeInBytes) / 1048576.0)
            } else if fileSizeInBytes >= 1024 { // 大于等于1KB
                return String(format: "%.0fKB", Double(fileSizeInBytes) / 1024.0)
            } else {
                return "\(fileSizeInBytes)B"
            }
        } catch {
            print("获取文件大小失败: \(error)")
            return "0KB"
        }
    }
    
    
    private func getRemoteFileSize(url: String) -> String {
        guard let url = URL(string: url) else { return "0KB" }
        
        var request = URLRequest(url: url)
        request.httpMethod = "HEAD" // 只请求头信息
        
        let semaphore = DispatchSemaphore(value: 0)
        var fileSize = "0KB"
        
        URLSession.shared.dataTask(with: request) { (_, response, _) in
            if let httpResponse = response as? HTTPURLResponse,
               let length = httpResponse.allHeaderFields["Content-Length"] as? String,
               let bytes = Int64(length) {
                
                if bytes >= 1048576 {
                    fileSize = String(format: "%.1fMB", Double(bytes) / 1048576.0)
                } else if bytes >= 1024 {
                    fileSize = String(format: "%.0fKB", Double(bytes) / 1024.0)
                } else {
                    fileSize = "\(bytes)B"
                }
            }
            semaphore.signal()
        }.resume()
        
        _ = semaphore.wait(timeout: .now() + 5) // 5秒超时
        return fileSize
    }
    
    
    
    private var fileIcon: String {
        switch fileExtension.lowercased() {
        case "pdf": return "doc.richtext.fill"
        case "ppt", "pptx": return "chart.presentation.fill"
        case "xls", "xlsx": return "chart.bar.doc.horizontal.fill"
        case "doc", "docx": return "doc.text.fill"
        default: return "doc.fill"
        }
    }
    
    var body: some View {
        HStack(spacing: 8) {
            // 文件图标
            Image(systemName: fileIcon)
                .foregroundColor(.blue)
                .font(.system(size: 20))
            
            VStack(alignment: .leading, spacing: 4) {
                // 文件名（不带扩展名）
                Text((fileName as NSString).deletingPathExtension)
                    .font(.system(size: 12))
                    .lineLimit(1)
                
                // 文件大小和类型
                HStack {
                    Text(fileExtension)
                        .font(.system(size: 10))
                        .padding(.horizontal, 4)
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(3)
                    
                    Text(fileSize)
                        .font(.system(size: 10))
                        .foregroundColor(.gray)
                }
            }
            .frame(width: 120, alignment: .leading)
            
            // 删除按钮
            Button(action: onDelete) {
                Image(systemName: "xmark.circle.fill")
                    .foregroundColor(.gray)
            }
        }
        .padding(8)
        .background(Color.gray.opacity(0.1))
        .cornerRadius(8)
    }
}

#if os(macOS)
struct CustomTextEditorView: View {
    @Bindable var session: DialogueSession
    
    private var currentMessage: Binding<String> {
        session.isEditing ? $session.editingMessage : $session.input
    }
    
    private var containsPdfOrAudio: Bool {
        return !session.inputPDFPath.isEmpty || !session.inputAudioPath.isEmpty || !session.editingPDFPath.isEmpty || !session.editingPDFPath.isEmpty
    }
    
    private var containsImage: Bool {
        return !session.inputImages.isEmpty || !session.editingImages.isEmpty
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            if containsImage {
                ScrollView(.horizontal) {
                    HStack {
                        CustomImportedImagesView(session: session)
                    }
                    .padding(10)
                }
            }

            MacTextEditor(input: currentMessage)
        }
        .roundedRectangleOverlay()
    }
}
#else
struct CustomTextEditorView: View {
    @Bindable var session: DialogueSession
    @FocusState var focused: Bool
    @Binding var selectedFuncCount : Int
    
    //@Binding var previewOn : Bool
    //@Binding var hasImage : Bool
    
    var extraAction: (() -> Void)
    
    var onCustomMicBtnTap: (Bool) -> Void
    
    var onAtModelBtnTap: (Bool) -> Void
    var previewBtnTap: (Bool) -> Void
    var clearContextBtnTap: (Bool) -> Void
    var selectedFuncBtnTap: (Bool) -> Void 
    
    @Binding var atModelString : String 
    
    var currentMessage: Binding<String> {
          
        session.isEditing ? $session.editingMessage : $session.input
    }
    
    var body: some View {
            
        
        IOSTextField(session:session, resetMarker:$session.resetMarker, input: currentMessage, isReplying:  session.isReplying, focused: _focused, selectedFuncCount:$selectedFuncCount, previewOn: $session.previewOn, onMicBtnTap: { press in
            
            onCustomMicBtnTap(press)
            
        }, onAtModelBtnTap: { isAtModel in
            onAtModelBtnTap(isAtModel)
        }, previewBtnTap: { preview in
            //预览
            previewBtnTap(preview)
            
        }, clearContextBtnTap: { clearContext in
            //clear context
            clearContextBtnTap(clearContext)
        },selectedfuncBtnTap:{ selectedBtn in
            
            selectedFuncBtnTap(selectedBtn)
            
        }, atModelString: $atModelString ) {
            focused = false
            
            //发送 send
            Task { @MainActor in
                extraAction()
                await session.sendAppropriate()
            }
        }stop: {
            session.stopStreaming()
        }
         
 
 
    }
}
#endif

struct CustomCrossButton: View {
    var action: () -> Void
    
    var body: some View {
        Button {
            action()
        } label: {
            //Image(systemName: "xmark.circle.fill")
            Image("叉叉")
                .resizable()
                //.foregroundStyle(.background)
                //.background(.primary, in: Circle())
                .frame(width: 20, height:20)
        }
        .padding(30)
        .buttonStyle(.plain)
    }
}
