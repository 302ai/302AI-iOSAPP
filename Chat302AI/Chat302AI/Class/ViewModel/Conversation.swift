//
//  Conversation.swift
//  GPTalks
//
//  Created by Zabir Raihan on 27/11/2024.
//

import OpenAI
import SwiftUI
import CoreData

enum ConversationRole: String, Codable, CaseIterable {
    case user
    case assistant
    case system

    func toChatRole() -> ChatQuery.ChatCompletionMessageParam.Role {
        switch self {
        case .user:
            return .user
        case .assistant:
            return .assistant
        case .system:
            return .system
        }
    }
}

import Foundation

@Observable class Conversation: Codable, Identifiable, Hashable, Equatable {
    var id: UUID
    var date: Date
    var role: ConversationRole
    var content: String  //json
    var avatar: String
    var reasoning: String
    var expandedReasoning: Bool  //展开思考过程
    var like : Bool   //赞    //为什么就是无法保存
    var unlike : Bool  //踩    //为什么就是无法保存
    var imagePaths: [String]
    var audioPath: String
    var pdfPath: String
    var toolRawValue: String
    var arguments: String   //标记预设提示词
    var atModelName: String // @艾特模型
    var isReplying: Bool
    var contentS: String
    var codeFileName : String

    init(id: UUID = UUID(), date: Date = Date(), role: ConversationRole, content: String,avatar:String="",reasoning:String="",expandedReasoning:Bool=false,like:Bool=false,unlike:Bool=false, imagePaths: [String] = [], audioPath: String = "", pdfPath: String = "", toolRawValue: String = "", arguments: String = "",atModelName:String, isReplying: Bool = false,contentS: String,codeFileName: String = "") {
        self.id = id
        self.date = date
        self.role = role
        self.content = content
        self.avatar = avatar
        self.reasoning = reasoning
        self.expandedReasoning = expandedReasoning
        self.like = like     //为什么就是无法保存
        self.unlike = unlike    //为什么就是无法保存
        self.imagePaths = imagePaths
        self.audioPath = audioPath
        self.pdfPath = pdfPath
        self.toolRawValue = toolRawValue
        self.arguments = arguments
        self.atModelName = atModelName
        self.isReplying = isReplying
        self.contentS = contentS
        self.codeFileName = codeFileName
    }

