//
//  FeedCell.swift
//  NOA
//
//  Created by wi_seong on 2022/04/09.
//

import UIKit
import RxSwift

class FeedCell: UITableViewCell {
    static let identifier = "FeedCell"
   
    @IBOutlet var thumbnail: UIImageView!
    @IBOutlet var name: UILabel!
    @IBOutlet var orgName: UILabel!
    @IBOutlet var duration: UILabel!
    
    private let onCountChanged: (Int) -> Void
    private let cellDisposeBag = DisposeBag()
    
    var disposeBag = DisposeBag()
    let onData: AnyObserver<Lecture>
    let onChanged: Observable<Int>
    
    required init?(coder aDecoder: NSCoder) {
        let data = PublishSubject<Lecture>()
        let changing = PublishSubject<Int>()
        onCountChanged = { changing.onNext($0) }

        onData = data.asObserver()
        onChanged = changing

        super.init(coder: aDecoder)

        data.observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] lecture in
                ImageLoader.loadImage(from: lecture.courseImage)
                    .observe(on: MainScheduler.instance)
                    // ! Refactoring 필요
                    .bind(to: (self?.thumbnail.rx.image)!)
                    .disposed(by: self!.cellDisposeBag)
                self?.name.text = lecture.number
                self?.orgName.text = lecture.id
            })
            .disposed(by: cellDisposeBag)
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        disposeBag = DisposeBag()
    }
}
