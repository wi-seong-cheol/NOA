//
//  DateMessage.swift
//  NOA
//
//  Created by wi_seong on 2022/05/05.
//

import Foundation

protocol DateMessageType {
    var date: String { get }
}

struct DateMessage: Codable, DateMessageType {
    let date: String
    
    enum CodingKeys: String, CodingKey {
        case date
    }

    init(date: String) {
        self.date = date
    }
}

