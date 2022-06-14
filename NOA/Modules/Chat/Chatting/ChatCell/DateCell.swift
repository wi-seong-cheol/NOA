//
//  DateCell.swift
//  NOA
//
//  Created by wi_seong on 2022/05/05.
//

import Foundation
import RxSwift
import UIKit

class DateCell: UITableViewCell {
    static let identifier = "DateCell"
    
    @IBOutlet weak var Date: UILabel!
    
    private let cellDisposeBag = DisposeBag()
    
    var disposeBag = DisposeBag()
    let onData: AnyObserver<DateMessageType>
    
    required init?(coder aDecoder: NSCoder) {
        let data = PublishSubject<DateMessageType>()
        
        onData = data.asObserver()
        
        super.init(coder: aDecoder)
        
        data.observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] d in
                self?.Date.text = Transform.shared.messageDay(d.date)
            })
            .disposed(by: cellDisposeBag)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        Date.font = UIFont.NotoSansCJKkr(type: .medium, size: 12)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        disposeBag = DisposeBag()
    }
}




