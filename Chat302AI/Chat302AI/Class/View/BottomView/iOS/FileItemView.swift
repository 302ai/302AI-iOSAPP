//
//  FileItemView.swift
//  Chat302AI
//
//  Created by Adswave on 2025/8/8.
//

import SwiftUI


enum FileFormat: String {
    case ppt
    case word
    case excel
    case pdf
    case keynote
    case pages
    case numbers
    case text
    case image
    case video
    case audio
    case archive
    case code
    case html
    case csv
    case json
    case xml
    case markdown
    case epub
    case unknown
    
    var displayName: String {
        switch self {
        case .ppt: return "PowerPoint"
        case .word: return "Word"
        case .excel: return "Excel"
        case .pdf: return "PDF"
        case .keynote: return "Keynote"
        case .pages: return "Pages"
        case .numbers: return "Numbers"
        case .text: return "Text"
        case .image: return "Image"
        case .video: return "Video"
        case .audio: return "Audio"
        case .archive: return "Archive"
        case .code: return "Code"
        case .html: return "HTML"
        case .csv: return "CSV"
        case .json: return "JSON"
        case .xml: return "XML"
        case .markdown: return "Markdown"
        case .epub: return "ePub"
        case .unknown: return "Unknown"
        }
    }
    
    var iconName: String {
        switch self {
        case .ppt: return "doc.richtext"
        case .word: return "doc.text"
        case .excel: return "tablecells"
        case .pdf: return "doc.plaintext"
        case .keynote: return "k.square"
        case .pages: return "doc.append"
        case .numbers: return "number.square"
        case .text: return "text.alignleft"
        case .image: return "photo"
        case .video: return "film"
        case .audio: return "waveform"
        case .archive: return "archivebox"
        case .code: return "chevron.left.forwardslash.chevron.right"
        case .html: return "network"
        case .csv: return "tablecells"
        case .json: return "curlybraces"
        case .xml: return "chevron.left.forwardslash.chevron.right"
        case .markdown: return "m.square"
        case .epub: return "book"
        case .unknown: return "questionmark.folder"
        }
    }
}

struct FileFormatHelper {
    static func getFileFormat(from fileName: String) -> FileFormat {
        let lowercasedFileName = fileName.lowercased()
        
        if lowercasedFileName.hasSuffix(".ppt") || lowercasedFileName.hasSuffix(".pptx") {
            return .ppt
        } else if lowercasedFileName.hasSuffix(".doc") || lowercasedFileName.hasSuffix(".docx") {
            return .word
        } else if lowercasedFileName.hasSuffix(".xls") || lowercasedFileName.hasSuffix(".xlsx") || lowercasedFileName.hasSuffix(".csv") {
            return .excel
        } else if lowercasedFileName.hasSuffix(".pdf") {
            return .pdf
        } else if lowercasedFileName.hasSuffix(".key") {
            return .keynote
        } else if lowercasedFileName.hasSuffix(".pages") {
            return .pages
        } else if lowercasedFileName.hasSuffix(".numbers") {
            return .numbers
        } else if lowercasedFileName.hasSuffix(".txt") || lowercasedFileName.hasSuffix(".rtf") {
            return .text
        } else if lowercasedFileName.hasSuffix(".jpg") || lowercasedFileName.hasSuffix(".jpeg") || lowercasedFileName.hasSuffix(".png") || lowercasedFileName.hasSuffix(".gif") || lowercasedFileName.hasSuffix(".heic") || lowercasedFileName.hasSuffix(".webp") {
            return .image
        } else if lowercasedFileName.hasSuffix(".mp4") || lowercasedFileName.hasSuffix(".mov") || lowercasedFileName.hasSuffix(".avi") || lowercasedFileName.hasSuffix(".mkv") {
            return .video
        } else if lowercasedFileName.hasSuffix(".mp3") || lowercasedFileName.hasSuffix(".wav") || lowercasedFileName.hasSuffix(".aac") {
            return .audio
        } else if lowercasedFileName.hasSuffix(".zip") || lowercasedFileName.hasSuffix(".rar") || lowercasedFileName.hasSuffix(".7z") || lowercasedFileName.hasSuffix(".tar") || lowercasedFileName.hasSuffix(".gz") {
            return .archive
        } else if lowercasedFileName.hasSuffix(".swift") || lowercasedFileName.hasSuffix(".java") || lowercasedFileName.hasSuffix(".c") || lowercasedFileName.hasSuffix(".cpp") || lowercasedFileName.hasSuffix(".h") || lowercasedFileName.hasSuffix(".py") {
            return .code
        } else if lowercasedFileName.hasSuffix(".html") || lowercasedFileName.hasSuffix(".htm") {
            return .html
        } else if lowercasedFileName.hasSuffix(".json") {
            return .json
        } else if lowercasedFileName.hasSuffix(".xml") {
            return .xml
        } else if lowercasedFileName.hasSuffix(".md") || lowercasedFileName.hasSuffix(".markdown") {
            return .markdown
        } else if lowercasedFileName.hasSuffix(".epub") {
            return .epub
        } else {
            return .unknown
        }
    }
}

// SwiftUI 使用示例
struct FileItemView: View {
    
    
    let fileName: String
    let onDelete: () -> Void
    
    
    var fileFormat: FileFormat {
        FileFormatHelper.getFileFormat(from: fileName)
    }
    
    //名称缩略
    func abbreviationFileName(fileName: String, prefixLength: Int = 4, suffixLength: Int = 4) -> String {
        // 提取文件名部分(用于显示)（去掉路径和扩展名）
        let fileURL = URL(fileURLWithPath: fileName)
        var name = fileURL.deletingPathExtension().lastPathComponent
        let `extension` = fileURL.pathExtension
        
        // 如果文件名本身就很短，直接返回
        if name.count <= prefixLength + suffixLength {
            return "\(name).\(`extension`)"
        }
        
        // 截取前缀和后缀
        let prefix = String(name.prefix(prefixLength))
        let suffix = String(name.suffix(suffixLength))
        
        // 组合成缩写形式
        return "\(prefix)...\(suffix).\(`extension`)"
    }
    
    var body: some View {
        HStack {
            Image(systemName: fileFormat.iconName)
                .foregroundColor(.blue)
                .font(.title2)
            
            VStack(alignment: .leading) {
                Text(abbreviationFileName(fileName: fileName))
                    .font(.headline)
                Text(fileFormat.displayName)
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            
            // 删除按钮
            Button(action: onDelete) {
                Image(systemName: "xmark.circle.fill")
                    .foregroundColor(.gray)
            }
            
        }
        .padding(10)
        .background(Color(.systemBackground))
        .cornerRadius(8)
        .padding(.horizontal)
    }
}
