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
            type: .circleStrokeSpin,
            color: .black,
            padding: 0)
        
        indicator.center = self.view.center
                
        // 기타 옵션
        indicator.color = UIColor(red: 237, green: 106, blue: 201)
        
        return indicator
    }()
    
    var viewModel: FeedDetailViewModel
    var disposeBag = DisposeBag()

    // MARK: - Life Cycle

    init(viewModel: FeedDetailViewModel = FeedDetailViewModel()) {
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
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
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
        profile.isUserInteractionEnabled = true
        profile.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.didSelectedProfile(_:))))
        self.navigationController?.navigationBar.tintColor = .black
        self.navigationController?.navigationBar.topItem?.title = ""
        self.view.addSubview(indicator)
    }
    
    // MARK: - UI Binding
    func setupBindings() {
        // ------------------------------
        //     INPUT
        // ------------------------------
        more.rx.tap
            .subscribe(onNext: {[weak self] _ in
                self?.reportAlert()
            })
            .disposed(by: disposeBag)
        
        like.rx.tap
            .bind(to: viewModel.input.likeClick)
            .disposed(by: disposeBag)
            
        // ------------------------------
        //     Page Move
        // ------------------------------

        // 페이지 이동
        
        // ------------------------------
        //     OUTPUT
        // ------------------------------
        
        viewModel.output.work
            .drive(work.rx.image)
            .disposed(by: disposeBag)
        
        viewModel.output.profile
            .drive(profile.rx.image)
            .disposed(by: disposeBag)
        
        viewModel.output.nickname
            .drive(nickname.rx.text)
            .disposed(by: disposeBag)
        
        viewModel.output.like
            .drive((like.imageView?.rx.image)!)
            .disposed(by: disposeBag)
        
        viewModel.output.likeCount
            .drive(likeCount.rx.text)
            .disposed(by: disposeBag)
        
        viewModel.output.nft
            .drive(nft.rx.image)
            .disposed(by: disposeBag)
        
        viewModel.output.titleLabel
            .drive(titleLabel.rx.text)
            .disposed(by: disposeBag)
        
        viewModel.output.desc
            .drive(desc.rx.text)
            .disposed(by: disposeBag)
        
        // Alert
        viewModel.output.alertMessage
            .skip(1)
            .map{ $0 as String }
            .subscribe(onNext: { [weak self] message in
                self?.OKDialog(message)
            })
            .disposed(by: disposeBag)
        
        // 에러 처리
        viewModel.output.errorMessage
            .map { $0.domain }
            .subscribe(onNext: { [weak self] message in
                self?.OKDialog("Order Fail")
            }).disposed(by: disposeBag)
        
        // 액티비티 인디케이터
        viewModel.output.activated
            .skip(1)
            .map { $0 }
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: {[weak self] finished in
                if finished {
                    self?.indicator.startAnimating()
                } else {
                    self?.indicator.stopAnimating()
                }
            })
            .disposed(by: disposeBag)
    }
    
    func reportAlert() {
        let actions: [UIAlertController.AlertAction] = [
            .action(title: "신고하기"),
            .action(title: "취소", style: .cancel)
        ]

        return UIAlertController
            .present(in: self, title: "Alert", message: "message", style: .actionSheet, actions: actions)
            .filter{ $0 == 0 }
            .subscribe(onNext: { _ in
                Observable<Void>.just(Void())
                    .subscribe(onNext: { _ in
                        self.viewModel.input.report.onNext(Void())
                    })
                    .disposed(by: self.disposeBag)
            })
            .disposed(by: disposeBag)
    }
    
    @objc func didSelectedProfile(_ sender: UIButton) {
        let storyboard = UIStoryboard(name:"Profile", bundle: nil)
        let pushVC = storyboard.instantiateViewController(withIdentifier: "OtherProfileViewController") as! OtherProfileViewController
        viewModel.output.artist
            .drive{ artist in
                pushVC.viewModel = OtherProfileViewModel(artist)
                self.navigationController?.pushViewController(pushVC, animated: true)
            }
            .disposed(by: disposeBag)
    }
}
