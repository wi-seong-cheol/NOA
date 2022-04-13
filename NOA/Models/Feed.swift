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

protocol PaginationType {
    var count: Int { get }
    var previios: String? { get }
    var num_page: Int { get }
    var next: String? { get }
}

struct FeedResponse: NetworkResponse, Codable {
    let statusCode: Int
    let pagination: Pagination
    let body: FeedResult
}

struct Pagination: PaginationType, Codable {
    let count: Int
    let previios: String?
    let num_page: Int
    let next: String?
}

struct FeedResult: Codable {
    let list: [Feed]
}

struct Feed: Codable {
    let effort: String
    let id: String
    let feed_image: String
    let description: String
    let hidden: Bool
    let artist_name: String
    let created: String

    enum CodingKeys: String, CodingKey {
        case effort
        case id
        case feed_image
        case description
        case hidden
        case artist_name
        case created
    }

    init(effort: String,
         id: String,
         feed_image: String,
         description: String,
         hidden: Bool,
         artist_name: String,
         created: String) {
        self.effort = effort
        self.id = id
        self.feed_image = feed_image
        self.description = description
        self.hidden = hidden
        self.artist_name = artist_name
        self.created = created
    }
}

extension FeedResult {
    static let EMPTY = FeedResult(list: [])
}
