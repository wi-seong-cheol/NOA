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
    
    func didSelectedProfile(_ homeTableCell: HomeTableCell, detailButtonTappedFor userId: String)
    func didSelectedMore(_ homeTableCell: HomeTableCell, detailButtonTappedFor workId: String)
    func didSelectedLike(_ homeTableCell: HomeTableCell, detailButtonTappedFor workId: String)
}

class HomeTableCell: UITableViewCell {
    static let identifier = "HomeTableCell"
   
    @IBOutlet var thumbnail: UIImageView!
    @IBOutlet weak var profile: UIImageView!
    @IBOutlet var nickname: UILabel!
    @IBOutlet var title: UILabel!
    @IBOutlet weak var desc: UILabel!
    @IBOutlet weak var likeCount: UILabel!
    
    var delegate: HomeTableDelegate?
    
    private let onCountChanged: (Int) -> Void
    private let cellDisposeBag = DisposeBag()
    
    var disposeBag = DisposeBag()
    let onData: AnyObserver<Lecture>
    let onChanged: Observable<Int>
    let profileId = BehaviorRelay<String>(value: "")
    let workId = BehaviorRelay<String>(value: "")
    
    required init?(coder aDecoder: NSCoder) {
        let data = PublishSubject<Lecture>()
        let changing = PublishSubject<Int>()
        onCountChanged = { changing.onNext($0) }

        onData = data.asObserver()
        onChanged = changing

        super.init(coder: aDecoder)
        
        // MARK: - UI Binding
        data.observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] lecture in
                self?.profileId.accept(lecture.name)
                self?.workId.accept(lecture.id)
                self?.thumbnail.image = UIImage()
                self?.nickname.text = lecture.number
                self?.title.text = lecture.id
                ImageLoader.loadImage(from: lecture.courseImage)
                    .observe(on: MainScheduler.instance)
                    .subscribe(onNext: { (image) in
                        self?.thumbnail.image = image})
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
        delegate?.didSelectedProfile(self, detailButtonTappedFor: profileId.value)
    }
    
    @IBAction func didSelectedMore(_ sender: Any) {
        delegate?.didSelectedMore(self, detailButtonTappedFor: workId.value)
    }
    
    @IBAction func didSelectedLike(_ sender: Any) {
        delegate?.didSelectedLike(self, detailButtonTappedFor: workId.value)
    }
}
