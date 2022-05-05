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
    var date: String { get }
}

struct MyMessage: Codable, MyMessageType {
    let id: String
    let message: String
    let date: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case message
        case date
    }

    init(id: String,
         message: String,
         date: String) {
        self.id = id
        self.message = message
        self.date = date
    }
}
