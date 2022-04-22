//
//  FeedCollectionCell.swift
//  NOA
//
//  Created by wi_seong on 2022/04/20.
//

import UIKit
import RxSwift
import RxRelay

class FeedCollectionCell: UICollectionViewCell {
    static let identifier = "FeedCollectionCell"
   
    @IBOutlet var thumbnail: UIImageView!
    
    private let cellDisposeBag = DisposeBag()
    
    var disposeBag = DisposeBag()
    let onData: AnyObserver<Lecture>
    
    required init?(coder aDecoder: NSCoder) {
        let data = PublishSubject<Lecture>()

        onData = data.asObserver()
        
        super.init(coder: aDecoder)
        
        data.observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] lecture in
                self?.thumbnail.image = UIImage()
                ImageLoader.cache_loadImage(url: lecture.courseImage)
                    .observe(on: MainScheduler.instance)
                    .subscribe(onNext: { (image) in
                        self?.thumbnail.image = image
                    })
                    .disposed(by: self!.disposeBag)
            })
            .disposed(by: cellDisposeBag)
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        disposeBag = DisposeBag()
    }
}
