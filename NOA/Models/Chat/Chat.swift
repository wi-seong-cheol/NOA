//
//  Chat.swift
//  NOA
//
//  Created by wi_seong on 2022/04/25.
//

import Foundation

protocol ChatType {
}

protocol ChatRoomType {
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
    
    init(from decoder: Decoder) throws {
    }
    
    func encode(to encoder: Encoder) throws {
        // encode code
    }
}

extension Chat {
    static let EMPTY = Chat(message: "")
}
extension Chat: Equatable {
    static func == (lhs: Chat, rhs: Chat) -> Bool {
        return
    }
}
struct ChatRoom: Codable, ChatRoomType {
    let profile: String
    let user_id: Int
    let user_nickname: String
    let title: String
    var last_message: String
    var unread_message_count: Int
    
    enum CodingKeys: String, CodingKey {
        case profile
        case user_id
        case user_nickname
        case title
        case last_message
        case unread_message_cout
    }
    
    init() {
    }
    
    init(from decoder: Decoder) throws {
    }
    
    func encode(to encoder: Encoder) throws {
    }
}

extension ChatList {
    static let EMPTY = ChatList()
}
