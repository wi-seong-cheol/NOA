//
//  ChatRoom.swift
//  NOA
//
//  Created by wi_seong on 2022/05/30.
//

import Foundation

protocol ChatRoomType {
    var message: ChatRoomMessage { get }
    var owner: Artist { get }
    var roomId: Int { get }
}

struct ChatRoom: Codable, ChatRoomType {
    let message: ChatRoomMessage
    let owner: Artist
    let roomId: Int
    
    enum CodingKeys: String, CodingKey {
        case message
        case owner
        case roomId = "room_id"
    }
    
    init(message: ChatRoomMessage,
         owner: Artist,
         roomId: Int) {
        self.message = message
        self.owner = owner
        self.roomId = roomId
    }
}

extension ChatRoom {
    static let EMPTY = ChatRoom(message: ChatRoomMessage.EMPTY, owner: Artist.EMPTY, roomId: 0)
}
