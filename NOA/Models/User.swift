//
//  User.swift
//  NOA
//
//  Created by wi_seong on 2022/04/13.
//

import Foundation

protocol UserType {
    var id: Int { get }
    var nickname: String { get }
    var profile: String { get }
    var push_token: String { get }
}

struct User: UserType, Codable {
    var id: Int
    var nickname: String
    var profile: String
    var status_message: String
    var push_token: String
    
    enum CodingKeys: String, CodingKey {
        case id = "user_code"
        case nickname
        case profile
        case status_message
        case push_token
    }

    init(id: Int,
         nickname: String,
         profile: String,
         status_message: String,
         push_token: String) {
        self.id = id
        self.nickname = nickname
        self.profile = profile
        self.status_message = status_message
        self.push_token = push_token
    }
}

struct UserResponse: Codable {
    let user_code: Int
    let user_nickname: String
    let user_profile: String
    let user_wallet: String?
    let user_report: Int?
    let user_desc: String?
    let isFriend: Int?
    let isReport: Int?
    
    enum CodingKeys: String, CodingKey {
        case user_code
        case user_nickname
        case user_profile
        case user_wallet
        case user_report
        case user_desc
        case isFriend = "isfriend"
        case isReport
    }

    init(user_code: Int,
         user_nickname: String,
         user_profile: String,
         user_wallet: String?,
         user_report: Int?,
         user_desc: String?,
         isFriend: Int?,
         isReport: Int?) {
        self.user_code = user_code
        self.user_nickname = user_nickname
        self.user_profile = user_profile
        self.user_wallet = user_wallet
        self.user_report = user_report
        self.user_desc = user_desc
        self.isFriend = isFriend
        self.isReport = isReport
    }
}
