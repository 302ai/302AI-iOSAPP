//
//  View+Picker.swift
//  Chat302AI
//
//  Created by Adswave on 2025/8/7.
//

import SwiftUI



// 扩展 View 添加便捷调用方法（带回调）
extension View {
    
    //联网搜索选择
    func bottomSheetSearchTypePicker(
           isPresented: Binding<Bool>,
           onTypeSelected: ((SearchEngineType) -> Void)? = nil
       ) -> some View {
           self.overlay(
               BottomSheetSearchTypePicker(
                   isPresented: isPresented,
                   onTypeSelected: onTypeSelected
               )
           )
           //.ignoresSafeArea()  //输入框  会被覆盖
       }
      
    
    //主题选择
    func bottomSheetThemePicker(
        isPresented: Binding<Bool>,
        onThemeSelected: ((ThemeMode) -> Void)? = nil
    ) -> some View {
        self.overlay(
            BottomSheetThemePicker(
                isPresented: isPresented,
                onThemeSelected: onThemeSelected
            )
        )
        //.ignoresSafeArea()  //输入框  会被覆盖
    }
    
    //文件选择
    func bottomSheetFilePicker(
            isPresented: Binding<Bool>,
            onTypeSelected: ((FilePickerType) -> Void)? = nil
        ) -> some View {
            self.overlay(
                BottomSheetFilePicker(
                    isPresented: isPresented,
                    onTypeSelected: onTypeSelected
                )
            )
            //.ignoresSafeArea()  //输入框  会被覆盖
        }
    
    
     
    
}



extension View {
    func takeScrollViewSnapshot(
            _ proxy: ScrollViewProxy? = nil,
            model: DialogueViewModel,
            completion: @escaping (Result<UIImage, Error>) -> Void
        ) {
            DispatchQueue.main.async {
                do {
                    let controller = UIHostingController(
                        rootView: self.environmentObject(model)
                    )
                    
                    let view = controller.view!
                    let contentSize = controller.sizeThatFits(in: UIView.layoutFittingExpandedSize)
                    
                    guard contentSize.width > 0 && contentSize.height > 0 else {
                        throw NSError(domain: "SnapshotError", code: 1, userInfo: [NSLocalizedDescriptionKey: "Invalid content size"])
                    }
                    
                    view.bounds = CGRect(origin: .zero, size: contentSize)
                    view.backgroundColor = .clear
                    
                    // 创建临时窗口
                    let tempWindow = UIWindow(frame: CGRect(origin: .zero, size: contentSize))
                    tempWindow.addSubview(view)
                    tempWindow.isHidden = false
                    
                    // 布局视图
                    view.setNeedsLayout()
                    view.layoutIfNeeded()
                    
                    // 等待渲染完成
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                        let renderer = UIGraphicsImageRenderer(size: contentSize)
                        let image = renderer.image { context in
                            view.layer.render(in: context.cgContext)
                        }
                        
                        // 清理
                        view.removeFromSuperview()
                        tempWindow.isHidden = true
                        
                        completion(.success(image))
                    }
                    
                } catch {
                    completion(.failure(error))
                }
            }
        }
}


//extension View {
//    // 生成 ScrollView 的长截图
//    func takeScrollViewSnapshot(_ proxy: ScrollViewProxy? = nil,model:DialogueViewModel) -> UIImage {
//        let controller = UIHostingController(
//            rootView: self.environmentObject(model)
//        )
//        
//        let view = controller.view
//        let contentSize = controller.sizeThatFits(in: UIView.layoutFittingExpandedSize)
//        view?.bounds = CGRect(origin: .zero, size: contentSize)
//        view?.backgroundColor = UIColor.clear
//        
//        let renderer = UIGraphicsImageRenderer(size: contentSize)
//        
//        return renderer.image { _ in
//            view?.drawHierarchy(in: controller.view.bounds, afterScreenUpdates: true)
//        }
//    }
//     
//}




// 分享控制器
struct ActivityViewController: UIViewControllerRepresentable {
    var activityItems: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}
