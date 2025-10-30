//
//  AIModel.swift
//  GPTalks
//
//  Created by Adswave on 2025/3/25.
//

import Foundation
 

//struct AI302Model: Hashable, Codable,Identifiable {
//    
//    var id: String
//    var is_moderated: Bool
//    var is_featured : Bool
//    
//    init(id: String, is_moderated: Bool = true, is_featured: Bool = false) {
//        self.id = id
//        self.is_moderated = is_moderated
//        self.is_featured = is_featured
//    }
//    
//    // 自定义解码逻辑：如果 JSON 无 `is_moderated`，则使用默认值 `true`
//        init(from decoder: Decoder) throws {
//            let container = try decoder.container(keyedBy: CodingKeys.self)
//            id = try container.decode(String.self, forKey: .id)
//            is_moderated = try container.decodeIfPresent(Bool.self, forKey: .is_moderated) ?? true
//            is_featured = try container.decodeIfPresent(Bool.self, forKey: .is_featured) ?? false
//        }
//        
//        enum CodingKeys: String, CodingKey {
//            case id, is_moderated, is_featured
//        }
//      
//}
