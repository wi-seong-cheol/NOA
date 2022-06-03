//
//  Search.swift
//  NOA
//
//  Created by wi_seong on 2022/05/02.
//

import Foundation

struct Search: Codable {
    
    let post_id: Int
    let post_title: String?
    
    enum CodingKeys: String, CodingKey {
        case post_id
        case post_title
    }

    init(post_id: Int,
         post_title: String?) {
        self.post_id = post_id
        self.post_title = post_title
    }
}
