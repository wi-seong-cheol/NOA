//
//  MyMessage.swift
//  NOA
//
//  Created by wi_seong on 2022/05/05.
//

import Foundation

protocol MyMessageType {
    var id: String { get }
    var message: String { get }
    var timestamp: String { get }
}

struct MyMessage: Codable, MyMessageType {
    let id: String
    let message: String
    let timestamp: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case message
        case timestamp
    }

    init(id: String,
         message: String,
         timestamp: String) {
        self.id = id
        self.message = message
        self.timestamp = timestamp
    }
}
