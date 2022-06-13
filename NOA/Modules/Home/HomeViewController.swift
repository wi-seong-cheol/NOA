//
//  ViewController.swift
//  NOA
//
//  Created by wi_seong on 2022/03/21.
//

import RxCocoa
import RxSwift
import RxViewController
import NVActivityIndicatorView
import UIKit

class HomeViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
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
    
    let viewModel: HomeViewModel
    var disposeBag = DisposeBag()

    // MARK: - Life Cycle

    init(viewModel: HomeViewModel = HomeViewModel()) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        viewModel = HomeViewModel()
        super.init(coder: aDecoder)
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
//        let identifier = segue.identifier ?? ""
//
//        if identifier == "HomeDetailSegue",
//           let selectedFeed = sender as? Lecture,
//           let feedVC = segue.destination as? HomeDetailViewController {
//            let feedViewModel = HomeDetailViewModel(selectedFeed)
//            feedVC.viewModel = feedViewModel
//        }
    }
}

extension HomeViewController {
    // MARK: - UI Setting
    func configure() {
        tableView.refreshControl = UIRefreshControl()
        tableView.rowHeight = UITableView.automaticDimension
        self.navigationController?.navigationBar.tintColor = .black
        self.navigationController?.navigationBar.topItem?.title = ""
        self.view.addSubview(indicator)
    }
    
    // MARK: - UI Binding
    func setupBindings() {
        // ------------------------------
        //     INPUT
        // ------------------------------

        // 처음 로딩할 때 하고, 당겨서 새로고침 할 때
        let firstLoad = rx.viewWillAppear
            .take(1)
            .map { _ in () }
        let reload = tableView.refreshControl?.rx
            .controlEvent(.valueChanged)
            .map { _ in () } ?? Observable.just(())
        
        Observable.merge([firstLoad, reload])
            .bind(to: viewModel.input.fetchList)
            .disposed(by: disposeBag)
        
        // 무한 스크롤
        tableView.rx_reachedBottom
            .map { _ in () }
            .bind(to: viewModel.input.moreFetchList)
            .disposed(by: disposeBag)
        

        // ------------------------------
        //     Page Move
        // ------------------------------

        // 페이지 이동
        Observable.zip(tableView.rx.modelSelected(Feed.self), tableView.rx.itemSelected) .bind { [weak self] item, indexPath in
            let storyboard = UIStoryboard(name:"Feed", bundle: nil)
            let pushVC = storyboard.instantiateViewController(withIdentifier: "FeedDetailViewController") as! FeedDetailViewController
            pushVC.viewModel = FeedDetailViewModel(item)
            self?.navigationController?.pushViewController(pushVC, animated: true)
        } .disposed(by: disposeBag)

        // ------------------------------
        //     OUTPUT
        // ------------------------------
        
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
            .map { !$0 }
            .observe(on: MainScheduler.instance)
            .do(onNext: { [weak self] finished in
                if finished {
                    self?.tableView.refreshControl?.endRefreshing()
                }
            })
            .bind(to: indicator.rx.isHidden)
            .disposed(by: disposeBag)
                
        // 테이블뷰 아이템들
        viewModel.output.items
            .drive(tableView.rx.items(cellIdentifier: HomeTableCell.identifier, cellType: HomeTableCell.self)) {
                _, item, cell in
                cell.onData.onNext(item)
                cell.delegate = self
            }
            .disposed(by: disposeBag)
    }
}

extension HomeViewController: HomeTableDelegate {
    func didSelectedProfile(_ homeTableCell: HomeTableCell, detailButtonTappedFor artist: Artist) {
        
        let storyboard = UIStoryboard(name:"Profile", bundle: nil)
        let pushVC = storyboard.instantiateViewController(withIdentifier: "OtherProfileViewController") as! OtherProfileViewController
        print("-> \(artist.profile)")
        pushVC.viewModel = OtherProfileViewModel(artist)
        self.navigationController?.pushViewController(pushVC, animated: true)
    }
    
    func didSelectedMore(_ homeTableCell: HomeTableCell, detailButtonTappedFor workId: Int) {
        
        let actions: [UIAlertController.AlertAction] = [
            .action(title: "신고하기"),
            .action(title: "취소", style: .cancel)
        ]

        UIAlertController
            .present(in: self, title: "Alert", message: "message", style: .actionSheet, actions: actions)
            .filter{ $0 == 0 }
            .subscribe(onNext: { _ in
                Observable.just(workId)
                    .subscribe(onNext: { id in
                        self.viewModel.input.report.onNext(id)
                    })
                    .disposed(by: self.disposeBag)
            })
            .disposed(by: disposeBag)
    }
    
    func didSelectedLike(_ homeTableCell: HomeTableCell, detailButtonTappedFor postId: Int) {
        let service: FeedFetchable = FeedService()
        Observable.just(postId)
            .map{ String($0) }
            .flatMapLatest{service.like($0)}
            .subscribe(onNext: { response in
                print(response)
                if response.message == "좋아요+1" {
                    let count = Int(homeTableCell.likeCount.text ?? "0")! + 1
                    homeTableCell.likeCount.text = String(count)
                    homeTableCell.like.imageView?.image = UIImage(named: "heart_fill_asset")
                } else if response.message == "좋아요 취소" {
                    let count = Int(homeTableCell.likeCount.text ?? "0")! - 1
                    homeTableCell.likeCount.text = String(count)
                    homeTableCell.like.imageView?.image = UIImage(named: "heart_blank_asset")
                }
            })
            .disposed(by: disposeBag)
    }
}

