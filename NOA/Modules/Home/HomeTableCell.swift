//
//  FeedCell.swift
//  NOA
//
//  Created by wi_seong on 2022/04/09.
//

import UIKit
import RxSwift

class HomeTableCell: UITableViewCell {
    static let identifier = "HomeTableCell"
   
    @IBOutlet var thumbnail: UIImageView!
    @IBOutlet var name: UILabel!
    @IBOutlet var orgName: UILabel!
    @IBOutlet weak var like: UIButton!
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
                self?.thumbnail.image = UIImage()
                self?.name.text = lecture.number
                self?.orgName.text = lecture.id
                ImageLoader.loadImage(from: lecture.courseImage)
                    .observe(on: MainScheduler.instance)
                    .subscribe(onNext: { (image) in
                        self?.thumbnail.image = image})
                    .disposed(by: self!.disposeBag)
            })
            .disposed(by: cellDisposeBag)
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        disposeBag = DisposeBag()
    }
}
