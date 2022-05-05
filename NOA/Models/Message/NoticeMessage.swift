//
//  NoticeMessage.swift
//  NOA
//
//  Created by wi_seong on 2022/05/05.
//

import Foundation

protocol NoticeMessageType {
    var message: String { get }
}

struct NoticeMessage: Codable, NoticeMessageType {
    let message: String
    
    enum CodingKeys: String, CodingKey {
        case message
    }

    init(message: String) {
        self.message = message
    }
}
