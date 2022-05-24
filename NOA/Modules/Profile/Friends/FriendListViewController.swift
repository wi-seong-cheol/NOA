//
//  FriendListViewController.swift
//  NOA
//
//  Created by wi_seong on 2022/05/10.
//


import RxCocoa
import RxSwift
import RxViewController
import NVActivityIndicatorView
import UIKit

class FriendListViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
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
    
    let viewModel: FriendListViewModelType
    var disposeBag = DisposeBag()

    // MARK: - Life Cycle

    init(viewModel: FriendListViewModelType = FriendListViewModel()) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        viewModel = FriendListViewModel()
        super.init(coder: aDecoder)
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

extension FriendListViewController {
    // MARK: - UI Setting
    func configure() {
        tableView.refreshControl = UIRefreshControl()
//        tableView.rowHeight = UITableView.automaticDimension
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
            .bind(to: self.viewModel.fetchList)
            .disposed(by: disposeBag)
        
        // 무한 스크롤
        self.tableView.rx_reachedBottom
            .map { _ in () }
            .bind(to: self.viewModel.moreFetchList)
            .disposed(by: disposeBag)

        // ------------------------------
        //     Page Move
        // ------------------------------

        // 페이지 이동
        Observable.zip(tableView.rx.modelSelected(Lecture.self), tableView.rx.itemSelected) .bind { [weak self] item, indexPath in
            let storyboard = UIStoryboard(name:"Profile", bundle: nil)
            let pushVC = storyboard.instantiateViewController(withIdentifier: "OtherProfileViewController")
            self?.navigationController?.pushViewController(pushVC, animated: true)
        } .disposed(by: disposeBag)

        // ------------------------------
        //     OUTPUT
        // ------------------------------

        // 에러 처리
        viewModel.errorMessage
            .map { $0.domain }
            .subscribe(onNext: { [weak self] message in
                self?.OKDialog("Order Fail")
            }).disposed(by: disposeBag)
        
        // 액티비티 인디케이터
        viewModel.activated
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
        viewModel.items
            .bind(to: tableView.rx.items(cellIdentifier: FriendListTableCell.identifier, cellType: FriendListTableCell.self)) {
                _, item, cell in
                cell.onData.onNext(item)
                cell.delegate = self
            }
            .disposed(by: disposeBag)
    }
}

extension FriendListViewController: FriendListTableDelegate {
    
    func didSelectedMore(_ friendListTableCell: FriendListTableCell, detailButtonTappedFor workId: String) {
        print(workId)
        
        let actions: [UIAlertController.AlertAction] = [
            .action(title: "no", style: .destructive),
            .action(title: "yes")
        ]

        UIAlertController
            .present(in: self, title: "Alert", message: "message", style: .actionSheet, actions: actions)
            .subscribe(onNext: { buttonIndex in
                print(buttonIndex)
                // coding
            })
            .disposed(by: disposeBag)
    }
}

