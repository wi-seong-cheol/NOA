//
//  Feed.swift
//  NOA
//
//  Created by wi_seong on 2022/04/09.
//

import Foundation

protocol NetworkResponse {
    var statusCode: Int { get }
}

struct FeedResponse: NetworkResponse, Codable {
    let statusCode: Int
    let body: FeedResult
}

struct FeedResult: Codable {
    let list: [Feed]
}

struct Feed: Codable {
    let projectID: Int

    enum CodingKeys: String, CodingKey {
        case projectID = "projectId"
    }
}

extension FeedResult {
    static let EMPTY = FeedResult(list: [])
}
