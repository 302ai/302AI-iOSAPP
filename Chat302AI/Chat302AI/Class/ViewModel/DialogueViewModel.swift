//
//  DialogueStore.swift
//  GPTalks
//
//  Created by Zabir Raihan on 10/12/2023.
//

import CoreData
import SwiftUI

enum ContentState: String, CaseIterable, Identifiable {
    case chats = "Chats"
    case images = "Images"
    
    var id: Self { self }
    
    var image: String {
        switch self {
        case .chats:
            return "tray.2.fill"
        case .images:
            return "photo"
        }
    }
}

@Observable class DialogueViewModel : ObservableObject {
    private let viewContext: NSManagedObjectContext
    
    var allDialogues: [DialogueSession] = []
    
    var isMultiSelectMode = false
    //@Published var selectedDialogues: [DialogueSession] = [] // 用于存储多选的项目
    
    var isExpanded: Bool = false
    
    var selectedState: ContentState = .chats 
    {
        didSet {
            switch selectedState {
            case .chats:
                if selectedDialogues.isEmpty {
                    #if os(macOS)
                    if let first = allDialogues.first {
                        selectedDialogues.insert(first)
                    }
                    #endif
                }
            case .images:
                selectedDialogues = []
            }
        }
    }
    
    var searchText: String = ""
    
    var selectedDialogues: Set<DialogueSession> = []
    var selectedDialogue: DialogueSession?

    func deleteSelectedDialogues() {
        
        var deleteAll = false
        if selectedDialogues.count == allDialogues.count {
            deleteAll = true
        }
        
        for session in selectedDialogues {
            deleteDialogue(session)
        }
        
        if let s = allDialogues.first,!deleteAll {
            self.selectedDialogue = s
        }
        
        selectedDialogues.removeAll()
        
        if deleteAll {
            allDialogues.removeAll()
            addDialogue()
        }
        
    }
    
    func toggleStarredDialogues() {
        for session in selectedDialogues {
            session.isArchive.toggle()
        }
    }
    
    var shouldShowPlaceholder: Bool {
        return (!searchText.isEmpty && currentDialogues.isEmpty) || currentDialogues.isEmpty
    }

    var currentDialogues: [DialogueSession] {
        // 过滤掉 traceless 为 true 的对话 (无痕会话)
        var filteredDialogues = allDialogues.filter { !$0.traceless }
        
//        if filteredDialogues.isEmpty {
//            let session = addNewDialogue()
//            filteredDialogues.append(session)
//        }
        
        
        if !searchText.isEmpty {
            return filterDialogues(matching: searchText, from: filteredDialogues)
        } else {
            return Array(filteredDialogues.prefix(isExpanded ? filteredDialogues.count : 200))
        }
        
//        if !searchText.isEmpty {
//            return filterDialogues(matching: searchText, from: allDialogues)
//        } else {
//            return Array(allDialogues.prefix(isExpanded ? allDialogues.count : 10))
//        }
    }
    
    var placeHolderText: String {
        return allDialogues.isEmpty ? "Start a new chat" : "No Search Results"
    }
    
    init(context: NSManagedObjectContext) {
        viewContext = context
        fetchDialogueData()
    }

    
     
    
    
    
    func fetchDialogueData(firstTime: Bool = true) {
        do {
            var fetchRequest = NSFetchRequest<DialogueData>(entityName: "DialogueData")
            fetchRequest.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
            
            
            // 自动过滤当前用户的数据
            if let userId = PersistenceController.currentUserId {
                fetchRequest.predicate = NSPredicate(format: "userId == %@", userId)
            } else {
                fetchRequest.predicate = NSPredicate(format: "userId == nil") // 或者返回空数组
            }
            
            
            let dialogueData = try PersistenceController.shared.container.viewContext.fetch(fetchRequest)

            allDialogues = dialogueData.compactMap { DialogueSession(rawData: $0) }
            
            if firstTime {
                    #if os(macOS)
                if let first = allDialogues.first {
                    selectedDialogues.insert(first)
                }
                    #endif
                }
            
        } catch {
            print("DEBUG: Some error occured while fetching")
        }
    }
    
    func filterDialogues(matching searchText: String, from dialogues: [DialogueSession]) -> [DialogueSession] {
        dialogues.filter { dialogue in
            let isContentMatch = dialogue.conversations.contains { conversation in
                conversation.content.localizedCaseInsensitiveContains(searchText)
            }
            let isTitleMatch = dialogue.title.localizedCaseInsensitiveContains(searchText)
            return isContentMatch || isTitleMatch
        }
    }


