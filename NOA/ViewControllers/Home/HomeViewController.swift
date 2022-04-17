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
            type: .ballScaleMultiple,
            color: .black,
            padding: 0)
        
        indicator.center = self.view.center
                
        // 기타 옵션
        indicator.color = .purple
        
        indicator.stopAnimating()
        return indicator
    }()
    
    let viewModel: HomeViewModelType
    var disposeBag = DisposeBag()

    // MARK: - Life Cycle

    init(viewModel: HomeViewModelType = HomeViewModel()) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        viewModel = HomeViewModel()
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.refreshControl = UIRefreshControl()
        setupBindings()
    }
}

extension HomeViewController {
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
            .bind(to: viewModel.fetchList)
            .disposed(by: disposeBag)
        
        // 무한 스크롤
        tableView.rx.didScroll
            .subscribe { [weak self] _ in
                guard let self = self else { return }
                let offSetY = self.tableView.contentOffset.y
                let contentHeight = self.tableView.contentSize.height

                if offSetY > (contentHeight - self.tableView.frame.size.height - 100) {
                    self.viewModel.nextList.onNext(())
                }
            }
            .disposed(by: disposeBag)

        // ------------------------------
        //     Page Move
        // ------------------------------

        // 페이지 이동
        tableView.rx.itemSelected
          .subscribe(onNext: { [weak self] indexPath in
//            let cell = self?.tableView.cellForRow(at: indexPath) as? FeedCell
//              cel
//              cell.button.isEnabled = false
              self?.performSegue(withIdentifier: "FeedDetailSegue",
                                 sender: nil)
          }).disposed(by: disposeBag)
//        viewModel.activated
//            .filter { !$0 }
//            .subscribe(onNext: { [weak self] _ in
//                self?.performSegue(withIdentifier: "MainSegue",
//                                   sender: nil)
//            })
//            .disposed(by: disposeBag)

        // ------------------------------
        //     OUTPUT
        // ------------------------------

        // 에러 처리
        viewModel.errorMessage
            .map { $0.domain }
            .subscribe(onNext: { [weak self] message in
                self?.OKDialog("Order Fail")
            })
            .disposed(by: disposeBag)
        
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
        viewModel.lectureList
                .map { $0 }
                .map { response -> [Lecture] in
                    return response.lectures
                }
                .bind(to: tableView.rx.items(cellIdentifier: FeedCell.identifier,
                                         cellType: FeedCell.self)) {
                    _, item, cell in
                    print(item)
                    cell.onData.onNext(item)
//                    cell.onLike
//                        .map { (item, $0) }
//                        .bind(to: self.viewModel.increaseMenuCount)
//                        .disposed(by: cell.disposeBag)
                }
            .disposed(by: disposeBag)
    }
}
