//
//  OtherProfileViewController.swift
//  NOA
//
//  Created by wi_seong on 2022/04/28.
//

import RxCocoa
import RxSwift
import RxViewController
import NVActivityIndicatorView
import UIKit
import PagingKit

class OtherProfileViewController: UIViewController {
    
    @IBOutlet weak var profile: UIImageView!
    @IBOutlet weak var nickname: UILabel!
    @IBOutlet weak var follow: UIButton!
    @IBOutlet weak var sendMessage: UIButton!
    @IBOutlet weak var statusMessage: UILabel!
    
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
    
    var viewModel: OtherProfileViewModel
    var disposeBag = DisposeBag()

    // MARK: - Life Cycle

    init(viewModel: OtherProfileViewModel = OtherProfileViewModel()) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        viewModel = OtherProfileViewModel()
        super.init(coder: aDecoder)
    }
    
    var menuViewController: PagingMenuViewController!
    var contentViewController: PagingContentViewController!
    
    private lazy var dataSource: [(menu: String, content: UIViewController)] = ["ALL", "NFT"].map {
        
        let title = $0
        
        switch title {
        case "ALL":
            let vc = UIStoryboard(name: "Profile", bundle: nil).instantiateViewController(identifier: "AllWorkViewController") as! AllWorkViewController
            viewModel.output.artist
                .drive{ artist in
                    vc.viewModel = WorkViewModel(artist)
                }
                .disposed(by: disposeBag)
            return (menu: title, content: vc)
        case "NFT":
            let vc = UIStoryboard(name: "Profile", bundle: nil).instantiateViewController(identifier: "NFTWorkViewController") as! NFTWorkViewController
            viewModel.output.artist
                .drive{ artist in
                    vc.viewModel = WorkViewModel(artist)
                }
                .disposed(by: disposeBag)
            return (menu: title, content: vc)
        default:
            let vc = UIStoryboard(name: "Profile", bundle: nil).instantiateViewController(identifier: "NFTWorkViewController") as! NFTWorkViewController
            viewModel.output.artist
                .drive{ artist in
                    vc.viewModel = WorkViewModel(artist)
                }
                .disposed(by: disposeBag)
            return (menu: title, content: vc)
        }
    }
    
    lazy var firstLoad: (() -> Void)? = { [weak self, menuViewController, contentViewController] in
        menuViewController?.reloadData()
        contentViewController?.reloadData()
        self?.firstLoad = nil
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        firstLoad?()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configure()
        setupBindings()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? PagingMenuViewController {
            menuViewController = vc
            menuViewController.dataSource = self
            menuViewController.delegate = self
        } else if let vc = segue.destination as? PagingContentViewController {
            contentViewController = vc
            contentViewController.dataSource = self
            contentViewController.delegate = self
        }
    }
}

// MARK: - Paging Menu Data Source
extension OtherProfileViewController: PagingMenuViewControllerDataSource {
    func numberOfItemsForMenuViewController(viewController: PagingMenuViewController) -> Int {
        return dataSource.count
    }
    
    func menuViewController(viewController: PagingMenuViewController, widthForItemAt index: Int) -> CGFloat {
        return (self.view.frame.width)/2
    }
    
    func menuViewController(viewController: PagingMenuViewController, cellForItemAt index: Int) -> PagingMenuViewCell {
        let cell = viewController.dequeueReusableCell(withReuseIdentifier: "MenuCell", for: index) as! MenuCell
        if dataSource[index].menu == "ALL" {
            cell.category.image = UIImage(named: "all_asset")
        } else {
            cell.category.image = UIImage(named: "nft_asset")
        }
        return cell
    }
}

// MARK: - Paging Menu Delegate
extension OtherProfileViewController: PagingMenuViewControllerDelegate {
    func menuViewController(viewController: PagingMenuViewController, didSelect page: Int, previousPage: Int) {
        contentViewController.scroll(to: page, animated: true)
    }
}

// MARK: - Paging Content Data Source
extension OtherProfileViewController: PagingContentViewControllerDataSource {
    func numberOfItemsForContentViewController(viewController: PagingContentViewController) -> Int {
        return dataSource.count
    }
    