    func moveUpChat(session: DialogueSession) {
        session.date = Date()
        session.save()
        
        if session.id == allDialogues.first?.id {
            return
        }
        
        let index = allDialogues.firstIndex { $0.id == session.id }
        if let index = index {
            withAnimation {
                allDialogues.remove(at: index)
                allDialogues.insert(session, at: 0)
            }
        }
    }
    
    func toggleImageAndChat() {
        if selectedState == .images {
            selectedState = .chats
        } else {
            selectedState = .images
        }
    }

    func addDialogue(conversations: [Conversation] = [],title:String="新的聊天".localized(),model_topic:String="",promptModel:String="") {
//        if let first = allDialogues.first {
//            if first.conversations.count == 0 {
//                selectedDialogues = [first]
//                return
//            }
//        }
        
        if selectedState != .chats {
            selectedState = .chats
        }

        let newItem = DialogueData(context: viewContext)
        newItem.id = UUID()
        newItem.date = Date()
        newItem.title = title

        if !conversations.isEmpty {
            let conversationsSet = NSSet(array: conversations.map { conversation in
                Conversation.createConversationData(from: conversation, in: viewContext)
            })
            newItem.conversations = conversationsSet
        }

        
        if AppConfiguration.shared.isCustomPromptOn && !AppConfiguration.shared.customPromptContent.isEmpty && model_topic.isEmpty && promptModel.isEmpty {
            let conversation = Conversation(role: .assistant, content: AppConfiguration.shared.customPromptContent,arguments:"预设提示词", atModelName: "", contentS: "")
            newItem.conversations = NSSet(array: [Conversation.createConversationData(from: conversation, in: viewContext)])
        }
        
        
        do {
            
            if !promptModel.isEmpty {
                //提示词  promptModel
                newItem.configuration = try JSONEncoder().encode(DialogueSession.Configuration(promptModel: promptModel))
            }else if !model_topic.isEmpty{
                //应用商店  model_topic
                newItem.configuration = try JSONEncoder().encode(DialogueSession.Configuration(model_topic: model_topic))
            }else{
                newItem.configuration = try JSONEncoder().encode(DialogueSession.Configuration())
            }
            
        } catch {
            print(error.localizedDescription)
        }

        save()

        if let session = DialogueSession(rawData: newItem) {
            withAnimation {
                //是否默认开启无痕会话
                if AppConfiguration.shared.autoTracelessSession {
                    session.traceless = true
                }
                allDialogues.insert(session, at: 0)
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
#if os(macOS)
                self.selectedDialogues = []
                self.selectedDialogues.insert(session)
#else
                self.selectedDialogue = session
#endif
            }
        }
    }
    
    
    
    
    func addNewDialogue(conversations: [Conversation] = [],title:String="新的聊天".localized(),model_topic:String="") -> DialogueSession {
 
        if selectedState != .chats {
            selectedState = .chats
        }

        let newItem = DialogueData(context: viewContext)
        newItem.id = UUID()
        newItem.date = Date()
        newItem.title = title

        if !conversations.isEmpty {
            let conversationsSet = NSSet(array: conversations.map { conversation in
                Conversation.createConversationData(from: conversation, in: viewContext)
            })
            newItem.conversations = conversationsSet
        }

        do {
            newItem.configuration = try JSONEncoder().encode(DialogueSession.Configuration(model_topic: model_topic))
        } catch {
            print(error.localizedDescription)
        }

        save()
         
        

        if let session = DialogueSession(rawData: newItem) {
            withAnimation {
                allDialogues.insert(session, at: 0)
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
#if os(macOS)
                self.selectedDialogues = []
                self.selectedDialogues.insert(session)
#else
                self.selectedDialogue = session
                
#endif
            }
            
            return session
        }
        
        return self.selectedDialogues.first!
    }
    
    
    
    
    func addToDB(dialogue: DialogueSession) {
        if selectedState != .chats {
            selectedState = .chats
        }

        
    }

    func deleteDialogue(_ session: DialogueSession) {
        
        if self.allDialogues.count == 1 {
            return
        }
        
        if session.isArchive {
            //return  //收藏的对话也要能删除
        }
        
        if selectedDialogues.contains(where: { $0.id == session.id }) {
            selectedDialogues.remove(session)
        }

        //withAnimation {
        self.allDialogues.removeAll {
            $0.id == session.id
        }
        //}

        if let item = session.rawData {
            viewContext.delete(item)
        }

        save()
    }

    private func save() {
        do {
            try PersistenceController.shared.save()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
    }
}
