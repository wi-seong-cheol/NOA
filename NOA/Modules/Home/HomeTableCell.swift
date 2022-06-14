//
//  FeedCell.swift
//  NOA
//
//  Created by wi_seong on 2022/04/09.
//

import UIKit
import RxSwift
import RxRelay

protocol HomeTableDelegate: AnyObject {
    
    func didSelectedProfile(_ homeTableCell: HomeTableCell, detailButtonTappedFor artist: Artist)
    func didSelectedMore(_ homeTableCell: HomeTableCell, detailButtonTappedFor workId: Int)
    func didSelectedLike(_ homeTableCell: HomeTableCell, detailButtonTappedFor workId: Int)
}

class HomeTableCell: UITableViewCell {
    static let identifier = "HomeTableCell"
    
    @IBOutlet weak var profile: UIImageView!
    @IBOutlet weak var nickname: UILabel!
    @IBOutlet weak var thumbnail: UIImageView!
    @IBOutlet weak var like: UIButton!
    @IBOutlet weak var likeCount: UILabel!
    @IBOutlet weak var nft: UIImageView!
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var desc: UILabel!
    
    var delegate: HomeTableDelegate?
    
    private let onCountChanged: (Int) -> Void
    private let cellDisposeBag = DisposeBag()
    
    var disposeBag = DisposeBag()
    let onData: AnyObserver<Feed>
    let onChanged: Observable<Int>
    let artist = BehaviorRelay<Artist>(value: Artist.EMPTY)
    let profileId = BehaviorRelay<Int>(value: -1)
    let workId = BehaviorRelay<Int>(value: -1)
    
    required init?(coder aDecoder: NSCoder) {
        let data = PublishSubject<Feed>()
        let changing = PublishSubject<Int>()
        onCountChanged = { changing.onNext($0) }

        onData = data.asObserver()
        onChanged = changing

        super.init(coder: aDecoder)
        
        // MARK: - UI Binding
        data.observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] feed in
                self?.artist.accept(feed.user!)
                self?.profileId.accept(feed.user!.user_code)
                self?.workId.accept(feed.post.id)
                
                self?.profile.image = UIImage()
                self?.nickname.text = feed.user!.nickname
                self?.thumbnail.image = UIImage()
                self?.like.imageView?.image = feed.post.isLike == 0 ? UIImage(named: "heart_blank_asset"): UIImage(named: "heart_fill_asset")
                self?.likeCount.text = String(feed.post.like_count)
                self?.nft.image = feed.post.nft == 0 ? UIImage() : UIImage(named: "nft_asset")
                self?.title.text = feed.post.title
                self?.desc.text = feed.post.text
                
                ImageLoader.loadImage(from: feed.post.img)
                    .observe(on: MainScheduler.instance)
                    .subscribe(onNext: { (image) in
                        self?.thumbnail.image = image})
                    .disposed(by: self!.disposeBag)
                
                ImageLoader.loadImage(from: feed.user!.profile)
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
        nickname.font = UIFont.NotoSansCJKkr(type: .medium, size: 14)
        likeCount.font = UIFont.NotoSansCJKkr(type: .medium, size: 14)
        title.font = UIFont.NotoSansCJKkr(type: .medium, size: 14)
        desc.font = UIFont.NotoSansCJKkr(type: .regular, size: 14)
        desc.setTextWithLineHeight(text: desc.text, lineHeight: 16)
        
        self.profile.isUserInteractionEnabled = true
        self.profile.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.didSelectedProfile(_:))))
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        disposeBag = DisposeBag()
    }
    
    @objc func didSelectedProfile(_ sender: UIButton) {
        delegate?.didSelectedProfile(self, detailButtonTappedFor: artist.value)
    }
    
    @IBAction func didSelectedMore(_ sender: Any) {
        delegate?.didSelectedMore(self, detailButtonTappedFor: workId.value)
    }
    
    @IBAction func didSelectedLike(_ sender: Any) {
        delegate?.didSelectedLike(self, detailButtonTappedFor: workId.value)
        
    }
}
