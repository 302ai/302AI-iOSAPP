import SwiftUI
import Toasts



struct FeedbackView: View {
    @Binding var isPresented: Bool
    @State private var selectedOptions: Set<FeedbackOption> = []
    @State private var optionRows: [[FeedbackOption]] = []
    @State private var suggestionText: String = "" // 新增：建议文本
    @Environment(\.presentToast) var presentToast
    let allOptions: [FeedbackOption] = [
        FeedbackOption(title: "内容质量问题".localized()),
        FeedbackOption(title: "逻辑缺陷".localized()),
        FeedbackOption(title: "表达不清".localized()),
        FeedbackOption(title: "答非所问".localized()),
        FeedbackOption(title: "补充其他".localized())
    ]
    
    // 主色调
    let mainColor = Color(hex: "#8E47F1")
    // 渐变背景色
    let gradientStart = Color(hex: "#EEE2FF")
    let gradientEnd = Color(hex: "#FFFFFF")
    
    var body: some View {
        if isPresented {
            ZStack {
                // 全屏半透明黑色背景 - 可点击关闭
                Color.black.opacity(0.6)
                    .edgesIgnoringSafeArea(.all)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        dismissFeedback()
                    }
                
                // 弹框内容
                VStack(spacing: 0) {
                    // 标题栏（包含关闭按钮）
                    HStack {
                        Spacer()
                        
                        Button(action: dismissFeedback) {
                            Image(systemName: "xmark")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(.secondary)
                                .frame(width: 30, height: 30)
                                .background(Color.gray.opacity(0.2))
                                .clipShape(Circle())
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 16)
                    
                    // 标题
                    HStack {
                        Text("帮我们做得更好👍🏼".localized())
                            .font(.title2)
                            .padding(.top, 8)
                            .padding(.leading,12)
                        Spacer()
                    }
                        
                    // 副标题
                    HStack {
                        Text("您的每条反馈都会优化AI，感谢推动进步".localized())
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.top, 8)
                            .padding(.leading, 12)
                        Spacer()
                    }
                    // 选项网格 - 使用固定宽度的按钮
                    VStack(spacing: 6) {
                        ForEach(0..<optionRows.count, id: \.self) { rowIndex in
                            HStack(spacing: 6) {
                                ForEach(optionRows[rowIndex]) { option in
                                    FeedbackOptionCapsule(
                                        option: option,
                                        isSelected: selectedOptions.contains(option),
                                        mainColor: mainColor,
                                        onSelect: { toggleOption(option) }
                                    )
                                    .fixedSize(horizontal: true, vertical: false)
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 10)
                    .padding(.top, 12)
                    
                    // 多行输入框
                    ZStack(alignment: .topLeading) {
                        TextEditor(text: $suggestionText)
                            .frame(height: 100)
                            .padding(12)
                            .background(Color.white)
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                            )
                            .colorScheme(.light)
                        if suggestionText.isEmpty {
                            Text("说说你的建议吧".localized())
                                .foregroundColor(.gray)
                                .padding(.leading, 16)
                                .padding(.top, 20)
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 20)
                    //.backgroundStyle(.white)
                    
                    // 提交按钮
                    Button(action: submitFeedback) {
                        Text("提交反馈".localized())
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(selectedOptions.isEmpty ? Color.gray.opacity(0.3) : mainColor)
                            .cornerRadius(12)
                            .padding(.horizontal, 16)
                            .padding(.top, 20)
                    }
                    .disabled(selectedOptions.isEmpty)
                    
                    Spacer()
                        .frame(height: 20)
                }
                .frame(width: 340)
                .background(
                    // 垂直渐变背景
                    LinearGradient(
                        gradient: Gradient(colors: [gradientStart, gradientEnd]),
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .cornerRadius(15)
                .shadow(radius: 10)
                .transition(.scale.combined(with: .opacity))
                .zIndex(1)
                // 阻止点击弹框内容时触发背景点击
                .onTapGesture {}
            }
            .onAppear {
                // 随机排列选项并分组
                optionRows = arrangeOptionsRandomly()
            }
        }
    }
    
    // 随机排列选项并分组为行
    private func arrangeOptionsRandomly() -> [[FeedbackOption]] {
        var shuffledOptions = allOptions.shuffled()
        var rows: [[FeedbackOption]] = []
        
        // 根据内容长度重新分组，确保每行显示合理
        let maxWidth: CGFloat = 300
        var currentRow: [FeedbackOption] = []
        var currentRowWidth: CGFloat = 0
        
        for option in shuffledOptions {
            // 估算按钮宽度
            let textWidth = CGFloat(option.title.count) * 10 + 40
            let buttonWidth = textWidth + 50
            
            if currentRowWidth + buttonWidth + 8 > maxWidth && !currentRow.isEmpty {
                rows.append(currentRow)
                currentRow = [option]
                currentRowWidth = buttonWidth
            } else {
                currentRow.append(option)
                currentRowWidth += buttonWidth + 8
            }
        }
        
        if !currentRow.isEmpty {
            rows.append(currentRow)
        }
        
        return rows
    }
    
    private func toggleOption(_ option: FeedbackOption) {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
            if selectedOptions.contains(option) {
                selectedOptions.remove(option)
            } else {
                selectedOptions.insert(option)
            }
        }
    }
    
    private func submitFeedback() {
        // 这里处理提交反馈的逻辑
        print("提交的反馈选项: \(selectedOptions.map { $0.title })")
        print("建议内容: \(suggestionText)")
        
        
        let toast = ToastValue(message: "提交成功!".localized())
        presentToast(toast)
        
        dismissFeedback()
    }
    
    private func dismissFeedback() {
        withAnimation(.easeInOut(duration: 0.2)) {
            isPresented = false
        }
    }
}

struct FeedbackOption: Identifiable, Hashable {
    let id = UUID()
    let title: String
    // 移除了icon属性
}

struct FeedbackOptionCapsule: View {
    let option: FeedbackOption
    let isSelected: Bool
    let mainColor: Color
    let onSelect: () -> Void
     
    
    
    var body: some View {
        Button(action: onSelect) {
            Text(option.title)
                .font(.system(size: 16, weight: .medium))
                .fixedSize(horizontal: true, vertical: false)
                .lineLimit(1)
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(isSelected ? mainColor.opacity(0.9) : Color.white.opacity(0.8))
                .foregroundColor(isSelected ? .white : Color.gray )
                .cornerRadius(20)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(isSelected ? mainColor : Color.gray.opacity(0.3), lineWidth: 1)
                )
                .scaleEffect(isSelected ? 1.05 : 1.0)
                .shadow(color: isSelected ? mainColor.opacity(0.3) : Color.clear, radius: 5, x: 0, y: 2)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

 





