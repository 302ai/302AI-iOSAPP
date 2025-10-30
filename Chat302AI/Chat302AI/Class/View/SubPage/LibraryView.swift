//
//  LibraryView.swift
//  Chat302AI
//
//  Created by Adswave on 2025/8/11.
//

import SwiftUI
import Toasts
import Photos


struct LibraryView: View {
    
    
    @Environment(\.presentationMode) var presentationMode
    @Environment(DialogueViewModel.self) private var viewModel
    @State private var showingAllImages = false
        
    var body: some View {
        AllImagesView(dialogueSessions: viewModel.currentDialogues)
            .background(NavigationGestureRestorer()) //返回手势
            .navigationTitle("资源库")
            .navigationBarTitleDisplayMode(.inline)
        
            .onReceive(NotificationCenter.default.publisher(for: .goImageLocation)) { _ in
                presentationMode.wrappedValue.dismiss()
            }
        
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
            .navigationBarBackButtonHidden(true)
        
    }
         
    
}
             


// SwiftUI视图示例
struct DialogueSessionView: View {
    @State var dialogueSession: DialogueSession
    
    var body: some View {
        NavigationView {
            List {
                ForEach(dialogueSession.conversationsGroupedByDate(), id: \.title) { section in
                    Section(header: Text(section.title)
                        .font(.headline)
                        .foregroundColor(.primary)
                        .padding(.vertical, 8)) {
                            
                            ForEach(section.conversations) { conversation in
                                ConversationRow(conversation: conversation)
                            }
                        }
                }
            }
            .navigationTitle(dialogueSession.title)
            .listStyle(GroupedListStyle())
        }
    }
}

struct ConversationRow: View {
    let conversation: Conversation
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // 显示时间
            Text(conversation.date, style: .time)
                .font(.caption)
                .foregroundColor(.secondary)
            
            // 显示图片（如果有）
            if !conversation.imagePaths.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        ForEach(conversation.imagePaths, id: \.self) { imagePath in
                            AsyncImage(url: URL(string: imagePath)) { image in
                                image
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 60, height: 60)
                                    .clipShape(RoundedRectangle(cornerRadius: 8))
                            } placeholder: {
                                Rectangle()
                                    .fill(Color.gray.opacity(0.3))
                                    .frame(width: 60, height: 60)
                                    .clipShape(RoundedRectangle(cornerRadius: 8))
                            }
                        }
                    }
                }
            }
        }
        .padding(.vertical, 8)
    }
}

 
struct ImageInfo: Identifiable, Hashable {
    let id = UUID()
    let imagePath: String
    let date: Date
    let sessionId: UUID
    let conversationId: UUID
    let sessionTitle: String
    let conversationDate: Date
    
    // 计算分类标题
    var categoryTitle: String {
        if date.isToday() {
            return "今天".localized()
        } else if date.isYesterday() {
            return "昨天".localized()
        } else if date.isWithinLast7Days() {
            return "最近7天".localized()
        } else {
            return "更早".localized()
        }
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: ImageInfo, rhs: ImageInfo) -> Bool {
        lhs.id == rhs.id
    }
}
 

// 扩展DialogueSession类，添加查找所有图片的方法
extension DialogueSession {
    // 查找所有图片的方法
    func findAllImages() -> [ImageInfo] {
        var images: [ImageInfo] = []
        
        for conversation in conversations {
            for imagePath in conversation.imagePaths {
                if isImageFile(imagePath) {
                    let imageInfo = ImageInfo(
                        imagePath: imagePath,
                        date: conversation.date,
                        sessionId: self.id, // 确保使用会话的ID
                        conversationId: conversation.id,
                        sessionTitle: self.title,
                        conversationDate: conversation.date
                    )
                    images.append(imageInfo)
                    print("找到图片: \(imagePath), 会话ID: \(self.id)")
                }
            }
        }
        
        return images.sorted { $0.date > $1.date }
    }
    
    // 图片文件检查方法
    func isImageFile(_ path: String) -> Bool {
        let imageExtensions = ["jpg", "jpeg", "png", "gif", "bmp", "tiff", "webp"]
        let fileExtension = (path as NSString).pathExtension.lowercased()
        return imageExtensions.contains(fileExtension)
    }
}

