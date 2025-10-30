import SwiftUI
import UniformTypeIdentifiers

// 文件类型枚举
enum OfficeFileType {
    case word
    case excel
    case powerpoint
    case pages
    case numbers
    case keynote
    case pdf
    case text
    case custom(extension: String, mimeType: String)
    
    var fileExtension: String {
        switch self {
        case .word: return "docx"
        case .excel: return "xlsx"
        case .powerpoint: return "pptx"
        case .pages: return "pages"
        case .numbers: return "numbers"
        case .keynote: return "keynote"
        case .pdf: return "pdf"
        case .text: return "txt"
        case .custom(let ext, _): return ext
        }
    }
    
    var mimeType: String {
        switch self {
        case .word: return "application/vnd.openxmlformats-officedocument.wordprocessingml.document"
        case .excel: return "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"
        case .powerpoint: return "application/vnd.openxmlformats-officedocument.presentationml.presentation"
        case .pages: return "application/vnd.apple.pages"
        case .numbers: return "application/vnd.apple.numbers"
        case .keynote: return "application/vnd.apple.keynote"
        case .pdf: return "application/pdf"
        case .text: return "text/plain"
        case .custom(_, let mime): return mime
        }
    }
    
    var folderName: String {
        switch self {
        case .word, .excel, .powerpoint: return "OfficeDocuments"
        case .pages, .numbers, .keynote: return "iWorkDocuments"
        case .pdf: return "PDFs"
        case .text: return "TextFiles"
        case .custom: return "CustomFiles"
        }
    }
}

// 主保存函数
func saveOfficeFile(data: Data, fileType: OfficeFileType, fileName: String = Date().nowFileName(), inFolder customFolder: String? = nil) -> String? {
    
    let folderName = customFolder ?? fileType.folderName
    let fullFileName = fileName + "." + fileType.fileExtension
    
    do {
        let directory = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
        let folderURL = directory.appendingPathComponent(folderName, isDirectory: true)
        
        // 创建文件夹（如果不存在）
        if !FileManager.default.fileExists(atPath: folderURL.path) {
            try FileManager.default.createDirectory(at: folderURL, withIntermediateDirectories: true, attributes: nil)
        }
        
        let fileURL = folderURL.appendingPathComponent(fullFileName)
        
        // 保存文件
        try data.write(to: fileURL)
        
        // 返回相对路径
        return folderName + "/" + fullFileName
        
    } catch {
        print("保存文件失败: \(error.localizedDescription)")
        return nil
    }
}

// 便捷的特定文件类型保存方法
func saveWordDocument(data: Data, fileName: String = Date().nowFileName()) -> String? {
    return saveOfficeFile(data: data, fileType: .word, fileName: fileName)
}

func saveExcelDocument(data: Data, fileName: String = Date().nowFileName()) -> String? {
    return saveOfficeFile(data: data, fileType: .excel, fileName: fileName)
}

func savePowerPointDocument(data: Data, fileName: String = Date().nowFileName()) -> String? {
    return saveOfficeFile(data: data, fileType: .powerpoint, fileName: fileName)
}

func savePagesDocument(data: Data, fileName: String = Date().nowFileName()) -> String? {
    return saveOfficeFile(data: data, fileType: .pages, fileName: fileName)
}

func saveNumbersDocument(data: Data, fileName: String = Date().nowFileName()) -> String? {
    return saveOfficeFile(data: data, fileType: .numbers, fileName: fileName)
}

func saveKeynoteDocument(data: Data, fileName: String = Date().nowFileName()) -> String? {
    return saveOfficeFile(data: data, fileType: .keynote, fileName: fileName)
}

func savePDFDocument(data: Data, fileName: String = Date().nowFileName()) -> String? {
    return saveOfficeFile(data: data, fileType: .pdf, fileName: fileName)
}

func saveTextDocument(text: String, fileName: String = Date().nowFileName()) -> String? {
    guard let data = text.data(using: .utf8) else {
        print("文本编码失败")
        return nil
    }
    return saveOfficeFile(data: data, fileType: .text, fileName: fileName)
}

