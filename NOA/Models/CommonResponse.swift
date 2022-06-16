//
//  CommonResponse.swift
//  NOA
//
//  Created by wi_seong on 2022/05/27.
//

import Foundation

protocol NetworkResponse {
    var status_code: Int { get }
}

struct CommonResponse: NetworkResponse, Codable {
    let message: String?
    let status_code: Int
    
    enum CodingKeys: String, CodingKey {
        case message
        case status_code
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        status_code = try container.decode(Int?.self, forKey: .status_code)!
        
        if let message = try? container.decode(String?.self, forKey: .message) {
            self.message = message
        } else if let message = try? container.decode(Int?.self, forKey: .message) {
            self.message = String(message)
        } else if let message = try? container.decode(SQLError?.self, forKey: .message) {
            let jsonData = try JSONEncoder().encode(message)
            let jsonString = String(data: jsonData, encoding: .utf8)!
            self.message = jsonString
        } else {
            self.message = nil
        }
    }
}

protocol SQLErrorType {
    var code: String { get }
    var error: Int { get }
    var sql: String { get }
    var sqlMessage: String { get }
    var sqlState: Int { get }
}

struct SQLError: Codable, SQLErrorType {
    let code: String
    let error: Int
    let sql: String
    let sqlMessage: String
    let sqlState: Int
    
    init(code: String,
         error: Int,
         sql: String,
         sqlMessage: String,
         sqlState: Int) {
        self.code = code
        self.error = error
        self.sql = sql
        self.sqlMessage = sqlMessage
        self.sqlState = sqlState
    }
}