// 扩展数组，用于在所有DialogueSession中查找图片并按分类分组
extension Array where Element == DialogueSession {
    func findAllImagesGroupedByCategory() -> [(title: String, images: [ImageInfo])] {
        var allImages: [ImageInfo] = []
        
        for session in self {
            let sessionImages = session.findAllImages()
            allImages.append(contentsOf: sessionImages)
        }
        
        // 按分类分组
        var grouped: [String: [ImageInfo]] = [:]
        
        for image in allImages {
            let category = image.categoryTitle
            if grouped[category] == nil {
                grouped[category] = []
            }
            grouped[category]?.append(image)
        }
        
        // 按分类顺序排序
        let categoryOrder = ["今天".localized(), "昨天".localized(), "最近7天".localized(), "更早".localized()]
        return categoryOrder.compactMap { category in
            guard let images = grouped[category], !images.isEmpty else { return nil }
            return (title: category, images: images)
        }
    }
}

// 所有图片视图 - 按分类显示
struct AllImagesView: View {
    let dialogueSessions: [DialogueSession]
    @State private var groupedImages: [(title: String, images: [ImageInfo])] = []
    
    // 计算网格布局 - 每行5张图片
    private var gridLayout: [GridItem] {
        let spacing: CGFloat = 4
        let itemCount = 5
        let availableWidth = UIScreen.main.bounds.width - (spacing * CGFloat(itemCount - 1)) - 32
        let itemSize = availableWidth / CGFloat(itemCount)
        
        return Array(repeating: GridItem(.fixed(itemSize), spacing: spacing), count: itemCount)
    }
    
    var body: some View {
        NavigationView {
            // 使用 ZStack 作为根容器
            ZStack {
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 16) {
                        if !groupedImages.isEmpty {
                            ForEach(groupedImages, id: \.title) { category in
                                Section {
                                    LazyVGrid(columns: gridLayout, spacing: 8) {
                                        ForEach(category.images) { imageInfo in
                                            ImageGridItemView(imageInfo: imageInfo)
                                        }
                                    }
                                    .padding(.horizontal)
                                } header: {
                                    categoryHeader(title: category.title, count: category.images.count)
                                        .padding(.bottom, 4)
                                }
                            }
                        }
                    }
                    .padding(.vertical, 16)
                }
                
                // 空状态视图居中显示
                if groupedImages.isEmpty {
                    emptyStateView
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(Color(.systemBackground)) // 可选：添加背景色
                }
            }
            .onAppear {
                groupedImages = dialogueSessions.findAllImagesGroupedByCategory()
            }
        }
    }
    
    private var emptyStateView: some View {
        VStack {
            Image(systemName: "photo.on.rectangle")
                .font(.system(size: 60))
                .foregroundColor(.gray)
            Text("暂无资源")
                .font(.body)
                .foregroundColor(.gray)
        }
        .frame(height: 300)
    }
    
    private func categoryHeader(title: String, count: Int) -> some View {
        HStack {
            Text(title)
                .font(.headline)
                .foregroundColor(.primary)
            
            Spacer()
            
            Text("\(count)张")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding(.horizontal)
        .padding(.bottom, 8)
    }
}

