//
//  ChatTableCell.swift
//  NOA
//
//  Created by wi_seong on 2022/04/24.
//

import Foundation
import RxSwift

class ChatTableCell: UITableViewCell {
    static let identifier = "ChatTableCell"
    
    private let cellDisposeBag = DisposeBag()
    
    var disposeBag = DisposeBag()
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        disposeBag = DisposeBag()
    }
}

