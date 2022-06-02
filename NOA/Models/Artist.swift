//
//  Artist.swift
//  NOA
//
//  Created by wi_seong on 2022/06/01.
//

import Foundation

struct Artist: Codable {
    let user_code: Int
    let profile: String
    let nickname: String
    
    enum CodingKeys: String, CodingKey {
        case user_code
        case profile
        case nickname
    }
    
    init(user_code: Int,
         profile: String,
         nickname: String) {
        self.user_code = user_code
        self.profile = profile
        self.nickname = nickname
    }
}

extension Artist {
    static let EMPTY = Artist(user_code: 0, profile: "", nickname: "")
}
