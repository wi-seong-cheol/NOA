//
//  Message.swift
//  NOA
//
//  Created by wi_seong on 2022/05/05.
//

import Foundation
import RxDataSources

enum MessageItem {
    case noticeCell(NoticeMessageType)
    case dateCell(DateMessageType)
    case otherMessageCell(OtherMessageType)
    case myMessageCell(MyMessageType)
}

struct MessageSection {
    var items: [Item]
}

extension MessageSection: SectionModelType {
    typealias Item = MessageItem
    
    init(original: MessageSection, items: [Item] = []) {
        self = original
        self.items = items
    }
}

struct Message: Codable {
    var msg_to: String
    var msg_content: String
    var read_state: Int
    var msg_num: Int
    var room_id: Int
    var msg_from: String
    var created: String
    
    enum CodingKeys: String, CodingKey {
        case msg_to
        case msg_content
        case read_state
        case msg_num
        case room_id
        case msg_from
        case created
    }

    init(msg_to: String,
         msg_content: String,
         read_state: Int,
         msg_num: Int,
         room_id: Int,
         msg_from: String,
         created: String) {
        self.msg_to = msg_to
        self.msg_content = msg_content
        self.read_state = read_state
        self.msg_num = msg_num
        self.room_id = room_id
        self.msg_from = msg_from
        self.created = created
    }
}
