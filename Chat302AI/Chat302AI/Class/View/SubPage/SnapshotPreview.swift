//
//  SnapshotPreview.swift
//  Chat302AI
//
//  Created by Adswave on 2025/8/13.
//

import SwiftUI

struct SnapshotPreview: View {
    let image: Image
    @Binding var isPresented: Bool // Binding variable to control visibility

    var body: some View {
        VStack {
            HStack {
                Spacer()
                
                Button(action: {
                    isPresented = false // Dismiss the view
                }) {
                    Image(systemName: "xmark")
                        .foregroundColor(.black)
                        .padding()
                }
            }
            
            Spacer()
            
            //Text("snapshot result:")
            image
                .resizable()
                .scaledToFit()
            
            Spacer()
        }
        .background(Color.init(hex: "#EEEEEE"))
        .ignoresSafeArea()
    }
}
 
