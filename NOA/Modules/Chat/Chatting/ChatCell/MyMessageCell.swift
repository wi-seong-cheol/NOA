//
//  MyMessageCell.swift
//  NOA
//
//  Created by wi_seong on 2022/05/05.
//

import Foundation
import RxSwift
import UIKit

class MyMessageCell: UITableViewCell {
    static let identifier = "MyMessageCell"
    
    @IBOutlet weak var message: UILabel!
    @IBOutlet weak var timestamp: UILabel!
    @IBOutlet weak var background: UIView!
    private let cellDisposeBag = DisposeBag()
    
    var disposeBag = DisposeBag()
    let onData: AnyObserver<MyMessageType>
    
    required init?(coder aDecoder: NSCoder) {
        let data = PublishSubject<MyMessageType>()
        
        onData = data.asObserver()
        
        super.init(coder: aDecoder)
        
        data.observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] msg in
                self?.message.text = msg.message
                self?.timestamp.text = Transform.shared.sendTimestamp(msg.timestamp)
            })
            .disposed(by: cellDisposeBag)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        message.font = UIFont.NotoSansCJKkr(type: .regular, size: 12)
        timestamp.font = UIFont.NotoSansCJKkr(type: .regular, size: 10)
        background.layer.cornerRadius = 4
        background.layer.borderWidth = 0.5
        background.layer.borderColor = UIColor(red: 112, green: 112, blue: 112).cgColor
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        disposeBag = DisposeBag()
    }
}



