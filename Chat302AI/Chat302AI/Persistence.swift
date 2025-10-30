//
//  Persistence.swift
//  GPTalks
//
//  Created by LuoHuanyu on 2023/3/22.
//

import CoreData

struct PersistenceController {
    static let shared = PersistenceController()
    
    // 添加静态变量存储当前用户ID
    static var currentUserId: String? {
        get { UserDefaults.standard.string(forKey: "currentUserId") }
        set { UserDefaults.standard.set(newValue, forKey: "currentUserId") }
    }

    let container: NSPersistentCloudKitContainer
    
    init(inMemory: Bool = false) {
        container = NSPersistentCloudKitContainer(name: "Chat302AI")
        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }
        
        container.viewContext.automaticallyMergesChangesFromParent = true
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        
        guard let description = container.persistentStoreDescriptions.first else {
            fatalError("No descriptions found")
        }
        description.setOption(true as NSNumber, forKey: NSPersistentHistoryTrackingKey)
        description.setOption(true as NSNumber, forKey: NSPersistentStoreRemoteChangeNotificationPostOptionKey)
        
        container.loadPersistentStores { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }
    }
    
    // 修改保存方法：自动为新增实体注入userId
    func save() {
        let context = container.viewContext
        if context.hasChanges {
            do {
                // 自动为所有新增的实体设置userId
                if let userId = PersistenceController.currentUserId {
                    for case let entity as NSManagedObject in context.insertedObjects {
                        if entity.entity.attributesByName["userId"] != nil {
                            entity.setValue(userId, forKey: "userId")
                        }
                    }
                }
                
                try context.save()
                print("[CoreData] Save succeed. User: \(PersistenceController.currentUserId ?? "unknown")")
            } catch {
                let nserror = error as NSError
                print("[CoreData] Save error: \(nserror), \(nserror.userInfo)")
            }
        }
    }
}



extension PersistenceController {
    static func login(uid: String) {
        currentUserId = uid
    }
    
    static func logout() {
        currentUserId = nil
    }
    
    static var isLoggedIn: Bool {
        return currentUserId != nil
    }
}
