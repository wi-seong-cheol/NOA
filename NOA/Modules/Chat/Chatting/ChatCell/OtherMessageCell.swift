//
//  OtherMessageCell.swift
//  NOA
//
//  Created by wi_seong on 2022/05/05.
//

import Foundation
import RxSwift
import RxCocoa
import UIKit

protocol OtherMessageDelegate: AnyObject {
    func didSelectedProfile(_ otherMessageCell: OtherMessageCell, detailButtonTappedFor userId: String)
}

class OtherMessageCell: UITableViewCell {
    static let identifier = "OtherMessageCell"
    
    @IBOutlet weak var profile: UIImageView!
    @IBOutlet weak var nickname: UILabel!
    @IBOutlet weak var message: UILabel!
    @IBOutlet weak var timestamp: UILabel!
    @IBOutlet weak var background: UIView!
    
    var delegate: OtherMessageDelegate?
    
    private let cellDisposeBag = DisposeBag()
    
    var disposeBag = DisposeBag()
    let onData: AnyObserver<OtherMessageType>
    let profileId = BehaviorRelay<String>(value: "")
    
    required init?(coder aDecoder: NSCoder) {
        let data = PublishSubject<OtherMessageType>()
        
        onData = data.asObserver()
        
        super.init(coder: aDecoder)
        
        data.observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] msg in
                self?.message.text = msg.message
                self?.timestamp.text = Transform.shared.messageTimestamp(msg.timestamp)
                self?.nickname.text = msg.nickname
                
                ImageLoader.loadImage(from: msg.profile)
                    .observe(on: MainScheduler.instance)
                    .subscribe(onNext: { (image) in
                        self?.profile.image = image})
                    .disposed(by: self!.disposeBag)
                
                self?.background.isHidden = false
            })
            .disposed(by: cellDisposeBag)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        background.layer.cornerRadius = 4
        background.layer.borderWidth = 0.5
        background.layer.borderColor = UIColor(red: 112, green: 112, blue: 112).cgColor
        background.isHidden = true
        
        nickname.font = UIFont.NotoSansCJKkr(type: .medium, size: 12)
        message.font = UIFont.NotoSansCJKkr(type: .regular, size: 12)
        timestamp.font = UIFont.NotoSansCJKkr(type: .regular, size: 10)
        profile.layer.cornerRadius = profile.frame.width / 2
        
        self.profile.isUserInteractionEnabled = true
        self.profile.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.didSelectedProfile(_:))))
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        disposeBag = DisposeBag()
    }
    
    @objc func didSelectedProfile(_ sender: UIButton) {
        delegate?.didSelectedProfile(self, detailButtonTappedFor: profileId.value)
    }
}



