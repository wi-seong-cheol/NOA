//
//  OtherMessage.swift
//  NOA
//
//  Created by wi_seong on 2022/05/05.
//

import Foundation

protocol OtherMessageType {
    var id: String { get }
    var nickname: String { get }
    var profile: String { get }
    var message: String { get }
    var timestamp: String { get }
}

struct OtherMessage: Codable, OtherMessageType {
    let id: String
    let nickname: String
    let profile: String
    let message: String
    let timestamp: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case nickname
        case profile
        case message
        case timestamp
    }

    init(id: String,
         nickname: String,
         profile: String,
         message: String,
         timestamp: String) {
        self.id = id
        self.nickname = nickname
        self.profile = profile
        self.message = message
        self.timestamp = timestamp
    }
}

