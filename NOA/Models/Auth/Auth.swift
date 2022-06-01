//
//  Auth.swift
//  NOA
//
//  Created by wi_seong on 2022/05/26.
//

import Foundation

struct Duplicate: Codable {
    let user_code: String
    
    enum CodingKeys: String, CodingKey {
        case user_code
    }

    init(user_code: String) {
        self.user_code = user_code
    }
}

struct LoginResponse: NetworkResponse, Codable {
    var status_code: Int
    let data: LoginResult?
    let message: String?
    
    enum CodingKeys: String, CodingKey {
        case status_code
        case data
        case message
    }
}

struct LoginResult: Codable {
    let user_code: Int
    let accessToken: String
    let refreshToken: String
}
