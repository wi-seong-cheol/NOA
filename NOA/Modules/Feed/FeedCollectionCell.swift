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
    @IBOutlet weak var nft: UIImageView!
    
    private let cellDisposeBag = DisposeBag()
    
    var disposeBag = DisposeBag()
    let onData: AnyObserver<Feed>
    let workId = BehaviorRelay<Int>(value: -1)
    
    required init?(coder aDecoder: NSCoder) {
        let data = PublishSubject<Feed>()

        onData = data.asObserver()
        
        super.init(coder: aDecoder)
        
        data.observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] feed in
                self?.workId.accept(feed.post.id)
                self?.nft.image = feed.post.nft == 0 ? UIImage() : UIImage(named: "nft_asset")!
                self?.thumbnail.image = UIImage()
                ImageLoader.cache_loadImage(url: feed.post.img)
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
