//
//  Work.swift
//  NOA
//
//  Created by wi_seong on 2022/06/01.
//

import Foundation

struct Work: Codable {
    let id: Int
    var like_count: Int
    let nft: Int
    let img: String
    let text: String
    let title: String
    let tag: String
    var isLike: Int
    
    enum CodingKeys: String, CodingKey {
        case id
        case like_count
        case nft
        case img
        case text
        case title
        case tag
        case isLike = "I_like_this_feed"
    }
    
    init(id: Int,
         like_count: Int,
         nft: Int,
         img: String,
         text: String,
         title: String,
         tag: String,
         isLike: Int) {
        self.id = id
        self.like_count = nft
        self.nft = nft
        self.img = img
        self.text = text
        self.title = title
        self.tag = tag
        self.isLike = isLike
    }
}

extension Work {
    static let EMPTY = Work(id: 0, like_count: 0, nft: 0, img: "", text: "", title: "", tag: "", isLike: 0)
}
