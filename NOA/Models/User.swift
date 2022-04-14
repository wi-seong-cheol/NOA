//
//  User.swift
//  NOA
//
//  Created by wi_seong on 2022/04/13.
//

import Foundation

protocol UserType {
    var id: Int { get }
    var nickname: Int { get }
    var profile: String { get }
    var push_token: Int { get }
}

struct UserResponse: NetworkResponse, Codable {
    let statusCode: Int
    let body: User
}

struct User: UserType, Codable {
    let id: Int
    let nickname: Int
    let profile: String
    let push_token: Int
    
    enum CodingKeys: String, CodingKey {
        case id
        case nickname
        case profile
        case push_token
    }

    init(id: Int,
         nickname: Int,
         profile: String,
         push_token: Int) {
        self.id = id
        self.nickname = nickname
        self.profile = profile
        self.push_token = push_token
    }
}