// 从URL保存文件
func saveFileFromURL(_ url: URL, fileName: String = Date().nowFileName(), inFolder folderName: String = "DownloadedFiles") -> String? {
    do {
        let data = try Data(contentsOf: url)
        let originalFileName = fileName //?? url.deletingPathExtension().lastPathComponent
        let fileExtension = url.pathExtension
        
        let fileType: OfficeFileType
        switch fileExtension.lowercased() {
        case "doc", "docx": fileType = .word
        case "xls", "xlsx": fileType = .excel
        case "ppt", "pptx": fileType = .powerpoint
        case "pages": fileType = .pages
        case "numbers": fileType = .numbers
        case "key", "keynote": fileType = .keynote
        case "pdf": fileType = .pdf
        case "txt": fileType = .text
        default: fileType = .custom(extension: fileExtension, mimeType: "application/octet-stream")
        }
        
        return saveOfficeFile(data: data, fileType: fileType, fileName: originalFileName, inFolder: folderName)
        
    } catch {
        print("从URL加载文件失败: \(error.localizedDescription)")
        return nil
    }
}

// 文件操作辅助方法
func getFileURL(from relativePath: String) -> URL? {
    guard let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
        return nil
    }
    return documentsDirectory.appendingPathComponent(relativePath)
}

func deleteFile(at relativePath: String) -> Bool {
    guard let fileURL = getFileURL(from: relativePath) else {
        return false
    }
    
    do {
        try FileManager.default.removeItem(at: fileURL)
        return true
    } catch {
        print("删除文件失败: \(error.localizedDescription)")
        return false
    }
}

func fileExists(at relativePath: String) -> Bool {
    guard let fileURL = getFileURL(from: relativePath) else {
        return false
    }
    return FileManager.default.fileExists(atPath: fileURL.path)
}



struct FileNameHelper {
    // 从URL字符串中提取文件名
    static func getFileName(from urlString: String) -> String? {
        guard let url = URL(string: urlString) else { return nil }
        return url.lastPathComponent.removingPercentEncoding
    }
    
    
    static func getUrlFileName(from url: URL) -> String? {
        //guard let url = URL(string: urlString) else { return nil }
        return url.lastPathComponent.removingPercentEncoding
    }
    
    
    // 从文件路径中提取文件名
    static func getFileName(fromPath path: String) -> String {
        let url = URL(fileURLWithPath: path)
        return url.lastPathComponent.removingPercentEncoding ?? url.lastPathComponent
    }
}


// 扩展方法，提供多种文件名提取方式
extension URL {
    // 方法1：提取并解码文件名（推荐）
    func extractedFileName() -> String {
        return self.lastPathComponent.removingPercentEncoding ?? self.lastPathComponent
    }
    
    // 方法2：安全提取，处理可能为空的情况
    func safeFileName() -> String {
        let fileName = self.lastPathComponent
        if let decoded = fileName.removingPercentEncoding {
            return decoded
        }
        return fileName
    }
    
    // 方法3：提取不带扩展名的文件名
    func fileNameWithoutExtension() -> String {
        let name = self.deletingPathExtension().lastPathComponent
        return name.removingPercentEncoding ?? name
    }
    
    // 方法4：只提取扩展名
    func fileExtension() -> String {
        return self.pathExtension
    }
}




// 使用示例
struct FileSaverExample: View {
    @State private var savedFilePath: String?
    
    var body: some View {
        VStack {
            Button("保存示例Word文档") {
                // 示例：创建一个简单的Word文档内容（实际应用中可能是从网络或其他来源获取）
                let sampleContent = "这是一个示例Word文档内容"
                if let data = sampleContent.data(using: .utf8) {
                    savedFilePath = saveWordDocument(data: data, fileName: "示例文档")
                }
            }
            
            Button("保存示例PDF") {
                // 示例：创建一个简单的PDF内容（实际应用中可能是生成的PDF数据）
                let sampleData = Data() // 这里应该是实际的PDF数据
                savedFilePath = savePDFDocument(data: sampleData)
            }
            
            if let path = savedFilePath {
                Text("文件已保存到: \(path)")
                    .foregroundColor(.green)
                
                Button("打开文件") {
                    if let url = getFileURL(from: path) {
                        // 在iOS中打开文件
                        #if os(iOS)
                        UIApplication.shared.open(url)
                        #elseif os(macOS)
                        NSWorkspace.shared.open(url)
                        #endif
                    }
                }
            }
        }
        .padding()
    }
}
