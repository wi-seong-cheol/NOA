//
//  FeedDetailViewController.swift
//  NOA
//
//  Created by wi_seong on 2022/04/20.
//

import RxCocoa
import RxSwift
import RxViewController
import NVActivityIndicatorView
import UIKit

class FeedDetailViewController: UIViewController {
    
    static let identifier = "FeedDetailViewController"
    @IBOutlet weak var profile: UIImageView!
    @IBOutlet weak var nickname: UILabel!
    @IBOutlet weak var more: UIButton!
    @IBOutlet weak var work: UIImageView!
    @IBOutlet weak var like: UIButton!
    @IBOutlet weak var likeCount: UILabel!
    @IBOutlet weak var nft: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var desc: UILabel!
    
    lazy var indicator: NVActivityIndicatorView = {
        let indicator = NVActivityIndicatorView(
            frame: CGRect(
                x: self.view.frame.width/2 - 25,
                y: self.view.frame.height/2 - 25,
                width: 50,
                height: 50),
            type: .ballScaleMultiple,
            color: .black,
            padding: 0)
        
        indicator.center = self.view.center
                
        // 기타 옵션
        indicator.color = .purple
        
        indicator.stopAnimating()
        return indicator
    }()
    
    var viewModel: FeedDetailViewModelType
    var disposeBag = DisposeBag()

    // MARK: - Life Cycle

    init(viewModel: FeedDetailViewModelType = FeedDetailViewModel()) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        viewModel = FeedDetailViewModel()
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configure()
        setupBindings()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
    }
}

extension FeedDetailViewController {
    // MARK: - UI Setting
    func configure() {
        profile.layer.cornerRadius = profile.frame.width / 2
        nickname.font = UIFont.NotoSansCJKkr(type: .medium, size: 14)
        likeCount.font = UIFont.NotoSansCJKkr(type: .medium, size: 14)
        titleLabel.font = UIFont.NotoSansCJKkr(type: .medium, size: 14)
        desc.font = UIFont.NotoSansCJKkr(type: .regular, size: 14)
    }
    
    // MARK: - UI Binding
    func setupBindings() {
        // ------------------------------
        //     INPUT
        // ------------------------------
        viewModel.work
            .bind(to: work.rx.image)
            .disposed(by: disposeBag)
        
        viewModel.profile
            .bind(to: profile.rx.image)
            .disposed(by: disposeBag)
        
        // ------------------------------
        //     Page Move
        // ------------------------------

        // 페이지 이동
        
        // ------------------------------
        //     OUTPUT
        // ------------------------------

        // 에러 처리
        viewModel.errorMessage
            .map { $0.domain }
            .subscribe(onNext: { [weak self] message in
                self?.OKDialog("Order Fail")
            }).disposed(by: disposeBag)
    }
}