// 单个图片网格项视图 - 使用ImageView2
struct ImageGridItemView: View {
    let imageInfo: ImageInfo
    @State private var showDetail = false
    @Environment(\.presentToast) var presentToast
    
    
    var body: some View {
        Button(action: { showDetail = true }) {
            ZStack(alignment: .bottomLeading) {
                // 使用你的ImageView2组件
                ImageView2(tapgestureOn:false,imageUrlPath: imageInfo.imagePath, imageSize: 60)
                    .frame(width: 60, height: 63, alignment: .bottom)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .id(imageInfo.imagePath)
                
                // 会话标识
//                Text(imageInfo.sessionTitle.prefix(1))
//                    .font(.system(size: 10, weight: .bold))
//                    .foregroundColor(.white)
//                    .padding(4)
//                    .background(Circle().fill(Color.blue))
//                    .offset(x: 4, y: -4)
            }
            .frame(width: 60, height: 63)
        }
        .buttonStyle(PlainButtonStyle())
        .sheet(isPresented: $showDetail) {
            ImageDetailView(imageInfo: imageInfo)
        }
        .contextMenu {
            
            
            //goImageLocation
            // 分享按钮
            Button(action: { goImageLoc() }) {
                HStack {
                    Image(systemName:"location.magnifyingglass")
                        .resizable()
                        .frame(width: 20, height: 20)
                    Text("定位到聊天位置")
                }
            }
            
            // 复制按钮
            Button(action: { copyImage() }) {
                HStack {
                    Image("复制2")
                        .resizable()
                        .frame(width: 20, height: 20)
                    Text("复制")
                }
            }
            
            // 分享按钮
            Button(action: { shareImage() }) {
                HStack {
                    Image("分享")
                        .resizable()
                        .frame(width: 20, height: 20)
                    Text("分享")
                }
            }
            
            
            // 分享按钮
            Button(action: { saveImage() }) {
                HStack {
                    Image(systemName:"photo.badge.plus")
                        .resizable()
                        .frame(width: 20, height: 20)
                    Text("保存到相册")
                }
            }
            
            
            
            // 档案库按钮
            Button(action: { addToArchive() }) {
                HStack {
                    Image("档案库")
                        .resizable()
                        .frame(width: 20, height: 20)
                    Text("档案库")
                }
            }
            
            // 知识库按钮
            Button(action: { addToKnowledgeBase() }) {
                HStack {
                    Image("知识库")
                        .resizable()
                        .frame(width: 20, height: 20)
                    Text("知识库")
                }
            }
        }
    }
    
    
    //goImageLocation  goImageLoc
    private func goImageLoc() {
        print("定位图片位置: \(imageInfo.imagePath)")
          
        // 发送返回通知
        //NotificationCenter.default.post(name: NSNotification.Name("PopToRoot"), object: nil)
        
        //NotificationCenter.default.post(name: .goImageLocation, object: nil)
        // 发送通知并传递完整的 ImageInfo 对象
        NotificationCenter.default.post(
            name: .goImageLocation,
            object: imageInfo
        )
        
    }
    
    private func copyImage() {
        
        let toast = ToastValue(message: "复制图片")
        presentToast(toast)
        print("复制图片: \(imageInfo.imagePath)")
    }
    
    private func shareImage() {
        let toast = ToastValue(message: "分享图片 开发中")
        presentToast(toast)
        print("分享图片: \(imageInfo.imagePath)")
    }
    
    
    
    private func saveImage() {
        
        print("分享图片: \(imageInfo.imagePath)")
        
        if let saveImg = loadImage(from: imageInfo.imagePath) {
            PHPhotoLibrary.requestAuthorization { status in
                if status == .authorized {
                    PHPhotoLibrary.shared().performChanges({
                        PHAssetChangeRequest.creationRequestForAsset(from: saveImg)
                    }) { success, error in
                        DispatchQueue.main.async {
                            if success {
                                print("保存成功")
                                
                                let toast = ToastValue(message: "保存成功")
                                presentToast(toast)
                                
                            } else if let error = error {
                                print("保存失败: \(error.localizedDescription)")
                            }
                        }
                    }
                } else {
                    print("没有相册访问权限")
                }
            }
        }
        
        
        
        
    }
    
    
    
    private func addToArchive() {
        let toast = ToastValue(message: "档案库 开发中")
        presentToast(toast)
        print("添加到档案库: \(imageInfo.imagePath)")
    }
    
    private func addToKnowledgeBase() {
        let toast = ToastValue(message: "知识库 开发中")
        presentToast(toast)
        print("添加到知识库: \(imageInfo.imagePath)")
    }
}

// 图片详情视图 - 使用你的ImageView2
struct ImageDetailView: View {
    let imageInfo: ImageInfo
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // 使用你的ImageView2显示大图
                ImageView2(imageUrlPath: imageInfo.imagePath, imageSize: 300, showSaveButton: true)
                    .frame(width: 300, height: 300)
                    .cornerRadius(12)
                    .shadow(radius: 5)
                
                // 图片信息
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text("会话:")
                            .fontWeight(.semibold)
                            .foregroundColor(.secondary)
                        Text(imageInfo.sessionTitle)
                            .foregroundColor(.primary)
                        Spacer()
                    }
                    
                    HStack {
                        Text("日期:")
                            .fontWeight(.semibold)
                            .foregroundColor(.secondary)
                        Text(imageInfo.date.formatted(date: .long, time: .shortened))
                            .foregroundColor(.primary)
                        Spacer()
                    }
                    
                    HStack {
                        Text("分类:")
                            .fontWeight(.semibold)
                            .foregroundColor(.secondary)
                        Text(imageInfo.categoryTitle)
                            .foregroundColor(.primary)
                        Spacer()
                    }
                }
                .font(.subheadline)
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(8)
                
                Spacer()
            }
            .padding()
            .navigationTitle("图片详情")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("完成") {
                        dismiss()
                    }
                }
            }
        }
    }
}
 