    static func == (lhs: Conversation, rhs: Conversation) -> Bool {
        lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    func toChat(imageAsPath: Bool = false,generateTitle:Bool = false) -> ChatQuery.ChatCompletionMessageParam {
        let chatRole = role.toChatRole()

        if chatRole == .user && !audioPath.isEmpty {
            let audioContent = content + "\n" + audioPath
            return .init(role: chatRole, content: audioContent)!
        } else if chatRole == .user && !pdfPath.isEmpty {
            let pdfContent = content + "\n" + pdfPath
            return .init(role: chatRole, content: pdfContent)!
        } else if chatRole == .tool {
            return .init(role: chatRole, content: content, name: toolRawValue, toolCallId: "")!
        } else if chatRole == .assistant && !imagePaths.isEmpty {
            if imageAsPath {
                let imageContent = content + "\n" + imagePaths.joined(separator: "|||")
                return .init(role: chatRole, content: imageContent)!
            } else {
                return createVisionMessage(conversation: self)
            }
        } else if chatRole == .user && !imagePaths.isEmpty {
            if imageAsPath {
                
                let imageContent = content + "\n" + imagePaths.joined(separator: "|||")
                return .init(role: chatRole, content: imageContent)!
                
            } else {
                if generateTitle {
                    return .init(role: chatRole, content: content)!
                }else{
                    return createVisionMessage(conversation: self)
                }
            }
        }

        return .init(role: chatRole, content: content)!
    }
}

// 判断是否为图片文件
//private func isImageFile(_ url: String) -> Bool {
//    let imageExtensions = ["jpg", "jpeg", "png", "gif", "webp"]
//    let ext = (url as NSString).pathExtension.lowercased()
//    return imageExtensions.contains(ext)
//}


//func createVisionMessage(conversation: Conversation) -> ChatQuery.ChatCompletionMessageParam {
//    return .init(role: .user,
//                 content:
//                    [.init(chatCompletionContentPartTextParam: .init(text: conversation.content))] +
//                 conversation.imagePaths.map { path in
//                        .init(chatCompletionContentPartImageParam:.init(imageUrl: .init( url: "data:image/jpeg;base64," + loadImageData(from: path)!.base64EncodedString(), detail: .auto  )
//                    )
//            )
//    })!
//}



func createVisionMessage(conversation: Conversation) -> ChatQuery.ChatCompletionMessageParam {
    var visionContent: [ChatQuery.ChatCompletionMessageParam.UserMessageParam.Content.VisionContent] = [
        .chatCompletionContentPartTextParam(.init(text: conversation.content))
    ]
    
    // 处理所有文件附件
    visionContent += conversation.imagePaths.compactMap { path in
        createBase64FileContent(filePath: path)
    }
    
    return .user(.init(content: .vision(visionContent)))
}

func createBase64FileContent(filePath: String) -> ChatQuery.ChatCompletionMessageParam.UserMessageParam.Content.VisionContent? {
    guard let fileData = loadFileData(from: filePath) else {
        return nil
    }
    
    // 检查文件大小，避免发送过大文件
    if !isFileSizeAcceptable(fileData: fileData, maxSize: 20 * 1024 * 1024) {
        return createOversizedFileContent(filePath: filePath, fileData: fileData)
    }
    
    let fileExtension = (filePath as NSString).pathExtension.lowercased()
    let base64String = fileData.base64EncodedString()
    let fileName = (filePath as NSString).lastPathComponent
    
    let mimeType = getMimeType(for: fileExtension)
    
    if mimeType.hasPrefix("image/") {
        // 图片文件使用image content part
        let imageUrl = ChatQuery.ChatCompletionMessageParam.UserMessageParam.Content.VisionContent.ChatCompletionContentPartImageParam.ImageURL(
            url: "data:\(mimeType);base64,\(base64String)",
            detail: .auto
        )
        let imagePart = ChatQuery.ChatCompletionMessageParam.UserMessageParam.Content.VisionContent.ChatCompletionContentPartImageParam(imageUrl: imageUrl)
        return .chatCompletionContentPartImageParam(imagePart)
    } else {
        // 其他文件类型：创建包含base64数据的文本消息
        var  textContent = ""
        if fileExtension ==  "pdf" {
            textContent = "\(fileName).\(fileExtension.uppercased())"
        }else{
            let textContent = """
            📄 文件附件: \(fileName)
            📊 类型: \(fileExtension.uppercased())
            📏 大小: \(formatFileSize(fileData.count))
            🔗 Base64 String: data:\(mimeType);base64,\(base64String)
            """
        }
        
         
        let textPart = ChatQuery.ChatCompletionMessageParam.UserMessageParam.Content.VisionContent.ChatCompletionContentPartTextParam(text: textContent)
        return .chatCompletionContentPartTextParam(textPart)
    }
}

func createOversizedFileContent(filePath: String, fileData: Data) -> ChatQuery.ChatCompletionMessageParam.UserMessageParam.Content.VisionContent {
    let fileExtension = (filePath as NSString).pathExtension.lowercased()
    let fileName = (filePath as NSString).lastPathComponent
    let mimeType = getMimeType(for: fileExtension)
    
    // 对于过大的文件，只发送文件信息和部分base64数据
    let partialBase64 = fileData.prefix(1024).base64EncodedString()
    
    let textContent = """
    ⚠️ 文件过大: \(fileName)
    📊 类型: \(fileExtension.uppercased())
    📏 大小: \(formatFileSize(fileData.count)) (超过20MB限制)
    🔗 部分Base64预览: data:\(mimeType);base64,\(partialBase64)...
    💡 提示: 文件过大，建议压缩或使用链接分享
    """
    
    let textPart = ChatQuery.ChatCompletionMessageParam.UserMessageParam.Content.VisionContent.ChatCompletionContentPartTextParam(text: textContent)
    return .chatCompletionContentPartTextParam(textPart)
}

//func loadFileData(from filePath: String) -> Data? {
//    guard let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
//        print("Documents directory not found.")
//        return nil
//    }
//    
//    let fileURL = documentsDirectory.appendingPathComponent(filePath)
//    
//    do {
//        let data = try Data(contentsOf: fileURL)
//        return data
//    } catch {
//        print("Failed to load file data from \(filePath): \(error.localizedDescription)")
//        return nil
//    }
//}

func loadFileData(from filePath: String) -> Data? {
    // 如果已经是完整的file URL
    if filePath.hasPrefix("file://") {
        guard let fileURL = URL(string: filePath) else {
            print("Invalid file URL: \(filePath)")
            return nil
        }
        return loadData(from: fileURL)
    }
    
    // 尝试从Documents目录加载
    if let documentsData = loadDataFromDocuments(filePath: filePath) {
        return documentsData
    }
    
    // 如果Documents目录没有，尝试从tmp目录加载
    if let tmpData = loadDataFromTemporary(filePath: filePath) {
        return tmpData
    }
    
    print("File not found in Documents or Temporary directory: \(filePath)")
    return nil
}

private func loadData(from url: URL) -> Data? {
    do {
        let data = try Data(contentsOf: url)
        return data
    } catch {
        print("文件加载失败 \(url): \(error.localizedDescription)")
        return nil
    }
}

private func loadDataFromDocuments(filePath: String) -> Data? {
    guard let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
        return nil
    }
    
    let fileURL = documentsDirectory.appendingPathComponent(filePath)
    
    // 检查文件是否存在
    guard FileManager.default.fileExists(atPath: fileURL.path) else {
        return nil
    }
    
    return loadData(from: fileURL)
}

