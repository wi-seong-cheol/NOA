//
//  Chat.swift
//  NOA
//
//  Created by wi_seong on 2022/04/25.
//

import Foundation

protocol ChatType {
}

struct Chat: Codable, ChatType {
    let message: String
    
    enum CodingKeys: String, CodingKey {
        case message
        // 중첩된 JSON Object에 접근하기 위한 키
    }
    
    init(message: String) {
        self.message = message
    }
    
//    init(from decoder: Decoder) throws {
//    }
//    
//    func encode(to encoder: Encoder) throws {
//        // encode code
//    }
}

extension Chat {
    static let EMPTY = Chat(message: "")
}
//extension Chat: Equatable {
//    static func == (lhs: Chat, rhs: Chat) -> Bool {
//        return
//    }
//}