    func contentViewController(viewController: PagingContentViewController, viewControllerAt index: Int) -> UIViewController {
        return dataSource[index].content
    }
}

// MARK: - Paging Content Delegate
extension OtherProfileViewController: PagingContentViewControllerDelegate {
    func contentViewController(viewController: PagingContentViewController, didManualScrollOn index: Int, percent: CGFloat) {
        menuViewController.scroll(index: index, percent: percent, animated: false)
    }
}

extension OtherProfileViewController {
    // MARK: - UI Setting
    func configure() {
        // Set Paging Kit
        menuViewController.register(nib: UINib(nibName: "MenuCell", bundle: nil), forCellWithReuseIdentifier: "MenuCell")
        menuViewController.registerFocusView(nib: UINib(nibName: "FocusView", bundle: nil))
        contentViewController.scrollView.isScrollEnabled = true
        
        profile.layer.cornerRadius = profile.frame.width / 2
        nickname.font = UIFont.NotoSansCJKkr(type: .medium, size: 14)
        statusMessage.font = UIFont.NotoSansCJKkr(type: .medium, size: 14)
        follow.titleLabel?.font = UIFont.NotoSansCJKkr(type: .medium, size: 12)
        follow.layer.borderWidth = 1
        follow.layer.cornerRadius = 3
        sendMessage.titleLabel?.font = UIFont.NotoSansCJKkr(type: .medium, size: 12)
        sendMessage.layer.borderWidth = 1
        sendMessage.layer.cornerRadius = 3
        self.navigationController?.navigationBar.tintColor = .black
        self.navigationController?.navigationBar.topItem?.title = ""
    }
    
    // MARK: - UI Binding
    func setupBindings() {
        // ------------------------------
        //     INPUT
        // ------------------------------
        rx.viewWillAppear
            .take(1)
            .map { _ in () }
            .bind(to: viewModel.input.load)
            .disposed(by: disposeBag)
        
        follow.rx.tap
            .bind(to: viewModel.input.follow)
            .disposed(by: disposeBag)
        
        sendMessage.rx.tap
            .bind(to: viewModel.input.message)
            .disposed(by: disposeBag)
        
        // ------------------------------
        //     Page Move
        // ------------------------------
        
        // ------------------------------
        //     OUTPUT
        // ------------------------------
        
        viewModel.output.followLabel
            .drive{ [weak self] text in
                self?.follow.setTitle(text, for: .normal)
            }
            .disposed(by: disposeBag)
        
        viewModel.output.profile
            .drive(profile.rx.image)
            .disposed(by: disposeBag)
        
        viewModel.output.nickname
            .drive(nickname.rx.text)
            .disposed(by: disposeBag)
        
        viewModel.output.status
            .drive(statusMessage.rx.text)
            .disposed(by: disposeBag)
        
        viewModel.output.move
            .subscribe(onNext: {
                if $0 {
                    let storyboard = UIStoryboard(name:"Chat", bundle: nil)
                    let pushVC = storyboard.instantiateViewController(withIdentifier: "ChattingViewController") as! ChattingViewController
                    self.viewModel.output.artist
                        .drive(onNext: { artist in
                            let chatRoom = ChatRoom(message: ChatRoomMessage(message: "",
                                                              unreadCount: 0,
                                                              created: ""),
                                     owner: artist,
                                                    roomId: self.viewModel.roomId.value)
                            pushVC.viewModel = ChattingViewModel(chatRoom)
                            self.navigationController?.pushViewController(pushVC, animated: true)
                        })
                        .disposed(by: self.disposeBag)
                }
            })
            .disposed(by: disposeBag)
        
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
        
        // Alert
        viewModel.output.alertMessage
            .skip(1)
            .map{ $0 as String }
            .subscribe(onNext: { [weak self] message in
                self?.OKDialog(message)
            })
            .disposed(by: disposeBag)
        
        viewModel.output.errorMessage
            .map { $0.domain }
            .subscribe(onNext: { [weak self] message in
                self?.OKDialog("Order Fail")
            }).disposed(by: disposeBag)
    }
}
