//
//  Feed.swift
//  NOA
//
//  Created by wi_seong on 2022/04/09.
//

import Foundation

struct Feed: Codable {
    var user: Artist?
    var post: Work
    
    enum CodingKeys: String, CodingKey {
        case user
        case post
    }
    
    init(user: Artist?,
         post: Work) {
        self.user = user
        self.post = post
    }
}

extension Feed {
    static let EMPTY = Feed(user: Artist.EMPTY, post: Work.EMPTY)
}

