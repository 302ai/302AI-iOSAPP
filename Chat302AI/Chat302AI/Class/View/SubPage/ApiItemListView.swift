//
//  ApiListView2.swift
//  GPTalks
//
//  Created by Adswave on 2025/4/10.
//

import SwiftUI
import AlertToast


struct ApiItemListView: View {
    @EnvironmentObject var dataManager: ApiDataManager
    @Environment(\.presentationMode) var presentationMode
    @State var showModelDetail = false
    @State var showCreateNew = false
    @State private var itemToDelete: ApiItem?
    @State private var showDeleteAlert = false
    
    
    @State private var showToast = false
    @State private var hintText = ""
    
    var body: some View {
        VStack {
            List {
                ForEach(dataManager.apiItems) { item in
                    Section(header: sectionHeader(for: item)) {
                        Button(action: {
                            dataManager.selectItem(item)
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                showModelDetail = true
                            }
                        }) {
                            HStack {
                                VStack(alignment: .leading) {
                                    Text(item.name.isEmpty ? "enter you api name" : item.name)
                                        .font(.headline)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .offset(x: 10, y: 0)
                                    Text(item.host.isEmpty ? "enter you api host" : item.host)
                                        .font(.subheadline)
                                        .foregroundColor(.gray)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .offset(x: 10, y: 0)
                                }
                                
                                Spacer()
                                
                                // 添加选中标记
                                if dataManager.selectedItemId == item.id {
                                    
                                    Image(systemName: "checkmark")
                                        .foregroundColor(.blue)
                                        .padding(.trailing,10)
                                }
                            }
                            .contentShape(Rectangle())
                        }
                        .foregroundColor(.primary)
                        .buttonStyle(.plain)
                        .contentShape(Rectangle())
                    }
                    .listRowInsets(EdgeInsets(top: 8, leading: 0, bottom: 8, trailing: 0))
                    .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                        //MARK: 左滑删除按钮
                        
                        if !item.name.contains("302") && !item.name.contains("OpenAI") {
                            Button(role: .destructive) {
                                itemToDelete = item
                                showDeleteAlert = true
                            } label: {
                                Label("删除", systemImage: "trash")
                            }
                        }
                        
                        
                        // 左滑编辑按钮（可选）
                        Button {
                            dataManager.selectItem(item)
                            showModelDetail = true
                        } label: {
                            Label("编辑", systemImage: "pencil")
                        }
                        .tint(.blue)
                    }
                }
            }
            /*
            // 编辑现有项目的导航链接
            NavigationLink(
                destination: ApiItemDetailView(draftItem: dataManager.selectedItem ?? ApiItem(name: "", host: "", apiKey: "", model: AI302Model(id: "", is_moderated: true), apiNote: "")),
                isActive: $showModelDetail,
                label: { EmptyView() }
            )
            .hidden()
            
            // 新增项目的导航链接
            NavigationLink(
                destination: CreateApiItemView(),
                isActive: $showCreateNew,
                label: { EmptyView() }
            )
            .hidden()*/
            
            .sheet(isPresented: $showModelDetail) {
                NavigationView {
                    ApiItemDetailView(
                        draftItem: dataManager.selectedItem ?? ApiItem(
                            name: "",
                            host: "",
                            apiKey: "",
                            model: AI302Model(id: "", is_moderated: true),
                            apiNote: ""
                        )
                    )
                }
            }
            .sheet(isPresented: $showCreateNew) {
                NavigationView {
                    CreateApiItemView()
                }
            }
            
        }
        .listStyle(.insetGrouped)
        .background(NavigationGestureRestorer())
        .navigationBarBackButtonHidden(true)
        .navigationTitle("模型管理")
        .navigationBarTitleDisplayMode(.inline)
        .alert("确认删除", isPresented: $showDeleteAlert) {
            Button("取消", role: .cancel) {}
            Button("删除", role: .destructive) {
                if let item = itemToDelete {
                    
                    if item.name.contains("302") || item.name.contains("OpenAI") {
                        hintText = "无法删除"
                        showToast = true
                    }else{
                        deleteItem(item)
                    }
                    
                    
                }
            }
        } message: {
            if let item = itemToDelete {
                Text("确定要删除「\(item.name)」吗？此操作无法撤销。")
            }
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
            
            // 新增：右侧工具栏按钮
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    showCreateNew = true
                }) {
                    Image(systemName: "plus")
                        .foregroundColor(.blue)
                }
            }
        }
        .onAppear {
            // 确保数据已加载
            dataManager.loadData()
        }
    }
    
    // Section Header 视图
    private func sectionHeader(for item: ApiItem) -> some View {
        HStack {
            Text(item.name.isEmpty ? "your api" : item.name)
                .font(.subheadline)
                .foregroundColor(.secondary)
            Spacer()
        }
        .padding(.vertical, 4)
        .background(Color(.systemGroupedBackground))
    }
    
    // 删除项目
    private func deleteItem(_ item: ApiItem) {
        withAnimation {
            dataManager.deleteItem(item)
        }
    }
}
 
