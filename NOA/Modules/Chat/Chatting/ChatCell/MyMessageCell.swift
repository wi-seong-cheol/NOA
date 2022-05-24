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
                self?.timestamp.text = msg.timestamp
            })
            .disposed(by: cellDisposeBag)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        disposeBag = DisposeBag()
    }
}



