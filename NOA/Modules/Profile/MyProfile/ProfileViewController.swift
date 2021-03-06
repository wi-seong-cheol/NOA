//
//  ProfileViewController.swift
//  NOA
//
//  Created by wi_seong on 2022/04/27.
//

import RxCocoa
import RxSwift
import RxViewController
import NVActivityIndicatorView
import UIKit
import PagingKit

class ProfileViewController: UIViewController {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var setting: UIButton!
    @IBOutlet weak var profile: UIImageView!
    @IBOutlet weak var nickname: UILabel!
    @IBOutlet weak var editProfile: UIButton!
    @IBOutlet weak var followList: UIButton!
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
    
    let viewModel: ProfileViewModel
    var disposeBag = DisposeBag()

    // MARK: - Life Cycle

    init(viewModel: ProfileViewModel = ProfileViewModel()) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        viewModel = ProfileViewModel()
        super.init(coder: aDecoder)
    }
    
    var menuViewController: PagingMenuViewController!
    var contentViewController: PagingContentViewController!
    
    let dataSource: [(menu: String, content: UIViewController)] = ["ALL", "NFT"].map {
        
        let title = $0
        
        switch title {
        case "ALL":
            let vc = UIStoryboard(name: "Profile", bundle: nil).instantiateViewController(identifier: "AllWorkViewController") as! AllWorkViewController
            let user = UserInfo.shared.getUser()
            let artist = Artist(user_code: user.id,
                                profile: user.profile,
                                nickname: user.nickname)
            vc.viewModel = WorkViewModel(artist)
            return (menu: title, content: vc)
        case "NFT":
            let vc = UIStoryboard(name: "Profile", bundle: nil).instantiateViewController(identifier: "NFTWorkViewController") as! NFTWorkViewController
            let user = UserInfo.shared.getUser()
            let artist = Artist(user_code: user.id,
                                profile: user.profile,
                                nickname: user.nickname)
            vc.viewModel = WorkViewModel(artist)
            return (menu: title, content: vc)
        default:
            let vc = UIStoryboard(name: "Profile", bundle: nil).instantiateViewController(identifier: "NFTWorkViewController") as! NFTWorkViewController
            let user = UserInfo.shared.getUser()
            let artist = Artist(user_code: user.id,
                                profile: user.profile,
                                nickname: user.nickname)
            vc.viewModel = WorkViewModel(artist)
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
        
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
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
extension ProfileViewController: PagingMenuViewControllerDataSource {
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
extension ProfileViewController: PagingMenuViewControllerDelegate {
    func menuViewController(viewController: PagingMenuViewController, didSelect page: Int, previousPage: Int) {
        contentViewController.scroll(to: page, animated: true)
    }
}

// MARK: - Paging Content Data Source
extension ProfileViewController: PagingContentViewControllerDataSource {
    func numberOfItemsForContentViewController(viewController: PagingContentViewController) -> Int {
        return dataSource.count
    }
    
    func contentViewController(viewController: PagingContentViewController, viewControllerAt index: Int) -> UIViewController {
        return dataSource[index].content
    }
}

// MARK: - Paging Content Delegate
extension ProfileViewController: PagingContentViewControllerDelegate {
    func contentViewController(viewController: PagingContentViewController, didManualScrollOn index: Int, percent: CGFloat) {
        menuViewController.scroll(index: index, percent: percent, animated: false)
    }
}

extension ProfileViewController {
    // MARK: - UI Setting
    func configure() {
        // Set Paging Kit
        menuViewController.register(nib: UINib(nibName: "MenuCell", bundle: nil), forCellWithReuseIdentifier: "MenuCell")
        menuViewController.registerFocusView(nib: UINib(nibName: "FocusView", bundle: nil))
        contentViewController.scrollView.isScrollEnabled = true
        
        titleLabel.font = UIFont.NotoSansCJKkr(type: .medium, size: 22)
        profile.layer.cornerRadius = profile.frame.width / 2
        nickname.font = UIFont.NotoSansCJKkr(type: .medium, size: 14)
        statusMessage.font = UIFont.NotoSansCJKkr(type: .medium, size: 14)
        editProfile.titleLabel?.font = UIFont.NotoSansCJKkr(type: .medium, size: 12)
        followList.titleLabel?.font = UIFont.NotoSansCJKkr(type: .medium, size: 12)
        editProfile.layer.borderWidth = 1
        editProfile.layer.cornerRadius = 3
        followList.layer.borderWidth = 1
        followList.layer.cornerRadius = 3
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
        
        // ------------------------------
        //     Page Move
        // ------------------------------

        // 페이지 이동
        // MARK: - Setting Page
        setting.rx.tap
            .bind{ [weak self] in
                let storyboard = UIStoryboard(name:"Setting", bundle: nil)
                let pushVC = storyboard.instantiateViewController(withIdentifier: "SettingViewController") as! SettingViewController
                self?.navigationController?.pushViewController(pushVC, animated: true)
            }
            .disposed(by: disposeBag)
        
        // MARK: - Edit Profile Page
        editProfile.rx.tap
            .bind{ [weak self] in
                self?.performSegue(withIdentifier: "editProfileSegue", sender: nil)
            }
            .disposed(by: disposeBag)
        
        // MARK: - followList Page
        followList.rx.tap
            .bind{ [weak self] in
                self?.performSegue(withIdentifier: "followListSegue", sender: nil)
            }
            .disposed(by: disposeBag)
        
        // ------------------------------
        //     OUTPUT
        // ------------------------------
        viewModel.output.profile
            .drive(profile.rx.image)
            .disposed(by: disposeBag)
        
        viewModel.output.nickname
            .drive(nickname.rx.text)
            .disposed(by: disposeBag)
        
        viewModel.output.status
            .drive(statusMessage.rx.text)
            .disposed(by: disposeBag)
        
        viewModel.output.errorMessage
            .map { $0.domain }
            .subscribe(onNext: { [weak self] message in
                self?.OKDialog("Order Fail")
            }).disposed(by: disposeBag)
        
    }
}
