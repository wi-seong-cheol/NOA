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
    
    @IBOutlet weak var profile: UIImageView!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var contents: UILabel!
    @IBOutlet weak var date: UILabel!
    @IBOutlet weak var countView: UIView!
    @IBOutlet weak var count: UILabel!
    
    private let cellDisposeBag = DisposeBag()
    
    var disposeBag = DisposeBag()
    let onData: AnyObserver<Lecture>
    
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

    override func prepareForReuse() {
        super.prepareForReuse()
        disposeBag = DisposeBag()
    }
}

