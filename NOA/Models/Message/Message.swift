//
//  Message.swift
//  NOA
//
//  Created by wi_seong on 2022/05/05.
//

import Foundation
import RxDataSources

enum MessageItem {
    case noticeCell(NoticeMessageType)
    case dateCell(DateMessageType)
    case otherMessageCell(OtherMessageType)
    case myMessageCell(MyMessageType)
}

struct MessageSection {
    var items: [Item]
}

extension MessageSection: SectionModelType {
    typealias Item = MessageItem
    
    init(original: MessageSection, items: [Item] = []) {
        self = original
        self.items = items
    }
}
