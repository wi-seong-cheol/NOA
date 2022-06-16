//
//  ChatRoomMessage.swift
//  NOA
//
//  Created by wi_seong on 2022/06/01.
//

import Foundation

struct ChatRoomMessage: Codable {
    let message: String
    let unreadCount: Int
    let created: String
    
    enum CodingKeys: String, CodingKey {
        case message
        case unreadCount = "unread_message_count"
        case created
    }
    
    init(message: String,
         unreadCount: Int,
         created: String) {
        self.message = message
        self.unreadCount = unreadCount
        self.created = created
    }
}

extension ChatRoomMessage {
    static let EMPTY = ChatRoomMessage(message: "", unreadCount: 0, created: "")
}
