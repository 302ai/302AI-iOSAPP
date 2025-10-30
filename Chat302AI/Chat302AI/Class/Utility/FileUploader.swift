//
//  FileUploader.swift
//  Chat302AI
//
//  Created by Adswave on 2025/9/28.
//

import SwiftUI
import Foundation

// 上传响应模型
struct UploadResponse: Codable {
    let code: Int
    let data: String?
    let message: String?
    
    var success: Bool {
        return code == 200
    }
}

// 上传状态
enum UploadState {
    case idle
    case uploading(progress: Double)
    case success(response: UploadResponse)
    case failure(error: String)
}

class FileUploader: ObservableObject {
    @Published var uploadState: UploadState = .idle
    @Published var uploadProgress: Double = 0.0
    
    private let uploadURL = URL(string: "https://api.302.ai/302/upload-file")!
    
    // 添加回调类型
    typealias UploadCompletion = (Result<UploadResponse, Error>) -> Void
    
    // 上传文件方法（带回调）
    func uploadFile(fileURL: URL, authorization: String, completion: UploadCompletion? = nil) {
        guard FileManager.default.fileExists(atPath: fileURL.path) else {
            let error = NSError(domain: "FileError", code: -1, userInfo: [NSLocalizedDescriptionKey: "文件不存在"])
            uploadState = .failure(error: "文件不存在")
            completion?(.failure(error))
            return
        }
        
        uploadState = .uploading(progress: 0.0)
        uploadProgress = 0.0
        
        // 创建请求
        var request = URLRequest(url: uploadURL)
        request.httpMethod = "POST"
        request.setValue(authorization, forHTTPHeaderField: "Authorization")
        
        // 创建边界
        let boundary = "Boundary-\(UUID().uuidString)"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        // 创建请求体
        do {
            let fileData = try Data(contentsOf: fileURL)
            let fileName = fileURL.lastPathComponent.removingPercentEncoding ?? fileURL.lastPathComponent
            request.httpBody = createMultipartFormData(boundary: boundary, fileData: fileData, fileName: fileName)
        } catch {
            uploadState = .failure(error: "读取文件失败: \(error.localizedDescription)")
            completion?(.failure(error))
            return
        }
        
        // 创建上传任务
        let task = URLSession.shared.uploadTask(with: request, from: request.httpBody!) { [weak self] data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    self?.uploadState = .failure(error: "上传失败: \(error.localizedDescription)")
                    completion?(.failure(error))
                    return
                }
                
                guard let data = data else {
                    let error = NSError(domain: "ServerError", code: -2, userInfo: [NSLocalizedDescriptionKey: "服务器返回空数据"])
                    self?.uploadState = .failure(error: "服务器返回空数据")
                    completion?(.failure(error))
                    return
                }
                
                do {
                    let uploadResponse = try JSONDecoder().decode(UploadResponse.self, from: data)
                    
                    if uploadResponse.success {
                        self?.uploadState = .success(response: uploadResponse)
                        completion?(.success(uploadResponse))
                    } else {
                        let errorMessage = uploadResponse.message ?? "上传失败 (错误码: \(uploadResponse.code))"
                        let error = NSError(domain: "UploadError", code: uploadResponse.code, userInfo: [NSLocalizedDescriptionKey: errorMessage])
                        self?.uploadState = .failure(error: errorMessage)
                        completion?(.failure(error))
                    }
                } catch {
                    self?.uploadState = .failure(error: "解析响应失败: \(error.localizedDescription)")
                    completion?(.failure(error))
                }
            }
        }
        
        // 监听上传进度
        let observation = task.progress.observe(\.fractionCompleted) { [weak self] progress, _ in
            DispatchQueue.main.async {
                let currentProgress = progress.fractionCompleted
                self?.uploadProgress = currentProgress
                self?.uploadState = .uploading(progress: currentProgress)
            }
        }
        
        task.resume()
        
        // 保持观察者的引用
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            _ = observation
        }
    }
    
    
    // 创建 multipart/form-data 请求体
    private func createMultipartFormData(boundary: String, fileData: Data, fileName: String, fieldName: String = "file") -> Data {
        var body = Data()
        
        // 添加文件数据
        body.append("--\(boundary)\r\n")
        body.append("Content-Disposition: form-data; name=\"\(fieldName)\"; filename=\"\(fileName)\"\r\n")
        body.append("Content-Type: application/octet-stream\r\n\r\n")
        body.append(fileData)
        body.append("\r\n")
        
        // 结束边界
        body.append("--\(boundary)--\r\n")
        
        return body
    }
    
    // 重置上传状态
    func reset() {
        uploadState = .idle
        uploadProgress = 0.0
    }
}




// Data 扩展，用于方便地添加字符串到 Data
extension Data {
    mutating func append(_ string: String) {
        if let data = string.data(using: .utf8) {
            append(data)
        }
    }
}

// SwiftUI 视图
struct FileUploadView: View {
    @StateObject private var uploader = FileUploader() 
    @State private var authorizationToken = "你的授权令牌"
    @State private var selectedFileURL: URL?
    @State private var showingFilePicker = false
    
