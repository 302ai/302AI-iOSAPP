import SwiftUI



 
struct RechargeCenterView: View {
    @State private var showAmountPicker = false
    @State private var selectedAmount: RechargeMountType = .default
    
    var body: some View {
        VStack(spacing: 20) {
            Button(action: {
                showAmountPicker.toggle()
            }) {
                Text("选择充值金额")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(10)
            }
            
            VStack(spacing: 8) {
                Text("当前选择")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Text(selectedAmount.description)
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                
                Text(selectedAmount.ptcDescription)
                    .font(.body)
                    .foregroundColor(.secondary)
            }
            .padding()
            .background(Color(.secondarySystemBackground))
            .cornerRadius(12)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemGroupedBackground))
        .bottomSheetRechargeMountPicker(
            isPresented: $showAmountPicker,
            selectedAmount: $selectedAmount
        ) { selectedType in
            print("确定了金额选择: \(selectedType.description)")
        }
    }
}

#Preview {
    RechargeCenterView()
}


 




// 充值金额类型枚举
enum RechargeMountType: String, CaseIterable {
    case five = "$5"
    case twenty = "$20"
    case fifty = "$50"
    case oneHundred = "$100"
    case twoHundred = "$200"
    case fiveHundred = "$500"
    //case oneThousand = "$1000"
    
    var amount: Int {
        switch self {
        case .five: return 5
        case .twenty: return 20
        case .fifty: return 50
        case .oneHundred: return 100
        case .twoHundred: return 200
        case .fiveHundred: return 500
        //case .oneThousand: return 1000.0
        }
    }
    
    var description: String {
        switch self {
        case .five: return "$5"
        case .twenty: return "$20"
        case .fifty: return "$50"
        case .oneHundred: return "$100"
        case .twoHundred: return "$200"
        case .fiveHundred: return "$500"
        //case .oneThousand: return "$1000"
        }
    }
    
    var ptcDescription: String {
        switch self {
        case .five: return "5 PTC"
        case .twenty: return "20 PTC"
        case .fifty: return "50 PTC"
        case .oneHundred: return "100 PTC"
        case .twoHundred: return "200 PTC"
        case .fiveHundred: return "500 PTC"
        //case .oneThousand: return "1000 PTC"
        }
    }
    
    // 判断是否需要显示赠送10%的文字
    var shouldShowBonus: Bool {
        switch self {
        case .twoHundred, .fiveHundred :
            return true
        default:
            return false
        }
    }
    
    // 默认类型
    static var `default`: RechargeMountType {
        return .twenty
    }
    
    // 从字符串初始化
    init?(rawValue: String) {
        switch rawValue {
        case "$5": self = .five
        case "$20": self = .twenty
        case "$50": self = .fifty
        case "$100": self = .oneHundred
        case "$200": self = .twoHundred
        case "$500": self = .fiveHundred
        //case "$1000": self = .oneThousand
        default: return nil
        }
    }
}

struct RechargeMountTypePicker: View {
    @Binding var isPresented: Bool
    @State private var tempSelectedAmount: RechargeMountType
    @Binding var selectedAmount: RechargeMountType
    var onAmountSelected: ((RechargeMountType) -> Void)?
    
    
    @State var showRechargeAgreement = false
    
    
    init(isPresented: Binding<Bool>, selectedAmount: Binding<RechargeMountType>, onAmountSelected: ((RechargeMountType) -> Void)? = nil) {
        self._isPresented = isPresented
        self._selectedAmount = selectedAmount
        self._tempSelectedAmount = State(initialValue: selectedAmount.wrappedValue)
        self.onAmountSelected = onAmountSelected
    }
    
