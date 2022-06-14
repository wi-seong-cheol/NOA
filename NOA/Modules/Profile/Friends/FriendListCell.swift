//
//  FriendListCell.swift
//  NOA
//
//  Created by wi_seong on 2022/05/10.
//

import UIKit
import RxSwift
import RxRelay

protocol FriendListTableDelegate: AnyObject {
    func didSelectedMore(_ friendListTableCell: FriendListTableCell, detailButtonTappedFor profileId: String)
}

class FriendListTableCell: UITableViewCell {
    static let identifier = "FriendListTableCell"
   
    @IBOutlet weak var profile: UIImageView!
    @IBOutlet var nickname: UILabel!
    @IBOutlet weak var statusMessage: UILabel!
    
    var delegate: FriendListTableDelegate?
    
    private let onCountChanged: (Int) -> Void
    private let cellDisposeBag = DisposeBag()
    
    var disposeBag = DisposeBag()
    let onData: AnyObserver<UserResponse>
    let onChanged: Observable<Int>
    let profileId = BehaviorRelay<String>(value: "")
    
    required init?(coder aDecoder: NSCoder) {
        let data = PublishSubject<UserResponse>()
        let changing = PublishSubject<Int>()
        onCountChanged = { changing.onNext($0) }

        onData = data.asObserver()
        onChanged = changing

        super.init(coder: aDecoder)
        
        // MARK: - UI Binding
        data.observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] user in
                self?.profileId.accept(String(user.user_code))
                self?.nickname.text = user.user_nickname
                self?.statusMessage.text = user.user_desc ?? ""
                self?.profile.image = UIImage()
                ImageLoader.loadImage(from: user.user_profile)
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
        statusMessage.font = UIFont.NotoSansCJKkr(type: .regular, size: 10)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        disposeBag = DisposeBag()
    }
    
    @IBAction func didSelectedMore(_ sender: Any) {
        delegate?.didSelectedMore(self, detailButtonTappedFor: profileId.value)
    }
}
