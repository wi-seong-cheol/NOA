//
//  OtherMessageCell.swift
//  NOA
//
//  Created by wi_seong on 2022/05/05.
//

import Foundation
import RxSwift
import UIKit

class OtherMessageCell: UITableViewCell {
    static let identifier = "OtherMessageCell"
    
    @IBOutlet weak var profile: UIImageView!
    @IBOutlet weak var nickname: UILabel!
    @IBOutlet weak var message: UILabel!
    @IBOutlet weak var timestamp: UILabel!
    
    private let cellDisposeBag = DisposeBag()
    
    var disposeBag = DisposeBag()
    let onData: AnyObserver<Lecture>
    
    required init?(coder aDecoder: NSCoder) {
        let data = PublishSubject<Lecture>()
        
        onData = data.asObserver()
        
        super.init(coder: aDecoder)
        
        data.observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] lecture in
            })
            .disposed(by: cellDisposeBag)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        profile.layer.cornerRadius = profile.frame.width / 2
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        disposeBag = DisposeBag()
    }
}



