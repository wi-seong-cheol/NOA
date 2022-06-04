//
//  MyMessage.swift
//  NOA
//
//  Created by wi_seong on 2022/05/05.
//

import Foundation

protocol MyMessageType {
    var id: String { get }
    var roomId: String { get }
    var to: String { get }
    var from: String { get }
    var message: String { get }
    var timestamp: String { get }
}

struct MyMessage: Codable, MyMessageType {
    let id: String
    let roomId: String
    let to: String
    let from: String
    let message: String
    let timestamp: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case roomId
        case to
        case from
        case message
        case timestamp
    }

    init(id: String,
         roomId: String,
         to: String,
         from: String,
         message: String,
         timestamp: String) {
        self.id = id
        self.roomId = roomId
        self.to = to
        self.from = from
        self.message = message
        self.timestamp = timestamp
    }
}
