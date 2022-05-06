//
//  ChatTableCell.swift
//  NOA
//
//  Created by wi_seong on 2022/04/24.
//

import Foundation
import RxSwift
import RxCocoa
import UIKit

protocol ChatTableDelegate: AnyObject {
    func didSelectedProfile(_ chatTableCell: ChatTableCell, detailButtonTappedFor userId: String)
}

class ChatTableCell: UITableViewCell {
    static let identifier = "ChatTableCell"
    
    @IBOutlet weak var profile: UIImageView!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var contents: UILabel!
    @IBOutlet weak var date: UILabel!
    @IBOutlet weak var countView: UIView!
    @IBOutlet weak var count: UILabel!
    
    var delegate: ChatTableDelegate?
    
    private let cellDisposeBag = DisposeBag()
    
    var disposeBag = DisposeBag()
    let onData: AnyObserver<Lecture>
    let profileId = BehaviorRelay<String>(value: "")
    
    required init?(coder aDecoder: NSCoder) {
        let data = PublishSubject<Lecture>()
        
        onData = data.asObserver()
        
        super.init(coder: aDecoder)
        
        data.observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] lecture in
                self?.profile.image = UIImage()
                self?.name.text = lecture.number
                self?.contents.text = lecture.id
                self?.date.text = lecture.id
                self?.count.text = lecture.id
                ImageLoader.loadImage(from: lecture.courseImage)
                    .observe(on: MainScheduler.instance)
                    .subscribe(onNext: { (image) in
                        self?.profile.image = image})
                    .disposed(by: self!.disposeBag)
            })
            .disposed(by: cellDisposeBag)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        profile.layer.cornerRadius = profile.frame.width / 2
        name.font = UIFont.NotoSansCJKkr(type: .medium, size: 14)
        contents.font = UIFont.NotoSansCJKkr(type: .medium, size: 14)
        contents.setTextWithLineHeight(text: contents.text, lineHeight: 14)
        date.font = UIFont.NotoSansCJKkr(type: .medium, size: 10)
        count.font = UIFont.NotoSansCJKkr(type: .medium, size: 10)
        
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

