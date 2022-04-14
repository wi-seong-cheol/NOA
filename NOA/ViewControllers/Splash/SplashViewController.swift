//
//  SplashViewController.swift
//  NOA
//
//  Created by wi_seong on 2022/04/08.
//

import RxCocoa
import RxSwift
import RxViewController
import UIKit

class SplashViewController: UIViewController {
    
    let viewModel: SplashViewModelType
    var disposeBag = DisposeBag()

    // MARK: - Life Cycle

    init(viewModel: SplashViewModelType = SplashViewModel()) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        viewModel = SplashViewModel()
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // activity 추후에 다른 것으로 변경
        let activity = UIActivityIndicatorView()
        view.addSubview(activity)
        activity.tintColor = .red
        activity.translatesAutoresizingMaskIntoConstraints = false
        activity.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        activity.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        
//        viewModel.loadingStarted = { [weak activity] in
//            activity?.isHidden = false
//            activity?.startAnimating()
//        }
//
//        viewModel.loadingEnded = { [weak activity] in
//            activity?.stopAnimating()
//
//            // 나중에 시간초 제거
//            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .seconds(1)) {
//                self.performSegue(withIdentifier: "MainSegue", sender: nil)
//            }
//        }
//
//        viewModel.initialization()
        setupBindings()
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
        let secondLoad = rx.viewWillAppear
            .take(1)
            .map { _ in () }
        Observable.merge(firstLoad)
            .bind(to: viewModel.fetchList)
            .disposed(by: disposeBag)
        
        let viewDidAppear = rx.viewWillAppear.map { _ in () }
//        Observable.merge(viewDidAppear)
//            .bind(to: viewModel.clearSelections)
//            .disposed(by: disposeBag)

        // ------------------------------
        //     NAVIGATION
        // ------------------------------

        // 페이지 이동
//        viewModel.showOrderPage
//            .subscribe(onNext: { [weak self] selectedMenus in
//                self?.performSegue(withIdentifier: OrderViewController.identifier,
//                                   sender: selectedMenus)
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
//        viewModel.activated
//            .map { !$0 }
//            .observeOn(MainScheduler.instance)
//            .do(onNext: { [weak self] finished in
//                if finished {
//                    self?.tableView.refreshControl?.endRefreshing()
//                }
//            })
//            .bind(to: activityIndicator.rx.isHidden)
//            .disposed(by: disposeBag)
        viewModel.lectureList
            .bind() { result in
                print(result)
            }
            .disposed(by: disposeBag)
    }
}
