//
//  TermsView.swift
//  Chat302AI
//
//  Created by Adswave on 2025/8/28.
//

import SwiftUI

struct TermsView: View {
    
    var url = "https://302.ai/legal/terms/"
    @Environment(\.presentationMode) var presentationMode
    
    
    var body: some View {
        EnhancedWebView(urlString: url)
            .navigationTitle("隐私政策".localized())
            .navigationBarTitleDisplayMode(.inline)
        
            .listStyle(.insetGrouped)
            .background(NavigationGestureRestorer()) //返回手势
    
    
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

#Preview {
    TermsView()
}