    var body: some View {
        VStack(spacing: 30) {
            // 标题
            Text("文件上传")
                .font(.title)
                .bold()
            
            // 授权令牌输入
            VStack(alignment: .leading) {
                Text("授权令牌")
                    .font(.headline)
                SecureField("输入 Authorization Token", text: $authorizationToken)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
            }
            
            // 文件选择
            VStack(alignment: .leading) {
                Text("选择文件")
                    .font(.headline)
                
                if let fileURL = selectedFileURL {
                    HStack {
                        Image(systemName: "doc.fill")
                            .foregroundColor(.blue)
                        Text(fileURL.lastPathComponent.removingPercentEncoding ?? fileURL.lastPathComponent)
                            .foregroundColor(.green)
                            .lineLimit(1)
                    }
                } else {
                    Text("未选择文件")
                        .foregroundColor(.gray)
                }
                
                Button("选择文件") {
                    showingFilePicker = true
                }
                .buttonStyle(.bordered)
            }
            
            // 上传按钮
            Button(action: startUpload) {
                Text(uploadButtonText)
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity, minHeight: 50)
                    .background(uploadButtonColor)
                    .cornerRadius(10)
            }
            .disabled(!canUpload)
            
            // 进度显示
            if case .uploading(let progress) = uploader.uploadState {
                VStack(spacing: 10) {
                    ProgressView(value: uploader.uploadProgress, total: 1.0)
                        .progressViewStyle(LinearProgressViewStyle())
                        .tint(.blue)
                    
                    Text("上传进度: \(Int(uploader.uploadProgress * 100))%")
                        .font(.caption)
                        .foregroundColor(.blue)
                }
            }
            
            // 状态显示
            Group {
                switch uploader.uploadState {
                case .idle:
                    EmptyView()
                case .uploading:
                    EmptyView()
                case .success(let response):
                    VStack(spacing: 15) {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                            .font(.largeTitle)
                        
                        Text("上传成功！")
                            .foregroundColor(.green)
                            .font(.headline)
                        
                        if let fileURL = response.data {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("文件地址:")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                                
                                Text(fileURL)
                                    .font(.caption)
                                    .foregroundColor(.blue)
                                    .textSelection(.enabled)
                                    .padding()
                                    .background(Color.blue.opacity(0.1))
                                    .cornerRadius(8)
                                
                                // 复制链接按钮
                                Button(action: {
                                    UIPasteboard.general.string = fileURL
                                }) {
                                    HStack {
                                        Image(systemName: "doc.on.doc")
                                        Text("复制链接")
                                    }
                                    .font(.caption)
                                }
                                .buttonStyle(.bordered)
                            }
                        }
                        
                        Text("状态码: \(response.code)")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                case .failure(let error):
                    VStack(spacing: 10) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.red)
                            .font(.largeTitle)
                        Text("上传失败")
                            .foregroundColor(.red)
                            .font(.headline)
                        Text(error)
                            .font(.caption)
                            .foregroundColor(.red)
                            .multilineTextAlignment(.center)
                    }
                }
            }
            
            Spacer()
        }
        .padding()

    }
    
    // 计算属性
    private var canUpload: Bool {
        guard selectedFileURL != nil && !authorizationToken.isEmpty else {
            return false
        }
        
        if case .uploading = uploader.uploadState {
            return false
        }
        
        return true
    }
    
    private var uploadButtonText: String {
        if case .uploading = uploader.uploadState {
            return "上传中..."
        }
        return "开始上传"
    }
    
    private var uploadButtonColor: Color {
        if !canUpload {
            return .gray
        }
        return .blue
    }
    
    private func startUpload() {
        guard let fileURL = selectedFileURL else { return }
    
        uploader.uploadFile(fileURL: fileURL, authorization: "Bearer sk-sx6464FSKRpX5eODxMQHTKbNuoeiz9iMYdbdoNzeTbMLuau7")
    }
}






// 文件选择器
//struct DocumentPicker: UIViewControllerRepresentable {
//    @Binding var selectedURL: URL?
//    @Environment(\.presentationMode) var presentationMode
//    
//    func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
//        let picker = UIDocumentPickerViewController(forOpeningContentTypes: [.item])
//        picker.allowsMultipleSelection = false
//        picker.delegate = context.coordinator
//        return picker
//    }
//    
//    func updateUIViewController(_ uiViewController: UIDocumentPickerViewController, context: Context) {}
//    
//    func makeCoordinator() -> Coordinator {
//        Coordinator(self)
//    }
//    
//    class Coordinator: NSObject, UIDocumentPickerDelegate {
//        let parent: DocumentPicker
//        
//        init(_ parent: DocumentPicker) {
//            self.parent = parent
//        }
//        
//        func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
//            guard let url = urls.first else { return }
//            parent.selectedURL = url
//            parent.presentationMode.wrappedValue.dismiss()
//        }
//        
//        func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
//            parent.presentationMode.wrappedValue.dismiss()
//        }
//    }
//}

// 使用示例
//struct ContentView: View {
//    var body: some View {
//        NavigationView {
//            FileUploadView()
//                .navigationBarTitle("文件上传示例", displayMode: .inline)
//        }
//    }
//}

// 预览
//#Preview {
//    ContentView()
//}

// 简单的上传工具函数
struct SimpleUploader {
    static func uploadFile(fileURL: URL, authorization: String, completion: @escaping (Result<UploadResponse, Error>) -> Void) {
        let uploader = FileUploader()
        
        // 监听上传状态
        let cancellable = uploader.$uploadState.sink { state in
            switch state {
            case .success(let response):
                completion(.success(response))
            case .failure(let error):
                completion(.failure(NSError(domain: "UploadError", code: -1, userInfo: [NSLocalizedDescriptionKey: error])))
            default:
                break
            }
        }
        
        uploader.uploadFile(fileURL: fileURL, authorization: authorization)
        
        // 保持引用（在实际使用中需要适当管理）
        DispatchQueue.main.asyncAfter(deadline: .now() + 30) {
            _ = cancellable
        }
    }
}