    // 修改为3列的网格布局
    private let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]
    
    var body: some View {
        ZStack(alignment: .bottom) {
            // 半透明背景
            if isPresented {
                Color.black.opacity(0.4)
                    .edgesIgnoringSafeArea(.all)
                    .onTapGesture {
                        withAnimation {
                            isPresented = false
                        }
                    }
                    .transition(.opacity)
            }
            
            // Action Sheet 内容
            if isPresented {
                VStack(alignment: .leading, spacing: 0) {
                    
                    // 标题栏 - 修改为居中
                    HStack {
                        Button(action: {
                            withAnimation {
                                isPresented = false
                            }
                        }) {
                            Image(systemName: "chevron.backward")
                                .foregroundColor(.secondary)
                                .frame(width: 44, height: 44)
                        }
                        
                        Spacer()
                        
                        Text("充值中心".localized())
                            .font(.headline)
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding(.trailing, 44)
                        
                        Spacer()
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 16)
                    
                    Divider()
                    
                    // 网格布局
                    LazyVGrid(columns: columns, spacing: 16) {
                        ForEach(RechargeMountType.allCases, id: \.self) { amountType in
                            AmountCard(
                                amountType: amountType,
                                isSelected: tempSelectedAmount == amountType
                            )
                            .onTapGesture {
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                    tempSelectedAmount = amountType
                                }
                            }
                        }
                    }
                    .padding(20)
                    
                    Divider()
                    
                    HStack{
                        Spacer()
                            .frame(width: 5)
                        Text("充值说明:".localized())
                            .font(.caption)
                            .foregroundColor(.gray)
                            .padding(5)
                    }
                    
                    Text("PTC为302.AI向您提供的用于在302.AI上进行相关消费的代币，1PTC=1美金，约为7人民币。您可以依照购买规则，先购买PTC，然后使用\"PTC\"购买302.AI的产品或服务。PTC一旦购买成功，不接受任何形式的退款。".localized())
                        .font(.caption)
                        .foregroundColor(.gray)
                        .padding(.horizontal,10)
                        
                    Spacer()
                        .frame(height: 50)
                    
                    
                    // 确定按钮
                    Button(action: {
                        withAnimation {
                            selectedAmount = tempSelectedAmount
                            
                            isPresented = false
                            onAmountSelected?(tempSelectedAmount)
                        }
                    }) {
                        Text("确定".localized())
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(Color(.black))
                            .cornerRadius(12)
                    }
                    .padding(20)
                    //.disabled(tempSelectedAmount == selectedAmount)
                    
                    VStack{
                    HStack {
                        Text("支付即代表阅读并同意".localized())
                            .font(.caption)
                            .foregroundColor(.gray)
                        
                        Button(action: {
                            // 显示用户协议
                            
                            showRechargeAgreement = true
                            
                            
                        }) {
                            Text("《用户充值协议》".localized())
                                .font(.caption)
                                .foregroundColor(.blue)
                        }
                    }
                    .padding(.bottom, 16)
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
                    
                    
                }
                .background(Color(.systemBackground))
                .cornerRadius(20)
                .padding(.horizontal, 16)
                .padding(.bottom, 20)
                .shadow(color: .black.opacity(0.1), radius: 20, x: 0, y: -5)
                .transition(.move(edge: .bottom).combined(with: .opacity))
                .zIndex(1)
            }
        }
        .animation(.easeInOut(duration: 0.3), value: isPresented)
        
        
        .sheet(isPresented: $showRechargeAgreement) { 
            
                
                    
            if LanguageManager.shared.currentLanguage == "en" {
                LocalWebView(htmlFileName: "充值协议(en)")
            }
            else if LanguageManager.shared.currentLanguage == "ja" {
                LocalWebView(htmlFileName: "充值协议（jp）")
            }else{
                LocalWebView(htmlFileName: "充值协议(zh)")
            }
        }
        
    }
}

// 金额卡片组件 - 调整高度以适应3列布局
struct AmountCard: View {
    let amountType: RechargeMountType
    let isSelected: Bool
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            VStack(spacing: 8) {
                // 顶部图片
                if amountType == .fifty {
                    ZStack{
                        Image("热卖")
                            .resizable()
                            .scaledToFit()
                            .frame(height: 20)
                        Text("热卖".localized())
                            .font(.system(size: 14))
                            .foregroundStyle(.white)
                    }
                } else if amountType == .twoHundred {
                    ZStack{
                        Image("特别推荐")
                            .resizable()
                            .scaledToFill()
                            .frame(width: 80,height: 20)
                        Text("特别推荐".localized())
                            .font(.system(size: 13))
                            .lineLimit(1)
                            .minimumScaleFactor(0.5)
                            .fixedSize()
                            .frame(width: 80)
                            .foregroundStyle(.white)
                    }
                }
                
                Spacer()
                
                Text(amountType.ptcDescription)
                    .font(.title2)
                    .fontWeight(.bold)
                    .allowsTightening(true) // 允许调整字符间距
                    .minimumScaleFactor(0.92)
                    .offset(y:-5)
                    .lineLimit(1)
                    .foregroundColor(isSelected ? .purple : .primary)
                
                // 赠送10%的文字（仅对特定金额显示）
                if amountType.shouldShowBonus {
                    Text("赠送10%".localized())
                        .font(.system(size: 10))
                        .fontWeight(.semibold)
                        .foregroundColor(.purple)
                        .padding(.horizontal, 6)
                        .offset(y: -2)
                        .cornerRadius(4)
                }
                
                // 美元金额文本（对所有金额都显示）
                Text(amountType.description)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .offset(y:-5)
                
                // 为没有赠送文字的金额添加额外间距以保持统一高度
                if !amountType.shouldShowBonus {
                    Spacer()
                        .frame(height: 8)
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 100)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(isSelected ? Color.purple.opacity(0.15) : Color(.secondarySystemBackground))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(isSelected ? Color.purple : Color.gray.opacity(0.3), lineWidth: isSelected ? 1 : 1)
            )
            
            // 添加选中时的checkmark图标
            if isSelected {
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Image("选中金额")
                            .resizable()
                            .scaledToFit()
                            .offset(x: -1, y: -1)
                            .frame(width: 20, height: 20)
                    }
                }
            }
        }
        .scaleEffect(isSelected ? 1.05 : 1.0)
        .shadow(color: isSelected ? Color.purple.opacity(0.3) : Color.clear, radius: 8, x: 0, y: 2)
    }
}

// 扩展 View 以添加便捷方法
extension View {
    func bottomSheetRechargeMountPicker(
        isPresented: Binding<Bool>,
        selectedAmount: Binding<RechargeMountType>,
        onAmountSelected: ((RechargeMountType) -> Void)? = nil
    ) -> some View {
        self.overlay(
            RechargeMountTypePicker(
                isPresented: isPresented,
                selectedAmount: selectedAmount,
                onAmountSelected: onAmountSelected
            )
        )
    }
}