private func loadDataFromTemporary(filePath: String) -> Data? {
    let tmpDirectory = FileManager.default.temporaryDirectory
    let fileURL = tmpDirectory.appendingPathComponent(filePath)
    
    // 检查文件是否存在
    guard FileManager.default.fileExists(atPath: fileURL.path) else {
        return nil
    }
    
    return loadData(from: fileURL)
}




func isFileSizeAcceptable(fileData: Data, maxSize: Int = 20 * 1024 * 1024) -> Bool {
    return fileData.count <= maxSize
}

func getMimeType(for fileExtension: String) -> String {
    let mimeTypes: [String: String] = [
        // 图片格式
        "jpg": "image/jpeg", "jpeg": "image/jpeg", "png": "image/png", "gif": "image/gif",
        "bmp": "image/bmp", "webp": "image/webp", "tiff": "image/tiff", "tif": "image/tiff",
        "heic": "image/heic", "heif": "image/heif",
        
        // 文档格式
        "pdf": "application/pdf", "txt": "text/plain", "rtf": "application/rtf",
        "md": "text/markdown", "html": "text/html", "htm": "text/html",
        
        // Microsoft Office
        "doc": "application/msword", "docx": "application/vnd.openxmlformats-officedocument.wordprocessingml.document",
        "xls": "application/vnd.ms-excel", "xlsx": "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet",
        "ppt": "application/vnd.ms-powerpoint", "pptx": "application/vnd.openxmlformats-officedocument.presentationml.presentation",
        
        // Apple iWork
        "pages": "application/vnd.apple.pages", "key": "application/vnd.apple.keynote",
        "keynote": "application/vnd.apple.keynote", "numbers": "application/vnd.apple.numbers",
        
        // 其他办公文档
        "odt": "application/vnd.oasis.opendocument.text", "ods": "application/vnd.oasis.opendocument.spreadsheet",
        "odp": "application/vnd.oasis.opendocument.presentation",
        
        // 压缩文件
        "zip": "application/zip", "rar": "application/x-rar-compressed", "7z": "application/x-7z-compressed",
        "tar": "application/x-tar", "gz": "application/gzip",
        
        // 音频视频
        "mp3": "audio/mpeg", "wav": "audio/wav", "mp4": "video/mp4", "mov": "video/quicktime",
        "avi": "video/x-msvideo"
    ]
    
    return mimeTypes[fileExtension.lowercased()] ?? "application/octet-stream"
}

func formatFileSize(_ size: Int) -> String {
    let formatter = ByteCountFormatter()
    formatter.allowedUnits = [.useBytes, .useKB, .useMB, .useGB]
    formatter.countStyle = .file
    return formatter.string(fromByteCount: Int64(size))
}




//MARK: - 增加文件消息的处理
func createFileMessage(conversation: Conversation) -> ChatQuery.ChatCompletionMessageParam {
    return .init(role: .user,
                 content:
                 [.init(chatCompletionContentPartTextParam: .init(text: conversation.content))] +
                     conversation.imagePaths.map { path in
                         .init(chatCompletionContentPartImageParam:
                             .init(imageUrl:
                                 .init(
                                     url: "data:image/jpeg;base64," + loadImageData(from: path)!.base64EncodedString(),
                                     detail: .auto
                                 )
                             )
                         )
                     })!
}



extension ConversationData {
    func sync(with conversation: Conversation) {
        id = conversation.id
        date = conversation.date
        role = conversation.role.rawValue
        content = conversation.content
        avatar = conversation.avatar
        reasoning = conversation.reasoning
        expandedReasoning = conversation.expandedReasoning
        like = conversation.like    //为什么就是无法保存
        unlike = conversation.unlike   //为什么无法保存
        audioPath = conversation.audioPath
        pdfPath = conversation.pdfPath
        imagePaths = conversation.imagePaths.joined(separator: "|||")
        toolRawValue = conversation.toolRawValue
        arguments = conversation.arguments
        atModelName = conversation.atModelName
        contentS = conversation.contentS
        codeFileName = conversation.codeFileName
        do {
            try PersistenceController.shared.save()
        } catch {
            print(error.localizedDescription)
        }
    }
}

extension Conversation {
    static func createConversationData(from conversation: Conversation, in viewContext: NSManagedObjectContext) -> ConversationData {
        let data = ConversationData(context: viewContext)
        data.id = conversation.id
        data.date = conversation.date
        data.role = conversation.role.rawValue
        data.content = conversation.content
        data.avatar = conversation.avatar
        data.reasoning = conversation.reasoning
        data.expandedReasoning = conversation.expandedReasoning
        data.like = conversation.like
        data.unlike = conversation.unlike
        data.audioPath = conversation.audioPath
        data.pdfPath = conversation.pdfPath
        data.imagePaths = conversation.imagePaths.joined(separator: "|||")
        data.toolRawValue = conversation.toolRawValue
        data.arguments = conversation.arguments
        data.atModelName = conversation.atModelName
        data.contentS = conversation.contentS
        data.codeFileName = conversation.codeFileName
        return data
    }
}
