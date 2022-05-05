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
    var date: String { get }
}

struct OtherMessage: Codable, OtherMessageType {
    let id: String
    let nickname: String
    let profile: String
    let message: String
    let date: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case nickname
        case profile
        case message
        case date
    }

    init(id: String,
         nickname: String,
         profile: String,
         message: String,
         date: String) {
        self.id = id
        self.nickname = nickname
        self.profile = profile
        self.message = message
        self.date = date
    }
}

